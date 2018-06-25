# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:jgettext"
GH_REF="gettext-commons-${PV//./_}"

## EXPORT_FUNCTIONS: pkg_setup src_prepare src_compile pkg_preinst
inherit java-pkg-2

## EXPORT_FUNCTIONS: src_compile src_install
## variables: S
inherit java-pkg-simple

## EXPORT_FUNCTIONS: src_unpack
## variables: SRC_URI, HOMEPAGE
inherit git-hosting


DESCRIPTION="Internationalization (i18n) through GNU gettext and Java ResourceBundles"
LICENSE="LGPL-2.1"

SLOT="0"

KEYWORDS="amd64 arm arm64"
IUSE_A=( )

## java-utils-2.eclass:
CP_DEPEND_A=(
)

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jdk-1.7"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jre-1.7"
)

## java-pkg-2.eclass:
JAVA_SRC_DIR_A=( "src/java" )

inherit arrays

S="${WORKDIR}/${P}"

src_compile() {
	java-pkg-simple_src_compile
}

src_install() {
	java-pkg-simple_src_install

	einstalldocs
}
