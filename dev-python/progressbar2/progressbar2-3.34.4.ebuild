# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:WoLpH:python-progressbar"
GH_REF="v${PV}"

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## functions: eautoreconf
inherit distutils-r1

DESCRIPTION="Progress bar for Python 2 and Python 3"
LICENSE="BSD"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/python-utils[${PYTHON_USEDEP}]"
	"dev-python/six[${PYTHON_USEDEP}]"
)

inherit arrays

src_prepare() {
	default

	esed -e "s|, 'pytest-runner>=2.8'||" -i -- setup.py

	distutils-r1_src_prepare
}
