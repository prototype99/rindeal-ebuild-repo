# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="bitbucket:tildeslash"
GH_REF="release-${PV//./-}"

## EXPORT_FUNCTIONS: src_unpack
## variables: GH_HOMEPAGE
inherit git-hosting
## functions: eautoreconf
inherit autotools
## functions: newpamd
inherit pam
## functions: systemd_dounit
inherit systemd

DESCRIPTION="Utility for monitoring and managing daemons or similar programs"
HOMEPAGE="https://mmonit.com/monit/ ${GH_HOMEPAGE}"
LICENSE="AGPL-3"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="pam ssl"

CDEPEND_A=(
	"ssl? ( dev-libs/openssl:0= )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"sys-devel/flex"
	"sys-devel/bison"
	"pam? ( virtual/pam )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_prepare() {
	eapply_user

	eautoreconf
}

src_configure() {
	local econf_args=(
		$(use_with ssl)
		$(use_with pam)
	)
	econf "${econf_args[@]}"
}

src_install() {
	default

	# default config file
	insinto /etc
	insopts -m600
	doins monitrc

	systemd_dounit "${FILESDIR}"/${PN}.service

	use pam && newpamd "${FILESDIR}"/${PN}.pamd ${PN}
}
