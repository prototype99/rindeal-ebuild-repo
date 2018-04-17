# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:google:roboto"
GH_REF="v${PV}"

## font.eclass:
FONT_PN="roboto"
FONT_S="src/hinted"
FONT_SUFFIX="ttf"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS pkg_setup src_install pkg_postinst pkg_postrm
inherit font

DESCRIPTION="Hinted TrueType outlines based on specific and (older) versions of the fonts"
LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="amd64 arm arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"!media-fonts/roboto"
)

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_configure() { : ; }
src_compile() { : ; }
src_test() { : ; }
