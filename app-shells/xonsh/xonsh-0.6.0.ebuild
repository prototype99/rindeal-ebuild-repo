# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github"

## python-*.eclass:
PYTHON_COMPAT=( python3_{4,5,6} )

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
## variables: PYTHON_USEDEP
inherit distutils-r1
## functions: optfeature
inherit eutils

DESCRIPTION="Python-powered, cross-platform, Unix-gazing shell"
HOMEPAGE="
	${GH_HOMEPAGE}
	https://xonsh.readthedocs.org/
	https://pypi.python.org/pypi/xonsh"
LICENSE="BSD"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( test )

CDEPEND_A=(
	"dev-python/ply[${PYTHON_USEDEP}]"
	"dev-python/pygments[${PYTHON_USEDEP}]"
)
DEPEND=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
	"test? ("
		"dev-python/nose[${PYTHON_USEDEP}]"
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

python_test() {
	nosetests --verbose || die
}

pkg_postinst() {
	elog "Optional features"
	optfeature "Jupyter kernel support" dev-python/jupyter
	optfeature "Alternative to readline backend" dev-python/prompt_toolkit
}
