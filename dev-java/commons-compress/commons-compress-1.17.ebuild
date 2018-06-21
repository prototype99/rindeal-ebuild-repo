# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# java-pkg-simple.eclass:
JAVA_SRC_DIR="src/main/java"

# EXPORT_FUNCTIONS: pkg_setup src_prepare src_compile pkg_preinst
inherit java-pkg-2
# EXPORT_FUNCTIONS: src_compile src_install
inherit java-pkg-simple

DESCRIPTION="API for working with compression and archive formats"
LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CP_DEPEND="
	dev-java/xz-java:0
	dev-java/zstd-jni:0
	app-arch/brotli:0[java]
"

CDEPEND_A=(
	"${CP_DEPEND}"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jdk-1.7"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jre-1.7"
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
