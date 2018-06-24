# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:jboss-javassist"
GH_REF="rel_${PV//./_}_ga"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## EXPORT_FUNCTIONS: pkg_setup src_prepare src_compile pkg_preinst
inherit java-pkg-2

## EXPORT_FUNCTIONS: src_compile src_install
inherit java-pkg-simple

DESCRIPTION="Java bytecode engineering toolkit"
LICENSE="MPL-1.1"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CP_DEPEND_A=(
)
CDEPEND_A=(
	"${CP_DEPEND}"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jdk-1.7"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jre-1.7"
)

REQUIRED_USE_A=(  )

JAVA_SRC_DIR_A=(
	"src/main"
)

inherit arrays

# revert java-pkg-simple.eclass's override
S="${WORKDIR}/${P}"

pkg_setup() {
	JAVA_GENTOO_CLASSPATH_EXTRA="$(java-config-2 --tools)"

	java-pkg-2_pkg_setup
}

src_prepare() {
	eapply_user

	java-pkg-2_src_prepare
}

src_compile() {
	java-pkg-simple_src_compile
}

src_install() {
	java-pkg-simple_src_install

	einstalldocs
}
