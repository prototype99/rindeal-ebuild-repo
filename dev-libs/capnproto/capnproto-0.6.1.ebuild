# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake-utils

DESCRIPTION="Serialization/RPC system - core tools and C++ library"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( test )

CDEPEND_A=( )
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

S_OLD="${S}"
S+="/c++" # not needed in 0.7.x

src_configure() {
	local mycmakeargs=(
		-D BUILD_TESTING=$(usex test)
		-D EXTERNAL_CAPNP=OFF
		-D CAPNP_LITE=OFF
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	cd "${S_OLD}"
	einstalldocs
}
