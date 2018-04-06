#!/usr/bin/env python3.6
##
# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
##

import os

SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))

# ---------------------------------------------------------

import argparse

parser = argparse.ArgumentParser()
parser.add_argument('modules', metavar='MODULES', nargs='+',
                    help='modules')

args = parser.parse_args()

# -----------------------------------------------------------

import jinja2

fs_loader = jinja2.FileSystemLoader(SCRIPT_DIR)
jinja_env = jinja2.Environment(
    loader      = fs_loader,
    trim_blocks = True,
    lstrip_blocks   = True
)

template = jinja_env.get_template('template.ebuild.jinja2')

rendered_ebuild = template.render(**dict((mod, True) for mod in args.modules))

## print to stdout
print(rendered_ebuild)

## put to clipboard
import subprocess

subprocess.run(
    ['xclip', '-selection', 'c'],
    input=rendered_ebuild.encode("utf-8")
)


