# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:jarun"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

DESCRIPTION="The missing terminal file browser for X"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=(
	"sys-libs/ncurses:0[unicode]"
	"sys-libs/readline:0"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_prepare() {
	ecp "${FILESDIR}/1.6-Makefile" Makefile

	eapply_user
}

src_install() {
	dobin "${PN}" nlay
	doman "${PN}.1"
	einstalldocs
}
