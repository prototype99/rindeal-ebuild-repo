# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

PYTHON_COMPAT=( python2_7 )

## git-hosting.eclass:
GH_RN="github"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake-utils
## variables: PYTHON_REQ_USE, PYTHON_DEPS
## EXPORT_FUNCTIONS: pkg_setup
inherit python-single-r1

DESCRIPTION="Protocol Buffers with small code size"
HOMEPAGE="${GH_HOMEPAGE} https://jpa.kapsi.fi/nanopb/"
LICENSE="BSD"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( generator )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"generator? ("
		# `protoc` utility
		"dev-libs/protobuf"
		"${PYTHON_DEPS}"
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"generator? ( ${PYTHON_REQ_USE} )"
)
RESTRICT+=""

inherit arrays

src_prepare() {
	eapply_user

	# change from static to shared
	esed -e 's,\bSTATIC\b,SHARED,' -e 's,\bARCHIVE\b,LIBRARY,' -i -- CMakeLists.txt

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-D nanopb_BUILD_RUNTIME=ON # headers, libs, ... important stuff
		-D nanopb_BUILD_GENERATOR=$(usex generator)
		-D nanopb_MSVC_STATIC_RUNTIME=OFF
	)

	cmake-utils_src_configure
}
