# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="bitbucket:jeromerobert:k4dirstat"
GH_REF="k4dirstat-${PV}"
## kde5.eclass:
KDE_HANDBOOK="forceoptional"

inherit git-hosting
inherit kde5

DESCRIPTION="Nice KDE replacement to the du command"
LICENSE="GPL-2"

KEYWORDS="~amd64"
IUSE=""

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
	"sys-devel/gettext"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"!kde-misc/kdirstat"
	"!kde-misc/k4dirstat:4"
)

inherit arrays
