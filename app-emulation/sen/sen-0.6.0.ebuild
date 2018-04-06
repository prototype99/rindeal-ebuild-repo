# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:TomasTomecek"

## python-*.eclass:
PYTHON_COMPAT=( python3_{4,5,6} )

## distutils-r1.eclass:
DISTUTILS_SINGLE_IMPL=true

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit distutils-r1

DESCRIPTION="Terminal User Interface for docker engine"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64"
IUSE_A=()

CDEPEND_A=(
	"dev-python/urwid[${PYTHON_USEDEP}]"
	"dev-python/urwidtrees[${PYTHON_USEDEP}]"
	"dev-python/docker-py[${PYTHON_USEDEP}]"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

python_install_all() {
	distutils-r1_python_install_all

	dodoc docs/*
}
