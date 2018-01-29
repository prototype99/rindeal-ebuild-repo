# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## font.eclass:
FONT_SUFFIX="bdf"

## git-hosting.eclass:
GH_RN="github:romeovs"
GH_REF="98bbf59" # 20160404

## EXPORT_FUNCTIONS: pkg_setup src_install pkg_postinst pkg_postrm
inherit font
## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

DESCRIPTION="Pretty sweet 4px wide pixel font"
LICENSE="MIT"

SLOT="0"

KEYWORDS="amd64 arm arm64"

DEPEND="media-gfx/fontforge"

DOCS="README.md"

src_compile() {
	./convert.pe || die
}
