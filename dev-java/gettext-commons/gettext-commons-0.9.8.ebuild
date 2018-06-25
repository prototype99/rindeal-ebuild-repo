# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# git-hosting.eclass:
GH_RN="github:jgettext"
GH_REF="gettext-commons-${PV//./_}"
# java-pkg-2.eclass:
JAVA_SRC_DIR="src/java"

# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
# EXPORT_FUNCTIONS: pkg_setup src_prepare src_compile pkg_preinst
inherit java-pkg-2
# EXPORT_FUNCTIONS: src_compile src_install
inherit java-pkg-simple

DESCRIPTION="Internationalization (i18n) through GNU gettext and Java ResourceBundles"
LICENSE="LGPL-2.1"

SLOT="0"

KEYWORDS="amd64 arm arm64"
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

src_prepare() {
	default

	java-pkg-2_src_prepare
}

src_compile() {
	java-pkg-simple_src_compile
}

src_install() {
	java-pkg-simple_src_install

	dodoc README ChangeLog
}
