# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:the-${PN}-group"
GH_REF="${PN}-${PV}"

## EXPORT_FUNCTIONS: src_unpack
## variables: GH_HOMEPAGE
inherit git-hosting
## functions: append-cppflags
inherit flag-o-matic
## functions: tc-getPKG_CONFIG
inherit toolchain-funcs
## functions: enewgroup, enewuser
inherit user

DESCRIPTION="Tool for network monitoring and data acquisition"
HOMEPAGE="${GH_HOMEPAGE} https://www.tcpdump.org/"
LICENSE="BSD"

SLOT="0"

KEYWORDS="amd64 arm arm64"
IUSE_A=( +drop-root smi ssl samba suid test )

CDEPEND_A=(
	"net-libs/libpcap"

	"drop-root? ( sys-libs/libcap-ng )"
	"smi? ( net-libs/libsmi )"
	"ssl? ( dev-libs/openssl:0 )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"drop-root? ( virtual/pkgconfig )"
	"test? ("
		"|| ("
			"app-arch/sharutils"
			"sys-freebsd/freebsd-ubin )"
		"dev-lang/perl"
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

my_use_custom_account() {
	use drop-root || use suid
}

src_configure() {
	if use drop-root ; then
		append-cppflags "-DHAVE_CAP_NG_H"
		export LIBS=$( $(tc-getPKG_CONFIG) --libs libcap-ng )
	fi

	local my_econf_args=(
		$(use_enable samba smb)
		$(use_with drop-root chroot '')
		$(use_with smi)
		$(use_with ssl crypto "${EPREFIX}/usr")
		$(usex drop-root --with-user="${PN}" '')
	)
	econf "${my_econf_args[@]}"
}

src_test() {
	if (( EUID )) || ! use drop-root ; then
		esed -e '/^\(espudp1\|eapon1\)/d;' -i -- tests/TESTLIST
		emake check
	else
		ewarn "Tests skipped!"
		ewarn "If you want to run the test suite, make sure you either"
		ewarn "set FEATURES=userpriv or set USE=-drop-root"
	fi
}

src_install() {
	dosbin "${PN}"
	doman "${PN}.1"

	dodoc *.awk
	einstalldocs

	if use suid ; then
		fowners "root":"tcpdump" "/usr/sbin/${PN}"
		fperms 4110 "/usr/sbin/${PN}"
	fi
}

pkg_preinst() {
	if my_use_custom_account ; then
		enewgroup "tcpdump"
		enewuser "tcpdump" -1 -1 -1 "tcpdump"
	fi
}

pkg_postinst() {
	my_use_custom_account && \
		elog "To let normal users run '${PN}' add them into 'tcpdump' group."
}
