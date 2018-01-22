# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:SirCmpwn"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake-utils

DESCRIPTION="Asynchronous email client for your terminal"
LICENSE="MIT"

SLOT="0"

[[ "${PV}" == *9999* ]] || \
	KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( openssl test )

CDEPEND_A=(
	# ```
	# find_package(OpenSSL)
	# ```
	"openssl? ( dev-libs/openssl:0 )"
	# ```
	# find_package(Termbox REQUIRED)
	# ```
	"sys-libs/termbox"
	# ```
	# find_package(Libtsm REQUIRED)
	# ```
	"sys-libs/libtsm"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	# ```
	# find_package(CMocka)
	# ```
	"test? ( dev-util/cmocka )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_prepare() {
	eapply_user

	esed -e '/CMAKE_C_FLAGS.*-Werror/d' -i -- CMakeLists.txt || die

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-D enable-openssl=$(use openssl)
		-D enable-tests=$(use test)
	)

	cmake-utils_src_configure
}
