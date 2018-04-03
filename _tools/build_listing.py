#!/usr/bin/env python3
# Copyright 2016-2017 Jan Chren (rindeal) <dev.rindeal@gmail.com>
# Distributed under the terms of the GNU General Public License v2

import os
import glob

import jinja2

from ebuild_repo_toolbox import EbuildRepoToolbox

EbuildRepoToolbox.setup_working_environment()
PORTAGE_DB = EbuildRepoToolbox.get_portagetree().dbapi

SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))

#settings = portage.config()

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
	if cat not in cats:
		cats[cat] = {}
	if pn in cats[cat]:
		continue

	db_pkg = PORTAGE_DB.xmatch("match-all", f'{cat}/{pn}::rindeal')[0]
	desc, home = PORTAGE_DB.aux_get(db_pkg, ['DESCRIPTION', 'HOMEPAGE'])
	home = home.split()[0]  # get only the first_pkg homepage

	cats[cat][pn] = {
		'desc': desc,
		'home': home
	}


fs_loader = jinja2.FileSystemLoader(SCRIPT_DIR)
jinja_env = jinja2.Environment(
		loader=fs_loader,
		trim_blocks=True,
		lstrip_blocks=True
	)

template = jinja_env.get_template('listing.md.jinja2')
print(template.render(categories=cats))
