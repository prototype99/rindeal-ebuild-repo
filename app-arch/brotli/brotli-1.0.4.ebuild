# Copyright 1999-2018 Gentoo Foundation
# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:google"
GH_REF="v${PV}"

## python-*.eclass:
PYTHON_COMPAT=( python2_7 python3_{4,5,6} pypy )

## distutils-r1.eclass:
DISTUTILS_OPTIONAL="1"

# TODO: add jni wrapper support
# java-pkg-simple.eclass:
JAVA_SRC_DIR="java"

## functions: ver_cut
inherit eapi7-ver
# EXPORT_FUNCTIONS: pkg_setup src_prepare src_compile pkg_preinst
inherit java-pkg-2
## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake-utils
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit distutils-r1
# EXPORT_FUNCTIONS: src_compile src_install
inherit java-pkg-simple

DESCRIPTION="Generic-purpose lossless compression algorithm"
HOMEPAGE="https://github.com/google/brotli"
LICENSE="MIT python? ( Apache-2.0 )"

SLOT="0/$(ver_cut 1)"

KEYWORDS="~amd64 ~arm ~arm64"

CDEPEND_A=(
	"python? ( ${PYTHON_DEPS} )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"java? ( >=virtual/jdk-1.7 )"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"java? ( >=virtual/jre-1.7 )"
)

RDEPEND=""
DEPEND="${RDEPEND}"

IUSE_A=( python java )
REQUIRED_USE_A=(
	"python? ( ${PYTHON_REQUIRED_USE} )"
)

inherit arrays

S="${WORKDIR}/${P}" # restore original value which was overriden by java-pkg-simple.eclass

pkg_setup() {
	use java && java-pkg-2_pkg_setup
}

src_prepare() {
	eapply_user

	cmake-utils_src_prepare

	use python && distutils-r1_src_prepare
	if use java ; then
		find "${JAVA_SRC_DIR}" -name "*Test.java" -print -delete || die

		java-pkg-2_src_prepare
	fi
}

src_configure() {
	local mycmakeargs=(
		-D ENABLE_SANITIZER=no
		-D BROTLI_DISABLE_TESTS=yes
	)
	cmake-utils_src_configure

	use python && distutils-r1_src_configure
}

src_compile() {
	cmake-utils_src_compile

	use python && distutils-r1_src_compile
	use java && java-pkg-simple_src_compile
}

python_test(){
	esetup.py test || die
}

src_install() {
	local DOCS=( README.md CONTRIBUTING.md )

	cmake-utils_src_install

	use python && distutils-r1_src_install
	use java && java-pkg-simple_src_install
}

pkg_preinst() {
	use java && java-pkg-2_pkg_preinst
}
