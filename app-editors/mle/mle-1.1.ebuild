# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:adsr"
GH_REF="v${PV}"
## git-r3.eclass (part of git-hosting.eclass):
[[ "${PV}" == *9999* ]] && \
	EGIT_SUBMODULES=() # no submodules please

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## functions: append-cflags
inherit flag-o-matic

DESCRIPTION="Small but powerful console text editor written in C"
LICENSE="Apache-2.0 BSD-1"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"sys-libs/mlbuf:0"
	"sys-libs/termbox:0"
	"dev-libs/uthash:0"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

REQUIRED_USE=""
RESTRICT+=""

src_prepare() {
	default

	local sedargs=(
		# flags
		-e '/mle_cflags/ s| -g||g'

		# libpcre
		-e "/mle_ldlibs/ s| -lpcre| $(pkg-config --libs libpcre)|"

		# static lib{mlbuf,termbox}
		-e '/mle_cflags/ s@-I[^ ]*(mlbuf|termbox)[^ ]*@@g'
		-e '/^mle:/ s@[^ \t]*lib(mlbuf|termbox)\.a@@g'
		-e '/\$\(CC\)/ s@[^ ]*(lib(mlbuf|termbox)\.a)@-l\2@g'
	)
	sed -r "${sedargs[@]}" -i Makefile || die

	# use global uthash.h/utlist.h instead of bundled copy
	sed -r \
		-e 's|(#include *)"uthash.h"|\1<uthash.h>|g' \
		-e 's|(#include *)"utlist.h"|\1<utlist.h>|g' \
		-i -- *.{c,h} || die
}

src_configure() {
	append-cflags "-Wno-unused-result"
}

src_install() {
	dobin "${PN}"
	einstalldocs
}
