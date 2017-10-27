#!/usr/bin/env python3
# Copyright 2016-2017 Jan Chren (rindeal) <dev.rindeal@gmail.com>
# Distributed under the terms of the GNU General Public License v2

import os
import glob
import jinja2
import portage

SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
PORTDIR_OVERLAY = os.path.realpath(SCRIPT_DIR + '/../')
PORTAGE_DB = portage.db[portage.root]["porttree"].dbapi

os.chdir(PORTDIR_OVERLAY)
os.environ["PORTDIR_OVERLAY"] = PORTDIR_OVERLAY

# structure will look like this:
# cats = {
#     "cat1": {
#         "pkg1": {
#             "desc": ...,
#             "home": ...
#         },
#         "pkg2": { ... }
#     },
#     "cat2": { ... },
#     ...
# }
# cats = defaultdict(set)
cats = {}

for f in glob.iglob('*/*/*.ebuild'):
    cat, pn, pf = f.split('/')
    if not cat in cats:
        cats[cat] = {}
    if pn in cats[cat]:
        continue

    db_pkg = PORTAGE_DB.xmatch("match-all", '{0}/{1}::rindeal'.format(cat, pn))[0]
    desc, home = PORTAGE_DB.aux_get(db_pkg, ['DESCRIPTION', 'HOMEPAGE'])
    home = home.split()[0] # get only the first_pkg homepage

    cats[cat][pn] = {
        'desc': desc,
        'home': home
    }

fs_loader = jinja2.FileSystemLoader(SCRIPT_DIR)
jinja_env = jinja2.Environment(
        loader = fs_loader,
        trim_blocks = True,
        lstrip_blocks = True
    )

template = jinja_env.get_template('listing.tmpl.md')
print(template.render(categories=cats))
