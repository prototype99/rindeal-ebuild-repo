# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## python-*.eclass:
PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

## git-hosting.eclass:
GH_RN='github:gpocentek:python-gitlab'

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
## functions: distutils-r1_python_prepare_all, distutils-r1_python_install_all
inherit distutils-r1

DESCRIPTION="Python wrapper for the GitLab API"
HOMEPAGE="https://python-gitlab.readthedocs.io ${GH_HOMEPAGE}"
LICENSE="LGPL-3"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="man test"

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"man? ( dev-python/sphinx )"
	"test? ("
		"dev-python/coverage"
		"dev-python/testrepository"
		">=dev-python/hacking-0.9.2"
		"<dev-python/hacking-0.10"
		"dev-python/httmock"
		"dev-python/jinja"
		"dev-python/mock"
		">=dev-python/sphinx-1.3"
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	">dev-python/requests-1"
	"dev-python/six"
)

inherit arrays

python_prepare_all() {
	use test || \
		erm -r 'gitlab/tests'

	distutils-r1_python_prepare_all
}

python_compile_all() {
	use man && \
		emake -C docs man
}

python_test() {
	esetup.py testr
}

python_install_all() {
	distutils-r1_python_install_all

	use man && \
		doman 'docs/_build/man/python-gitlab.1'
}
