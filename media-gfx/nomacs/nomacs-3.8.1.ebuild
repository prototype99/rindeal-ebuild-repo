# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github"
## cmake-utils.eclass:
# ninja build fails at parsing stage with message:
# `ninja: error: build.ninja:845: bad $-escape (literal $ must be written as $$)`
# which complains because of `$(CONFIGURATION)` not being expanded beforehand
CMAKE_MAKEFILE_GENERATOR="emake"

## functions: rindeal:dsf:prefix_flags
inherit rindeal-utils
## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake-utils
## EXPORT_FUNCTIONS: src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg

DESCRIPTION="Qt-based image viewer"
HOMEPAGE="https://www.nomacs.org/ ${GH_HOMEPAGE}"
LICENSE="GPL-3+"

SLOT="0"
git-hosting_gen_snapshot_url "github:${PN}:${PN}-plugins" "${GH_REF}" plugins_snap_url plugins_distfile
SRC_URI+="
	plugins? ( ${plugins_snap_url} -> ${plugins_distfile} )"

KEYWORDS="~amd64"
IUSE_A=( debug opencv +plugins raw tiff zip nls
	$(rindeal:dsf:prefix_flags \
		plugins_ \
			+fake_miniatures \
			nikon \
			+affine_transformation \
			+paint \
			page_extraction \
			ocr \
			simple \
			instagram_filter \
			filter \
			instagram_like_filter \
			insta_like_filter \
			mars \
			patch_matching \
			image_stitching \
			ruler_detetection
	)
)

CDEPEND_A=(
	# qt deps specified in '${S}/cmake/Utils.cmake'
	"dev-qt/qtconcurrent:5"
	"dev-qt/qtcore:5"
	"dev-qt/qtgui:5"
	"dev-qt/qtnetwork:5"
	"dev-qt/qtprintsupport:5"
	"dev-qt/qtsvg:5"
	"dev-qt/qtwidgets:5"

	">=media-gfx/exiv2-0.25:="

	"opencv? ( >=media-libs/opencv-2.4.6:=[qt5(+)] )"
	"raw? ( >=media-libs/libraw-0.17.0:= )"
	"tiff? ("
		"media-libs/tiff:0"
		# https://bugs.gentoo.org/630764
		"dev-qt/qtimageformats:5"
	")"
	"zip? ( dev-libs/quazip[qt5(+)] )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-qt/linguist-tools:5"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"raw? ( opencv )"
	"tiff? ( opencv )"
)

inherit arrays

L10N_LOCALES=( ar ru uk nl de az hr es en ko fr bg sk pt sl zh cs bs sr pl als ja it )
inherit l10n-r1

S_OLD="${S}"
S="${S}/ImageLounge"

src_unpack() {
	git-hosting_src_unpack
	default

	[[ -d "${S}"/plugins ]] && die
	emv "${WORKDIR}"/*plugins* "${S}/plugins"
}

src_prepare-locales() {
	local l locales dir='translations' pre="${PN}_" post='.ts'

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	l10n_get_locales locales app off
	for l in ${locales} ; do
		erm "${dir}/${pre}${l}${post}"
	done
}

src_prepare() {
	cd "${S_OLD}"
	eapply_user
	cd "${S}"

	# prevent these from interfering with the build
	NO_V=1 erm -r "${S_OLD}"/{exiv2-*,expat,installer,zlib-*}
	NO_V=1 erm -r "${S}"/3rdparty/quazip-*

	esed -e 's|QStringList libPaths = QCoreApplication::libraryPaths();|QStringList libPaths;|' \
		-e "s|libPaths.append(QCoreApplication::applicationDirPath() + \"/plugins\");|libPaths.append(\"${EPREFIX}/usr/$(get_libdir)/nomacs-plugins\");|" \
		-i -- src/DkCore/DkPluginManager.cpp

	if use plugins ; then
		esed -e "s|DESTINATION lib/nomacs-plugins|DESTINATION $(get_libdir)/nomacs-plugins|" \
			-i -- plugins/cmake/Utils.cmake
	fi

	src_prepare-locales

	xdg_src_prepare
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-D USE_SYSTEM_QUAZIP=ON
		# this app uses patched libqpsd + libqpsd is not in the tree
		# -D USE_SYSTEM_LIBQPSD=ON

		-D ENABLE_OPENCV=$(usex opencv)
		-D ENABLE_RAW=$(usex raw)
		-D ENABLE_TIFF=$(usex tiff)
		-D ENABLE_QT_DEBUG=$(usex debug)
# 		-D ENABLE_INCREMENTER
		-D ENABLE_READ_BUILD=OFF
		-D ENABLE_TRANSLATIONS=$(use nls)
		-D ENABLE_PLUGINS=$(usex plugins)
		-D ENABLE_CODE_COV=OFF

		# upnp support requires:
		# 	- fork herqq to a github/gitlab repo / use hupnp-ng
		# 		- because HUpnpAV is currently only in original SVN repo
		# 	- create a new herqq package which would use that fork/*-ng
		# 	- patch build system to use upnp on linux (-DWITH_UPNP)
		# 	- test everything works as probably no one used nomacs with upnp before
		#-D ENABLE_UPNP=$(usex upnp)
		-D ENABLE_QUAZIP=$(usex zip)

		### Plugins:
		-D ENABLE_FAKE_MINIATURES=$(usex plugins_fake_miniatures)
		-D ENABLE_NIKON=$(usex plugins_nikon)
		-D ENABLE_TRANSFORM=$(usex plugins_affine_transformation)
		-D ENABLE_PAINT=$(usex plugins_paint)
		# windows only plugin
# 		-D ENABLE_DOC=$(usex plugins_doc_analysis)
		-D ENABLE_PAGE=$(usex plugins_page_extraction)
		-D ENABLE_OCR=$(usex plugins_ocr)
		-D ENABLE_SIMPLE=$(usex plugins_simple)
		-D ENABLE_INSTAGRAM=$(usex plugins_instagram_filter)
		-D ENABLE_FILTER=$(usex plugins_filter)
		-D ENABLE_INSTAGRAM_FILTER=$(usex plugins_instagram_like_filter)
		-D ENABLE_INSTA_LIKE_FILTER=$(usex plugins_insta_like_filter)
		-D ENABLE_MARS=$(usex plugins_mars)
		-D ENABLE_PATCHMATCHING=$(usex plugins_patch_matching)
		-D ENABLE_IMAGESTITCHING=$(usex plugins_image_stitching)
		-D ENABLE_RULERDETECTION=$(usex plugins_ruler_detetection)
	)
	cmake-utils_src_configure
}
