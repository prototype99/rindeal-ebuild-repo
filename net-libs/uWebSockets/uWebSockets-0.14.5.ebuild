# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:uNetworking"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## functions: append-cppflags
inherit flag-o-matic

DESCRIPTION="Highly efficient cross-platform WebSocket & HTTP library for C++11 and Node.js"
LICENSE="ZLIB"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( asio libuv +epoll threads )

CDEPEND_A=(
	"asio? ( dev-libs/boost:0 )"
	"libuv? ( dev-libs/libuv:0 )"
	"dev-libs/openssl:0"
	"sys-libs/zlib:0"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"^^ ( asio libuv epoll )"
)

inherit arrays

# ```
# make[1]: warning: jobserver unavailable: using -j1.  Add '+' to parent make rule.
# ```
MAKEOPTS+=" -j1"

src_prepare() {
	eapply_user

	esed -e "s, -O3 , ,g" -i -- Makefile
	esed -e "s, -s , ,g" -i -- Makefile
}

src_compile() {
	my_use_def() {
		echo "$(usex "${1}" "-D" "-U")${2}"
	}

	append-cppflags "$(my_use_def asio USE_ASIO)"
	append-cppflags "$(my_use_def libuv USE_LIBUV)"
	append-cppflags "$(my_use_def epoll USE_EPOLL)"
	append-cppflags "$(my_use_def threads UWS_THREADSAFE)"
	append-cppflags "-UUSE_MTCP"

	emake
}

src_install() {
	emake PREFIX="${ED}"/usr install

	einstalldocs
}
