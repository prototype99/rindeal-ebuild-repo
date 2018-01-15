# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:sustrik"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## functions: eautoreconf
inherit autotools
## functions: prune_libtool_files
inherit ltprune

DESCRIPTION="Structured concurrency in C"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( doc static-libs man debug census threads sockets)

CDEPEND_A=( )
DEPEND_A=( "${CDEPEND_A[@]}"
	"man? ("
		"app-text/pandoc-bin"
		"app-text/pandoc"
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_prepare() {
	default

	esed -r -e "\,(tutorial|perf)/,d" -i -- Makefile.am
	esed -r -e "\|noinst_PROGRAMS *\+?\=| { s|^|# EBUILD MOD # |; s|\\\\$||; }" -i -- Makefile.am

	eautoreconf
}

src_configure() {
	export DILL_MANPAGES="$(usex man)"

	local myeconfargs=(
		--enable-shared
		$(use_enable static-libs static)
		$(use_enable debug)
		$(use_enable threads)

		$(use_enable sockets)
		$(use_enable census)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	prune_libtool_files

	if use doc ; then
		docinto html
		dodoc -r docs/html/*
	fi
}
