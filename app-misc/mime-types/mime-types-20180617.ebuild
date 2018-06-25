# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

DESCRIPTION="MIME type associations for file types"
HOMEPAGE="https://pagure.io/mailcap"
LICENSE="public-domain"

ref="ec8c60e"

SLOT="0"
SRC_URI="https://pagure.io/mailcap/raw/${ref}/f/mime.types"

KEYWORDS="amd64 arm arm64"

S="${WORKDIR}"

RESTRICT+=" mirror"

src_unpack() { : ; }
src_configure() { : ; }
src_compile() { : ; }
src_test() { : ; }

src_install() {
	insinto /etc
	doins "${DISTDIR}"/mime.types
}
