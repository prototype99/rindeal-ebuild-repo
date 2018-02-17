# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:diacritic"
GH_REF="c99f5279bba41b2dcf1826daa5daa23d08b0b5ee"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake-utils

DESCRIPTION="Convenient & cross-platform sandboxing C library"
LICENSE="MIT"

SLOT="0"

KEYWORDS="-* ~amd64"
IUSE_A=( reopen-arena-shm file-backed-arena static-libs test +fork-resilience )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_prepare() {
	eapply_user

	esed -e 's,\bSTATIC\b,SHARED,' -e "/DESTINATION/ s,\blib\b,$(get_libdir)," -i -- CMakeLists.txt
	esed -r -e 's, -(pedantic)\b,,g' -i -- CMakeLists.txt

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-D USE_QEMU=OFF # use qemu to run the tests
		-D BXF_ARENA_REOPEN_SHM=$(usex reopen-arena-shm)
		-D BXF_ARENA_FILE_BACKED=$(usex file-backed-arena)
		-D BXF_STATIC_LIB=$(usex static-libs)
		-D BXF_SAMPLES=OFF
		-D BXF_TESTS=$(usex test)
		-D BXF_FORK_RESILIENCE=$(usex fork-resilience)
	)

	cmake-utils_src_configure
}
