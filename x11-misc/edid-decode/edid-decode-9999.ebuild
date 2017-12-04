# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-r3.eclass
EGIT_REPO_URI="https://anongit.freedesktop.org/git/xorg/app/${PN}.git"
EGIT_CLONE_TYPE="shallow"
EGIT_SUBMODULES=()

## EXPORT_FUNCTIONS: src_unpack
inherit git-r3

DESCRIPTION="EDID decoder and conformance tester"
HOMEPAGE="https://cgit.freedesktop.org/xorg/app/${PN}/"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_prepare() {
    default

	sed -e "s| -g||" -i -- Makefile || die
}

src_install() {
	dobin "${PN}"
	doman "${PN}.1"

	einstalldocs
}
