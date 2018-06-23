# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:mttkay"
GH_REF="550c876167fe69671155138e3140fd1ee6419f16"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: pkg_setup src_prepare src_compile pkg_preinst
inherit java-pkg-2
## EXPORT_FUNCTIONS: src_compile src_install
inherit java-pkg-simple

DESCRIPTION="Light-weight client-side OAuth library for Java"
LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CP_DEPEND="
	dev-java/commons-httpclient:3
	dev-java/commons-codec:0
"

CDEPEND_A=(
	"${CP_DEPEND}"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jdk-1.8"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jre-1.8"
)

REQUIRED_USE_A=(  )
RESTRICT+=" mirror"

inherit arrays

S="${WORKDIR}/${P}"
JAVA_SRC_DIR="
	signpost-commonshttp3/src/main/java
	signpost-core/src/main/java
"
# TODO:
#   - dev-java/commons-codec
#   - signpost-commonshttp4/src/main/java

src_prepare() {
	default

	java-pkg-2_src_prepare
}

src_install() {
	java-pkg-simple_src_install

	dodoc README.md
}
