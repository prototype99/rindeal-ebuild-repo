# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# git-hosting.eclass:
GH_RN="github:apache"
GH_REF="${PN}-${PV}"

# java-pkg-simple.eclass:
JAVA_SRC_DIR="src/main/java"

# EXPORT_FUNCTIONS: pkg_setup src_prepare src_compile pkg_preinst
inherit java-pkg-2
# EXPORT_FUNCTIONS: src_compile src_install
inherit java-pkg-simple
# NOTE: java-pkg-2 overrides SRC_URI, so git-hosting must be inherited after it
# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

DESCRIPTION="Simple encoder and decoders for various formats such as Base64 and Hexadecimal"
LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jdk-1.8"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jre-1.8"
)

inherit arrays

S="${WORKDIR}/${P}"

src_prepare() {
	default

	java-pkg-2_src_prepare
}

src_install() {
	java-pkg-simple_src_install

	dodoc README.md RELEASE-NOTES.txt
}
