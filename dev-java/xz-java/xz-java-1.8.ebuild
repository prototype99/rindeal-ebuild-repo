# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## EXPORT_FUNCTIONS: pkg_setup src_prepare src_compile pkg_preinst
inherit java-pkg-2

## EXPORT_FUNCTIONS: src_compile src_install
inherit java-pkg-simple

DESCRIPTION="Complete implementation of XZ data compression in pure Java"
HOMEPAGE="https://tukaani.org/xz/java.html"
LICENSE="public-domain"

SLOT="0"
SRC_URI="https://tukaani.org/xz/${P}.zip"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CP_DEPEND_A=()

CDEPEND_A=(
	"${CP_DEPEND[@]}"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jdk-1.6"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jre-1.6"
)

REQUIRED_USE_A=(  )

JAVA_SRC_DIR_A=(
	"src"
)

inherit arrays

pkg_setup() {
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
