# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:apache"
GH_REF="${P}"

## EXPORT_FUNCTIONS: pkg_setup src_prepare src_compile pkg_preinst
inherit java-pkg-2

## EXPORT_FUNCTIONS: src_compile src_install
## variables: S
inherit java-pkg-simple

## EXPORT_FUNCTIONS: src_unpack
## variables: SRC_URI, HOMEPAGE
inherit git-hosting

DESCRIPTION="Simple encoder and decoders for various formats such as Base64 and Hexadecimal"
LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="amd64 arm arm64"
IUSE_A=( )

## java-utils-2.eclass:
CP_DEPEND_A=(
)

CDEPEND_A=( "${CP_DEPEND_A[@]}" )
DEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jdk-1.6"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jre-1.6"
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
