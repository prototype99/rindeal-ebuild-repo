# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="bitbucket:jeromerobert"
GH_REF="${P}"
## kde5.eclass:
KDE_HANDBOOK="forceoptional"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: pkg_setup pkg_nofetch src_unpack src_prepare src_configure src_compile src_test src_install pkg_preinst pkg_postinst pkg_postrm
inherit kde5

DESCRIPTION="Nice KDE replacement to the du command"
LICENSE="GPL-2"

KEYWORDS="~amd64"
IUSE_A=( nls )

CDEPEND_A=(
	"$(add_frameworks_dep kconfig)"
	"$(add_frameworks_dep kconfigwidgets)"
	"$(add_frameworks_dep kcoreaddons)"
	"$(add_frameworks_dep kdelibs4support)"
	"$(add_frameworks_dep ki18n)"
	"$(add_frameworks_dep kiconthemes)"
	"$(add_frameworks_dep kio)"
	"$(add_frameworks_dep kjobwidgets)"
	"$(add_frameworks_dep kwidgetsaddons)"
	"$(add_frameworks_dep kxmlgui)"
	"$(add_qt_dep qtgui)"
	"$(add_qt_dep qtwidgets)"
	"sys-libs/zlib"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"nls? ( sys-devel/gettext )"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"!kde-misc/kdirstat"
	"!kde-misc/k4dirstat:4"
)

inherit arrays

src_unpack() {
	git-hosting_src_unpack
}

src_prepare() {
	eapply_user

	if ! use nls ; then
		esed -e '/add_subdirectory( *po *)/d' -i -- CMakeLists.txt
	fi

	kde5_src_prepare
}
