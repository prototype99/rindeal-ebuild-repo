# Copyright 1999-2017 Gentoo Foundation
# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## functions: eautoreconf
inherit autotools
## functions: prune_libtool_files
inherit ltprune

DESCRIPTION="State machine for DEC VT100-VT520 compatible terminal emulators"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/kmscon/libtsm/"
LICENSE="MIT LGPL-2.1 BSD-2"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
	static-libs test
	# gtktsm # useless for now
)

SLOT="0"
snapshot_id="b73acb4c71698a764763ae8dad94c1e8a2b8d7a3" # 2014-04-24 18:15:29 +0200
SRC_URI="https://cgit.freedesktop.org/~dvdhrm/libtsm/snapshot/${snapshot_id}.tar.bz2 -> ${P}--snapshot--${snapshot_id}.tar.bz2"

CDEPEND_A=(
	# ```
	# PKG_CHECK_MODULES([XKBCOMMON], [xkbcommon],
	#  [have_xkbcommon=yes], [have_xkbcommon=no])
	# ```
	#
	# required for <xkbcommon/xkbcommon-keysyms.h> header file
	#
	"x11-libs/libxkbcommon"
	"dev-libs/glib:2"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
	"test? ( dev-libs/check )"
	## ```
	## PKG_CHECK_MODULES([GTKTSM], [gtk+-3.0 cairo pango pangocairo xkbcommon],
	## ```
# 	"gtktsm? ("
# 		"x11-libs/gtk+:3" # gtk+-3.0
# 		"x11-libs/cairo" # cairo
# 		"x11-libs/pango" # pango, pangocairo
# 		"x11-libs/libxkbcommon" # xkbcommon
# 	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
)

inherit arrays

S="${WORKDIR}/${snapshot_id}"

src_prepare() {
	default

	esed -e '/-ffast-math/d' -i -- Makefile.am || die
	esed -e '/AM_CFLAGS/ s,-O[0-3],,g' -i -- Makefile.am || die
	# ```
	# src/gtktsm/gtktsm-terminal.c:32:20: fatal error: libtsm.h: No such file or directory
	# ```
	esed -e '/gtktsm_CPPFLAGS/ s,= ,= -Isrc/tsm ,' -i -- Makefile.am || die

	eautoreconf
}

src_configure() {
	local my_econf_args=(
		--disable-optimizations
		--disable-debug
		$(use_enable static-libs static)
# 		$(use_enable gtktsm)
		--disable-gtktsm
	)
	econf "${my_econf_args[@]}"
}

src_install() {
	default

	prune_libtool_files
}
