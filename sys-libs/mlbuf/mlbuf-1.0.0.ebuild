# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:adsr"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

DESCRIPTION="Multiline buffer library"
LICENSE="Apache-2.0"

# subslotting by soname
SLOT="0/1"

KEYWORDS="amd64 arm arm64"
IUSE_A=( static-libs )

CDEPEND_A=(
	"dev-libs/libpcre:3"
	"=dev-libs/uthash-2*"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_prepare() {
	default

	# use global utlist.h instead of bundled copy
	esed -r -e 's|(#include *)"utlist.h"|\1<utlist.h>|g' \
		-i -- *.{c,h}
}

src_configure() {
	export PCRE_LDLIBS="$(pkg-config libpcre --libs-only-l)"
}

src_install() {
	dolib.so "lib${PN}.so"*
	use static-libs && \
		dolib.a "lib${PN}.a"

	doheader "${PN}.h"
}
