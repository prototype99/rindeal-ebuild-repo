# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## functions: append-cflags
inherit flag-o-matic
## functions: tc-getPKG_CONFIG
inherit toolchain-funcs
## functions: dohelp2man
inherit help2man

DESCRIPTION="Nigel's performance MONitor for CPU, memory, network, disks, etc..."
HOMEPAGE="https://nmon.sourceforge.net/"
LICENSE="GPL-3"

MY_DISTFILE="lmon${PV}.c"

SLOT="0"
SRC_URI="mirror://sourceforge/${PN}/${MY_DISTFILE}"

KEYWORDS="amd64 arm ~arm64"

CDEPEND_A=(
	"sys-libs/ncurses:0="
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
)

inherit arrays

S="${WORKDIR}"

src_unpack() {
	ecp -f "${DISTDIR}/${MY_DISTFILE}" "${S}/${PN}.c"
}

src_configure() {
	local cflags=(
		## recommended by upstream to be always on
		-DGETUSER
		-DJFS
		-DKERNEL_2_6_18
		-DLARGEMEM

		## archs
		$(usex amd64 "-DX86" "")
		$(usex arm "-DARM" "")
	)
	append-cflags "${cflags[@]}"
	export LDLIBS="$( $(tc-getPKG_CONFIG) --libs ncurses ) -lm"
}

src_compile() {
	emake ${PN}
}

src_install() {
	dobin ${PN}

	HELP2MAN_OPTS=(
		--name="Performance Monitor"
	)
	dohelp2man "${PN}"

	newenvd "${FILESDIR}"/${PN}.envd 70${PN}
}
