# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:clangen"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare, pkg_preinst, pkg_postinst, pkg_postrm
# inherit xdg
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake-utils
## functions: prune_libtool_files
# inherit eutils
## functions: rindeal:dsf:eval, rindeal:dsf:prefix_flags
# inherit rindeal-utils

DESCRIPTION="Cross-platform, terminal-based music player, audio engine, metadata indexer, and server in c++"
HOMEPAGE="https://musikcube.com/ ${GH_HOMEPAGE}"
LICENSE="BSD-3"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"

IUSE_A=( )

CDEPEND_A=( )
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=( )
RESTRICT+=""

inherit arrays

src_prepare() {
	eapply_user

	NO_V=1 erm -r src/3rdparty
	find -\( -name "*.vcproj*" -o -name "*.vcxproj*"  -o -name "*.sln*" -\) -delete || die

	sed -e "\|/3rdparty/| s|^|# |" \
		-i -- CMakeLists.txt src/plugins/server/CMakeLists.txt src/glue/CMakeLists.txt src/core/CMakeLists.txt || die

	cmake-utils_src_prepare
}
