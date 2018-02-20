# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github"
GH_REF="v${PV}"

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit distutils-r1
inherit git-hosting

DESCRIPTION="Python library to access the Github API v3"
LICENSE="LGPL-3"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="test"

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/pyjwt[${PYTHON_USEDEP}]"
)

inherit arrays

python_prepare_all() {
	if ! use test ; then
		esed -e '/"github.tests"/d' -i -- setup.py
		esed -e '/"github": \["tests/d' -i -- setup.py
	fi

	distutils-r1_python_prepare_all
}

python_test() {
	esetup.py test
}
