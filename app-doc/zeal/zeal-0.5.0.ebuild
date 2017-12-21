# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass
GH_RN="github:zealdocs"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake-utils
## EXPORT_FUNCTIONS: src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg

DESCRIPTION="Offline documentation browser inspired by Dash"
HOMEPAGE="https://zealdocs.org/ ${GH_HOMEPAGE}"
LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~amd64"
IUSE_A=()

CDEPEND_A=(
	## src/app/CMakeLists.txt:
	##   - `find_package(Qt5Core REQUIRED)`
	##   - `find_package(Qt5 COMPONENTS Widgets REQUIRED)`
	"dev-qt/qtcore:5"
	"dev-qt/qtwidgets:5"

	## src/libs/core/CMakeLists.txt:
	##   - `find_package(Qt5 COMPONENTS Network WebKit Widgets REQUIRED)`
	##   - `find_package(LibArchive REQUIRED)`
	"dev-qt/qtnetwork:5"
	"dev-qt/qtwebkit:5"
	"dev-qt/qtwidgets:5"
	"app-arch/libarchive"

	## src/libs/registry/CMakeLists.txt:
	##   - `find_package(Qt5 COMPONENTS Concurrent Gui Network REQUIRED)`
	"dev-qt/qtconcurrent:5"
	"dev-qt/qtgui:5"
	"dev-qt/qtnetwork:5"

	## src/libs/ui/CMakeLists.txt:
	##   - `find_package(Qt5 COMPONENTS WebKitWidgets REQUIRED)`
	"dev-qt/qtwebkit:5"

	## src/libs/ui/qxtglobalshortcut/CMakeLists.txt:
	##   - `find_package(X11)`
	##   - `find_package(Qt5Gui REQUIRED)`
	##   - `find_package(Qt5 COMPONENTS X11Extras REQUIRED)`
	##   - `find_package(XCB COMPONENTS XCB KEYSYMS REQUIRED)`
	"x11-libs/libX11"
	"dev-qt/qtgui:5"
	"dev-qt/qtx11extras:5"
	"x11-libs/libxcb"
	"x11-libs/xcb-util-keysyms"

	## src/libs/util/CMakeLists.txt:
	##   - `find_package(Qt5Core REQUIRED)`
	##   - `find_package(SQLite REQUIRED)`
	"dev-qt/qtcore:5"
	"dev-db/sqlite:3"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"kde-frameworks/extra-cmake-modules"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"x11-themes/hicolor-icon-theme"
)

src_prepare() {
	xdg_src_prepare
	cmake-utils_src_prepare
}
