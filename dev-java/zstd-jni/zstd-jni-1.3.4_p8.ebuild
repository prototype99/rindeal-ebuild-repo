# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# java-pkg-simple.eclass:
JAVA_SRC_DIR="src/main/java"

## git-hosting.eclass:
GH_RN="github:luben"
GH_REF="1c07183"  # 1.3.4-8; 2018-06-01

# EXPORT_FUNCTIONS: pkg_setup src_prepare src_compile pkg_preinst
inherit java-pkg-2
# EXPORT_FUNCTIONS: src_compile src_install
inherit java-pkg-simple
## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS src_prepare src_configure src_compile src_test src_install
inherit cmake-utils

DESCRIPTION="Simple encoder and decoders for various formats such as Base64 and Hexadecimal"
LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jdk-1.7"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jre-1.7"
)

inherit arrays

S="${WORKDIR}/${P}"

CMAKE_USE_DIR="${S}/src/main/native"

src_prepare() {
	eapply_user

	esed -e "s,DESTINATION lib),DESTINATION $(get_libdir))," -i -- "${CMAKE_USE_DIR}/CMakeLists.txt"

	java-pkg-2_src_prepare
	cmake-utils_src_prepare
}

src_configure() {
	cmake-utils_src_configure
}

src_compile() {
	java-pkg-simple_src_compile
	cmake-utils_src_compile
}

src_install() {
	java-pkg-simple_src_install
	cmake-utils_src_install

	dodoc README.md
}
