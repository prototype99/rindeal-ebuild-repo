# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## EXPORT_FUNCTIONS: src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg
## functions: append-cxxflags
inherit flag-o-matic
## functions: qt5_get_bindir
inherit qmake-utils
## functions: eautoreconf
inherit autotools
## functions: prune_libtool_files
inherit ltprune

DESCRIPTION="Simple v4l2 full-featured video grabber"
HOMEPAGE="http://guvcview.sourceforge.net/"
LICENSE="GPL-3"

SLOT="0"
MY_P="${PN}-src-${PV}"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"

KEYWORDS="~amd64"
IUSE_A=( builtin-mjpg gsl nls pulseaudio qt5 +sdl2 )

CDEPEND_A=(
	"media-libs/libpng:0="
	"media-libs/libv4l"
	">=media-libs/portaudio-19_pre"
	">=media-video/ffmpeg-2.8:0="
	"virtual/libusb:1"
	"virtual/udev"

	"gsl? ( >=sci-libs/gsl-1.15 )"
	"qt5? ( dev-qt/qtwidgets:5 )"
	"!qt5? ("
		">=x11-libs/gtk+-3.6:3"
		">=dev-libs/glib-2.10"
	")"
	"pulseaudio? ( >=media-sound/pulseaudio-0.9.15 )"
	"sdl2? ( media-libs/libsdl2 )"
	"!sdl2? ( >=media-libs/libsdl-1.2.10 )"

	"!<sys-kernel/linux-headers-3.4-r2" #448260
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-util/intltool"
	"sys-devel/gettext"
	"virtual/os-headers"
	"sys-devel/autoconf-archive"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

S="${WORKDIR}/${MY_P}"

L10N_LOCALES=( bg bs cs da de en_AU es eu fo fr gl he hr it ja lv nl pl pt pt_BR ru si sr tr uk zh_TW )
inherit l10n-r1

pkg_setup() {
	# required for compilation with newer Qt
	append-cxxflags -std=gnu++11

	export MOC="$(qt5_get_bindir)/moc"
}

src_prepare-locales() {
	local l locales dir="po" pre="" post=".po"

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	l10n_get_locales locales app off
	for l in ${locales} ; do
		erm "${dir}/${pre}${l}${post}"
		esed -e "/^ALL_LINGUAS/ s|${l}||" -i -- configure.ac
	done
}

src_prepare() {
	eapply_user

	xdg_src_prepare

	src_prepare-locales

	# do not make some compiler prefered over another and let user make the choice
	esed -r -e 's:^AC_PROG_(CC|CXX).*:AC_PROG_\1:' -i -- configure.ac

	esed -e '/^docdir/,/^$/d' -i -- Makefile.am

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--disable-debian-menu
		--disable-static
		$(use_enable builtin-mjpg)
		$(use_enable gsl)
		$(use_enable nls)
		$(use_enable pulseaudio pulse)
		$(use_enable qt5)
		$(use_enable !qt5 gtk3)
		$(use_enable sdl2)
	)

	econf "${myeconfargs[@]}"
}

src_install() {
	default

	prune_libtool_files
}
