# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

DESCRIPTION="Virtual package to satisfy gentoo deps"
HOMEPAGE=""
LICENSE="no-source-code"

SLOT="0"

KEYWORDS="amd64 arm arm64"

S="${WORKDIR}"

PDEPEND="dev-libs/glib:2"

src_configure() { : ; }
src_compile()   { : ; }
src_install()   { : ; }
