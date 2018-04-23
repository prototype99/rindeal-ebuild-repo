#!/usr/bin/env python3

import os
import traceback
import glob
from multiprocessing import Pool, Process, Lock
import subprocess

import requests
import portage
from terminaltables import AsciiTable


DEBUG=0
if 'DEBUG' in os.environ:
    DEBUG = os.environ['DEBUG']

PORTDIR_OVERLAY=os.path.realpath(os.path.dirname(os.path.realpath(__file__)) + "/../")
os.chdir(PORTDIR_OVERLAY)
os.environ["PORTDIR_OVERLAY"] = PORTDIR_OVERLAY


# retrieves the latest versions for specified product codes
def get_version( codes ):
    payload = {
        'code': ','.join(codes),
        'latest': 'false',
        'type': 'release'
    }
    r = requests.get('https://data.services.jetbrains.com/products/releases', params=payload)
    json=r.json()

    # [code][slot]
    versions = {}
    for c in codes:
        versions[c] = {}
        all_v_data = json[c]

        # latest version is always the first one
        versions[c]['latest_slot'] = all_v_data[0]['majorVersion']

        # loop over all data and pick the first version from each slot, because the data are already sorted
        for v_data in all_v_data:
            slot = v_data['majorVersion']
            if not slot in versions[c]:
                v = v_data['version']
                versions[c][slot] = v

    return versions

# format: `package_name: product_code`
codes={
    'clion': 'CL',
    'datagrip': 'DG',
    'idea': 'IIU',
    'idea-community': 'IIC',
    'phpstorm': 'PS',
    'pycharm': 'PCP',
    'pycharm-community': 'PCC',
    'rider': 'RD',
    'rubymine': 'RM',
    'webstorm': 'WS',
}

remote_versions = get_version(codes.values())

update_table = [dict() for x in range(0)]

pdb = portage.db[portage.root]["porttree"].dbapi

for pn, code in sorted(codes.items()):
    new_updates = [dict() for x in range(0)]

    # find category by globbing in this repo
    cat = glob.glob(f"*/{pn}/{pn}*.ebuild")[0].split("/")[0]

    # find the newest version for each slot
    loc_slots = {}
    local_versions = pdb.xmatch('match-visible', f"{cat}/{pn}::rindeal")
    for v in local_versions:
        slot = pdb.aux_get(v, ["SLOT"])[0]
        # add if not yet present
        if not slot in loc_slots:
            loc_slots[slot] = v
            continue
        # update slot if newer version was found
        if portage.vercmp(loc_slots[slot], v) < 0:
            loc_slots[slot] = v

    # now compare current and server versions for each slot
    for slot in loc_slots:
        pkg = loc_slots[slot]

        loc_ver = portage.pkgsplit(pkg)[1]
        rem_ver = remote_versions[code][slot]

        if portage.vercmp(loc_ver, rem_ver) < 0:
            new_updates.append({
                    'cat': cat,
                    'pn': pn,
                    'loc_slot': slot,
                    'loc_ver': loc_ver,
                    'rem_slot': slot,
                    'rem_ver': rem_ver
                })

    # now look for the newest version outside of any known slots
    latest_loc_pkg = pdb.xmatch('bestmatch-visible', f"{cat}/{pn}::rindeal")
    latest_loc_ver = portage.pkgsplit(latest_loc_pkg)[1]
    latest_loc_slot = pdb.aux_get(latest_loc_pkg, ["SLOT"])[0]
    latest_rem_slot = remote_versions[code]['latest_slot']
    latest_rem_ver = remote_versions[code][latest_rem_slot]
    if portage.vercmp(latest_loc_ver, latest_rem_ver) < 0:
        # check for duplicates
        is_dup = 0
        for update in new_updates:
            if update['loc_slot'] == latest_rem_slot:
                is_dup = 1
                break

        if not is_dup:
            new_updates.append({
                    'cat': cat,
                    'pn': pn,
                    'loc_slot': latest_loc_slot,
                    'loc_ver': latest_loc_ver,
                    'rem_slot': latest_rem_slot,
                    'rem_ver': latest_rem_ver
                })

    update_table += new_updates


# create a pretty table
pretty_table = [ [ 'Category', 'Package', 'Slot', 'Version' ] ]
for u in update_table:
    slot = u['loc_slot']
    if slot != u['rem_slot']:
        slot += ' -> ' + u['rem_slot']
    pretty_table.append([ u['cat'], u['pn'], slot, u['loc_ver'] + ' -> ' + u['rem_ver'] ])

# now print the table
print(AsciiTable(pretty_table).table)
# and prompt the user for an action
y = input("Press 'y' to proceed with the update\n")
if y != "y":
    print(f"You pressed '{y}', bailing...")
    exit(0)


def run_cmd(cmd):
    pn = os.path.basename(os.getcwd())
    print(f"> \033[94m{pn}\033[0m: `\033[93m{cmd}\033[0m`")
    err = os.system(cmd)
    if err:
        print(f"{pn}: command '{cmd}' failed with code {err}")
    return err


def update_pkg(cat, pn, loc_slot, loc_ver, rem_slot, rem_ver):
    global GIT_LOCK, PKG_LOCKS, PORTDIR_OVERLAY

    cat_pn = f"{cat}/{pn}"

    os.chdir(f"{PORTDIR_OVERLAY}/{cat_pn}")

    PKG_LOCKS[cat_pn].acquire()

    new_slot = False if loc_slot == rem_slot else True

    if new_slot: # bump into a new slot
        run_cmd(f"cp -v {pn}-{loc_slot}*.ebuild {pn}-{rem_ver}.ebuild")
    else: # bump inside a slot
        GIT_LOCK.acquire()
        run_cmd(f"git mv -v {pn}-{loc_ver}*.ebuild {pn}-{rem_ver}.ebuild")
        GIT_LOCK.release()

    if run_cmd(f"repoman manifest {pn}-{rem_ver}.ebuild") != 0:
        GIT_LOCK.acquire()
        run_cmd('git reset -- .')
        run_cmd('git checkout -- .')
        GIT_LOCK.release()

        PKG_LOCKS[cat_pn].release()

        return 1

    GIT_LOCK.acquire()
    run_cmd(f"git add {pn}-{rem_ver}.ebuild")
    if new_slot:
        run_cmd(f"git commit -m '{cat}/{pn}: new version v{rem_ver}' .")
    else: # bump inside a slot
        run_cmd(f"git commit -m '{cat}/{pn}: bump to v{rem_ver}' .")
    GIT_LOCK.release()

    PKG_LOCKS[cat_pn].release()

# only one git command may run concurrently
GIT_LOCK = Lock()
PKG_LOCKS = {}

for update in update_table:
    cat_pn = update['cat'] + "/" + update['pn']
    if not cat_pn in PKG_LOCKS:
        PKG_LOCKS[cat_pn] = Lock()

# DEBUG
#update_pkg(update_table[0])

# https://stackoverflow.com/a/25558333/2566213
def pool_init(l):
    global PKG_LOCKS
    PKG_LOCKS = l

pool = Pool(processes=8, initializer=pool_init, initargs=(PKG_LOCKS, ))

for update in update_table:
    pool.apply_async(func=update_pkg, kwds=update)

pool.close()
pool.join()
