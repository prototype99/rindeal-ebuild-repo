# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass
# GH_RN="github:Motion-Project"
# fork is required for Meson to work, upstream autotools-based system is crap, but YMMV
GH_RN="github:rindeal"
[[ "${PV}" == *9999* ]] || \
	GH_REF="release-${PV}"

## functions: eshopts_push, eshopts_pop
inherit estack
## EXPORT_FUNCTIONS: src_unpack
## variables: GH_HOMEPAGE
inherit git-hosting
## functions: readme.gentoo_create_doc, readme.gentoo_print_elog
inherit readme.gentoo-r1
## functions: enewuser
inherit user
## functions: systemd_dounit, systemd_dotmpfilesd
inherit systemd
## functions: eautoreconf
inherit autotools
## EXPORT_FUNCTIONS: src_configure src_compile src_test src_install
inherit meson

DESCRIPTION="A software motion detector"
HOMEPAGE="https://motion-project.github.io https://github.com/Motion-Project/motion ${GH_HOMEPAGE}"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( ffmpeg mmal mysql pgsql +v4l2 webp sqlite3 )

CDEPEND_A=(
	"ffmpeg? ("
		"media-video/ffmpeg:0="
	")"
	"virtual/jpeg:="
	"mmal? ( media-libs/raspberrypi-userland )"
	"mysql? ( virtual/mysql )"
	"pgsql? ( dev-db/postgresql:= )"
	"webp? ( media-libs/libwebp )"
	"sqlite3? ( dev-db/sqlite:3 )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	">dev-util/meson-0.42.1" # older versions have serious bugs preventing successful compilation
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

DISABLE_AUTOFORMATTING="yes"
DOC_CONTENTS="
You need to setup /etc/${PN}/${PN}.conf before running ${PN} for
the first time. You can use /etc/${PN}/${PN}-dist.conf as a template.
Please note that the 'daemon' and 'process_id_file' settings are
overridden by the bundled OpenRC init script and systemd unit where
appropriate.

To install ${PN} as a service, use:
rc-update add ${PN} default # with OpenRC
systemctl enable ${PN}.service # with systemd
"

pkg_setup() {
	enewuser ${PN} -1 -1 -1 video
}

src_prepare() {
	default

	# this is needed in order to generate `config.h.in` file
	eautoreconf
}

src_configure() {
	function usexb() {
		usex $1 'true' 'false'
	}

	local emesonargs=(
		-D WITH_WITH_MMAL=$(usexb mmal)
		-D WITH_V4L2=$(usexb v4l2)

		-D WITH_FFMPEG=$(usexb ffmpeg)
		-D WITH_WEBP=$(usexb webp)

		-D WITH_MYSQL=$(usexb mysql)
		-D WITH_PGSQL=$(usexb pgsql)
		-D WITH_SQLITE3=$(usexb sqlite3)
	)
	meson_src_configure
}

src_install() {
	meson_src_install

	# meson doesn't know about docdir; https://github.com/mesonbuild/meson/issues/825
	emv "${ED%/}"/usr/share/doc/{${PN}/*,${PF}}
	rmdir "${ED%/}"/usr/share/doc/${PN} || die

	epushd "${ED}/usr/share/doc/${PF}"
	erm examples/*FreeBSD*
	epopd

	# TODO: remove
	newinitd "${FILESDIR}"/${PN}.initd-r3 ${PN}
	newconfd "${FILESDIR}"/${PN}.confd-r1 ${PN}

	systemd_dounit "${FILESDIR}"/${PN}.service
	systemd_dounit "${FILESDIR}"/${PN}_at.service
	systemd_dotmpfilesd "${FILESDIR}"/${PN}.conf

	keepdir /var/lib/motion
	fowners motion:video /var/lib/motion
	fperms 0750 /var/lib/motion

	readme.gentoo_create_doc
	readme.gentoo_print_elog
}
