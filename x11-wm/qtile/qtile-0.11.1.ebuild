# Copyright 1999-2016 Gentoo Foundation
# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github"
GH_REF="v${PV}"

## distutils-r1.eclass:
PYTHON_COMPAT=( python3_{4,5,6} )

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit distutils-r1
## functions: virtualmake
inherit virtualx

DESCRIPTION="A full-featured, hackable tiling window manager written in Python"
HOMEPAGE="https://qtile.org/"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64"
IUSE_A=( test )

## https://qtile.readthedocs.io/en/latest/manual/install/index.html#installing-from-source
CDEPEND_A=(
	"dev-python/xcffib[${PYTHON_USEDEP}]"
	"dev-python/cairocffi[${PYTHON_USEDEP}]"

	"x11-libs/pango"
	"x11-libs/cairo[xcb]"

	## not mentioned in docs, but specified in setup.py:
	">=dev-python/cffi-1.1.0[${PYTHON_USEDEP}]"
	">=dev-python/six-1.4.1[${PYTHON_USEDEP}]"

	## optional
	"dev-python/dbus-python[${PYTHON_USEDEP}]"
	"dev-python/pygobject:3[${PYTHON_USEDEP}]"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"

	"test? ("
		"dev-python/nose[${PYTHON_USEDEP}]"
		"x11-base/xorg-server[kdrive]"
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

# docs require sphinxcontrib-blockdiag and sphinxcontrib-seqdiag

RESTRICT+=" test"

python_test() {
	VIRTUALX_COMMAND="nosetests" virtualmake
}

python_install_all() {
	local DOCS=( CHANGELOG README.rst )
	distutils-r1_python_install_all

	insinto /usr/share/xsessions
	doins resources/qtile.desktop

	exeinto /etc/X11/Sessions
	newexe "${FILESDIR}"/${PN}-session ${PN}
}
