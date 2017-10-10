# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:jedisct1"

inherit git-hosting
inherit systemd
inherit user
inherit autotools
inherit rindeal-utils

DESCRIPTION="A tool for securing communications between a client and a DNS resolver"
HOMEPAGE="https://dnscrypt.org ${GH_HOMEPAGE}"
LICENSE="ISC"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( plugins ssl systemd static )

CDEPEND_A=(
	"dev-libs/libsodium"
	"net-libs/ldns"
	"ssl? ( dev-libs/openssl:0= )"
	"systemd? ( sys-apps/systemd )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_prepare() {
	default

	sed -e 's|--ltdl||' -i -- autogen.sh || die

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--disable-pie
		--disable-ssp
		--disable-debug
		--without-safecode
		--without-systemd # we use custom systemd service

		$(use_enable static)
		$(use_enable plugins)
		$(use_enable ssl openssl)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	local DOCS="AUTHORS ChangeLog NEWS README* THANKS *txt"
	default

	rindeal:expand_vars "${FILESDIR}"/${PN}.service.in "${T}"/${PN}.service
	systemd_dounit "${T}"/${PN}.service
	systemd_dounit "${FILESDIR}"/${PN}.socket
}

pkg_postinst() {
	enewgroup dnscrypt
	enewuser dnscrypt -1 -1 /var/empty dnscrypt
}
