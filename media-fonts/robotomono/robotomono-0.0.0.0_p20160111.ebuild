# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:google:fonts"
GH_REF="8839397"

## font.eclass:
FONT_S="apache/robotomono"
FONT_SUFFIX="ttf"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS pkg_setup src_install pkg_postinst pkg_postrm
inherit font

DESCRIPTION="Monospaced addition to the Roboto type family"
LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="amd64 arm arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

DOCS=( "${FONT_S}/DESCRIPTION.en_us.html" )

src_configure() { : ; }
src_compile() { : ; }
src_test() { : ; }
