# Copyright 1999-2014 Gentoo Foundation
# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="gitlab:rindeal-forks"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## functions: eautoreconf
inherit autotools
## functions: prune_libtool_files
inherit ltprune
## EXPORT_FUNCTIONS: pkg_setup
inherit linux-info
## functions: enewgroup, enewuser
inherit user

DESCRIPTION="Miredo is an open-source Teredo IPv6 tunneling software"
HOMEPAGE="http://www.remlab.net/miredo/ ${GH_HOMEPAGE}"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="amd64 arm arm64"
IUSE_A=( +caps +client nls +assert judy )

CDEPEND_A=(
	"sys-devel/gettext"
	"sys-apps/iproute2"
	"virtual/udev"
	"caps? ( sys-libs/libcap )"
	"judy? ( dev-libs/judy )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"app-arch/xz-utils"
)

inherit arrays

#tries to connect to external networks (#339180)
RESTRICT+=" test"

CONFIG_CHECK="~IPV6 ~TUN"

src_prepare() {
	default

	# the following step is normally done in `autogen.sh`
	ecp "${EPREFIX}"/usr/share/gettext/gettext.h "${S}"/include

	eautoreconf
}

src_configure() {
	local econf_args=(
		--disable-static
		--enable-miredo-user=miredo
		--with-runstatedir=/run

		$(use_enable assert)
		$(use_with caps libcap)
		$(use_enable client teredo-client)
		$(use_enable nls)
	)
	econf "${econf_args[@]}"
}

src_install() {
	default

	insinto /etc/miredo
	doins misc/miredo-server.conf

	prune_libtool_files
}

pkg_preinst() {
	enewgroup miredo
	enewuser miredo -1 -1 /var/empty miredo
}
