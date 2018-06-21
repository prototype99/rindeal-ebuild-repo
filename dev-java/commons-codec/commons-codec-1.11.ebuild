# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# java-pkg-simple.eclass:
JAVA_SRC_DIR="src/main/java"

# EXPORT_FUNCTIONS: pkg_setup src_prepare src_compile pkg_preinst
inherit java-pkg-2
# EXPORT_FUNCTIONS: src_compile src_install
inherit java-pkg-simple

DESCRIPTION="Simple encoder and decoders for various formats such as Base64 and Hexadecimal"
LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jdk-1.6"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jre-1.6"
)

inherit arrays

S="${WORKDIR}/${P}-src"

src_compile() {
	java-pkg-simple_src_compile
}

src_install() {
	java-pkg-simple_src_install

	dodoc RELEASE-NOTES.txt
}
