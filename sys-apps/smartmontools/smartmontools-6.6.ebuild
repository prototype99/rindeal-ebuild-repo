# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github"
GH_REF="RELEASE_${PV//./_}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
inherit flag-o-matic
## functions: eautoreconf
inherit autotools
inherit systemd

DESCRIPTION="Control and monitor storage systems using S.M.A.R.T."
HOMEPAGE="https://www.smartmontools.org"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(caps examples selinux static nvme gnupg)

CDEPEND_A=(
	"caps? ("
		"static? ( sys-libs/libcap-ng[static-libs] )"
		"!static? ( sys-libs/libcap-ng )"
	")"
	"selinux? ("
		"sys-libs/libselinux"
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"selinux? ( sec-policy/selinux-smartmon )"
)

inherit arrays

S+="/${PN}"

src_prepare() {
	default

	eautoreconf
}

MY_DB_PATH="/var/db/${PN}"

src_configure() {
	use static && append-ldflags -static

	local myeconfargs=(
		--docdir="${EPREFIX}/usr/share/doc/${PF}"
		--with-smartdscriptdir="${EPREFIX}/usr/libexec/${PN}"
		--with-scriptpath="${EPREFIX}/usr/libexec/${PN}"
		--with-smartdplugindir="${EPREFIX}/usr/libexec/${PN}"
		--with-drivedbdir="${EPREFIX}${MY_DB_PATH}" # gentoo#575292
		--without-initscriptdir
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)"

		$(use_with caps libcap-ng)
		$(use_with selinux)
		--without-update-smart-drivedb
		$(use_with gnupg)

		# --with-savestates
		# --with-attributelog
		$(use_with nvme nvme-devicescan)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	insinto "${MY_DB_PATH}"
	newins "${FILESDIR}/20171118-drivedb.h" "drivedb.h"

	use examples || erm -r "${ED}"/usr/share/doc/${PF}/example*
}
