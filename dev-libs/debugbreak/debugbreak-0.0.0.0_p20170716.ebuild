# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:scottt"
GH_REF="7ee9b29208c2c5aad8a935334062a87c738b6aa4"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

DESCRIPTION="break into the debugger programmatically"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_compile() { : ; }

src_install() {
	doheader "${PN}.h"

	einstalldocs
}
