# Copyright 1999-2015 Gentoo Foundation
# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:Kozea:CairoSVG"

## python-*.eclass:
PYTHON_COMPAT=( python3_{5,6} )

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
##
inherit distutils-r1

DESCRIPTION="Simple cairo based SVG converter with support for PDF, PostScript and PNG"
HOMEPAGE="https://cairosvg.org/ ${GH_HOMEPAGE}"
LICENSE="LGPL-3"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"

CDEPEND_A=(
	"dev-python/cairocffi[${PYTHON_USEDEP}]"
	"dev-python/cssselect2[${PYTHON_USEDEP}]"
	"dev-python/defusedxml[${PYTHON_USEDEP}]"
	"dev-python/pillow[${PYTHON_USEDEP}]"
	"dev-python/tinycss2[${PYTHON_USEDEP}]"

)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

DOCS=( NEWS.rst README.rst TODO.rst )
