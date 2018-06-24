# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:apache"
GH_REF="rel/${PV}"

# java-pkg-simple.eclass:
JAVA_SRC_DIR="src/main/java"

## EXPORT_FUNCTIONS: pkg_setup src_prepare src_compile pkg_preinst
inherit java-pkg-2

## EXPORT_FUNCTIONS: src_compile src_install
## variables: S
inherit java-pkg-simple

## EXPORT_FUNCTIONS: src_unpack
## variables: SRC_URI, HOMEPAGE
inherit git-hosting

DESCRIPTION="API for working with compression and archive formats"
LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CP_DEPEND_A=(
	"dev-java/xz-java:0"
	"dev-java/zstd-jni:0"
	"app-arch/brotli:0[java]"
)

CDEPEND_A=(
	"${CP_DEPEND_A[@]}"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jdk-1.7"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jre-1.7"
)

## java-pkg-simple.eclass:
JAVA_SRC_DIR_A=(
	"src/main/java"
)

inherit arrays

# revert java-pkg-simple.eclass's override
S="${WORKDIR}/${P}"

src_compile() {
	java-pkg-simple_src_compile
}

src_install() {
	java-pkg-simple_src_install

	dodoc README.md RELEASE-NOTES.txt
}
