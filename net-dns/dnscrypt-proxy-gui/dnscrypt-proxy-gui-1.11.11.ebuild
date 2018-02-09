# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:F1ash"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
## variables: mycmakeargs
inherit cmake-utils

DESCRIPTION="Qt/KF5 GUI wrapper over dnscrypt-proxy"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64"
IUSE_A=( )

CDEPEND_A=(
	"net-dns/dnscrypt-proxy"
)
DEPEND_A=( "${CDEPEND_A[@]}"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

pkg_setup() {
	mycmakeargs=(
		-DSHARE_INSTALL_PREFIX="${EPREFIX}/usr/share"
	)
}
