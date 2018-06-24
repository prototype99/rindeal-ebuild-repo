# Copyright 1999-2016 Gentoo Foundation
# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## functions: eautoreconf
inherit autotools

DESCRIPTION="Supporting tools for IMA and EVM"
HOMEPAGE="http://linux-ima.sourceforge.net"
LICENSE="GPL-2"

SLOT="0"
SRC_URI="mirror://sourceforge/linux-ima/${P}.tar.gz"

CDEPEND_A=(
	"sys-apps/keyutils"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"app-text/docbook-xsl-stylesheets"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
)

KEYWORDS="amd64 x86"
IUSE_A=( debug )

inherit arrays

src_prepare() {
	eapply_user

	esed -e '/^MANPAGE_DOCBOOK_XSL/ s:/usr/share/xml/docbook/stylesheet/docbook-xsl/manpages/docbook.xsl:/usr/share/sgml/docbook/xsl-stylesheets/manpages/docbook.xsl:' -i -- Makefile.am

	eautoreconf
}

src_configure() {
	econf $(use_enable debug)
}
