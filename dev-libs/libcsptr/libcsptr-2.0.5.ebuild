# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:Snaipe"
GH_REF="5bc7aad8cab5f8d9d64308dcffb1a397e86a6b0c" # May 1, 2017

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake-utils

DESCRIPTION="Smart pointers for the (GNU) C programming language"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( test +sentinel fixed-allocator )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"test? ( dev-libs/check )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_prepare() {
	eapply_user

	esed -e 's,\bSTATIC\b,SHARED,' -e "s,\blib\b,$(get_libdir)," -i -- CMakeLists.txt
	esed -r -e 's, -(Werror|g)\b,,g' -i -- CMakeLists.txt


	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-D LIBCSPTR_TESTS=$(usex test)
		-D SENTINEL=$(usex sentinel)
		-D FIXED_ALLOCATOR=$(usex fixed-allocator)
	)

	cmake-utils_src_configure
}
