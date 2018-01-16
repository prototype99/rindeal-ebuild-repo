# Copyright 1999-2017 Gentoo Foundation
# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="gitlab:mbunkus"
GH_REF="release-${PV}"

## EXPORT_FUNCTIONS: src_unpack
## variables: GH_HOMEPAGE
inherit git-hosting
## functions: makeopts_jobs
inherit multiprocessing
## functions: eautoreconf
inherit autotools

DESCRIPTION="Tools to create, alter, and inspect Matroska files"
HOMEPAGE="https://mkvtoolnix.download/ ${GH_HOMEPAGE}"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64"
IUSE_A=( debug +pch test +gui flac magic nls +tools )

# check NEWS.md for build system changes entries for boost/libebml/libmatroska
# version requirement updates and other packaging info
CDEPEND_A=(
	">=dev-libs/boost-1.49.0:="
	">=dev-libs/libebml-1.3.5:="
	"dev-libs/jsoncpp:="
	"dev-libs/pugixml"
	"flac? ( media-libs/flac )"
	">=media-libs/libmatroska-1.4.8:="
	"media-libs/libogg"
	"media-libs/libvorbis"
	"magic? ( sys-apps/file )"
	"sys-libs/zlib"
	"gui? ("
		"dev-qt/qtcore:5"
		"dev-qt/qtgui:5"
		"dev-qt/qtnetwork:5"
		"dev-qt/qtwidgets:5"
		"dev-qt/qtconcurrent:5"
		"dev-qt/qtmultimedia:5"
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-ruby/rake"
	"nls? ("
		"sys-devel/gettext"
		"app-text/po4a"
	")"
	"virtual/pkgconfig"
	"dev-libs/libxslt"
	"app-text/docbook-xsl-stylesheets"

	"test? ( dev-cpp/gtest )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

L10N_LOCALES=( ca cs de es eu fr it ja ko lt nl pl pt pt_BR ro ru sr_RS sr_RS@latin sv tr uk zh_CN zh_TW )
inherit l10n-r1

my_rake() {
	rake V=1 -j$(makeopts_jobs) "${@}" || die
}

src_prepare-locales() {
	local l locales dir="po" pre="" post=".po"

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	l10n_get_locales locales app off
	for l in ${locales} ; do
		erm "${dir}/${pre}${l}${post}"
		erm -f "doc/man/po4a/po/${pre}${l}${post}"
	done
}

src_prepare() {
	default

	src_prepare-locales

	touch config.sub || die

	eautoreconf
}

src_configure() {
	local myconf=(
		--disable-update-check
		--disable-appimage
		$(use_enable debug)
		--disable-profiling
		--disable-optimization
# 		--disable-addrsan # https://gitlab.com/mbunkus/mkvtoolnix/issues/2199
# 		--disable-ubsan # https://gitlab.com/mbunkus/mkvtoolnix/issues/2199
		$(usex pch "" --disable-precompiled-headers)
		--disable-static

		$(use_enable gui qt)
		--disable-static-qt
		$(use_enable magic)

		$(use_with flac)
		--with-qt-pkg-config
		$(use_with nls gettext)

		--docdir="${EPREFIX}/usr/share/doc/${PF}"

		--with-boost="${EROOT}usr"
		--with-boost-libdir="${EROOT}usr/$(get_libdir)"

		$(use_with tools)
	)

	if use gui ; then
		# ac/qt5.m4 finds default Qt version set by qtchooser, bug #532600
		myconf+=(
			--with-moc="${EROOT}usr/$(get_libdir)/qt5/bin/moc"
			--with-uic="${EROOT}usr/$(get_libdir)/qt5/bin/uic"
			--with-rcc="${EROOT}usr/$(get_libdir)/qt5/bin/rcc"
			--with-qmake="${EROOT}usr/$(get_libdir)/qt5/bin/qmake"
		)
	fi

	econf "${myconf[@]}"
}

src_compile() {
	my_rake
}

src_test() {
	my_rake tests:unit
	my_rake tests:run_unit
}

src_install() {
	DESTDIR="${D}" my_rake install

	einstalldocs
	doman doc/man/*.1
}
