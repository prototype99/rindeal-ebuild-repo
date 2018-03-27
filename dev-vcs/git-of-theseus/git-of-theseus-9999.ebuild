# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:erikbern"

# TODO: fork seaborn pkg from gentoo repos and add python3.6
PYTHON_COMPAT=( python3_{4,5} )
DISTUTILS_SINGLE_IMPL=1

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## functions: eautoreconf
inherit distutils-r1

DESCRIPTION="Analyze how a Git repo grows over time"
LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/git-python[${PYTHON_USEDEP}]"
	"dev-python/numpy[${PYTHON_USEDEP}]"
	"dev-python/progressbar2[${PYTHON_USEDEP}]"
	"dev-python/pygments[${PYTHON_USEDEP}]"
	"dev-python/matplotlib[${PYTHON_USEDEP}]"
	"dev-python/seaborn[${PYTHON_USEDEP}]"
)

inherit arrays
