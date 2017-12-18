# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:adsr"
GH_REF="49be202feadaa9aa22385d82e22b5def20110d0a" # 20161001

inherit git-hosting

DESCRIPTION="Multiline buffer library"
LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="static-libs"

CDEPEND="
	dev-libs/libpcre:3
	dev-libs/uthash"
DEPEND="${CDEPEND}
	virtual/pkgconfig"
RDEPEND="${CDEPEND}"

src_prepare() {
	eapply "${FILESDIR}"/makefile.patch
	default

	# use global utlist.h instead of bundled copy
	sed -r -e 's|(#include *)"utlist.h"|\1<utlist.h>|g' \
		-i -- *.{c,h} || die
}

src_install() {
	dolib.so lib${PN}.so*
	use static-libs && \
		dolib.a "lib${PN}.a"

	doheader "${PN}.h"
}
