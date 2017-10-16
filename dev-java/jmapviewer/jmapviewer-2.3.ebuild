# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# java-pkg-2.eclass:
EANT_BUILD_TARGET="build pack"

# EXPORT_FUNCTIONS: pkg_setup src_prepare src_compile pkg_preinst
inherit java-pkg-2
# EXPORT_FUNCTIONS: src_configure
inherit java-ant-2

DESCRIPTION="Java OpenStreetMap Tile Viewer"
HOMEPAGE="https://wiki.openstreetmap.org/wiki/JMapViewer"
LICENSE="GPL-2"

SLOT="0"
SRC_URI="mirror://debian/pool/main/${PN:0:1}/${PN}/${PN}_${PV}+dfsg.orig.tar.gz"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jdk-1.8"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jre-1.8"
)

RESTRICT+=" mirror"

inherit arrays

src_prepare() {
	default

	java-pkg-2_src_prepare

	# required for ant build task
	emkdir bin
}

src_install() {
	java-pkg_dojar JMapViewer.jar
}
