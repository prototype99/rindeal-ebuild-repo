# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

FONT_SUFFIX="ttf"

GH_RN="github:ansilove"

## EXPORT_FUNCTIONS: pkg_setup src_install pkg_postinst pkg_postrm
inherit font
## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

DESCRIPTION="Faithful recreation of the original DOS font"
LICENSE="OFL-1.1"

SLOT="0"

KEYWORDS="amd64 arm arm64"

DOCS="README.md"
