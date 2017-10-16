# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:cboxdoerfer:ddb_spectrogram"
[[ "${PV}" != *9999* ]] && \
	GH_REF="8d1b3713f3a3a8a93b4934a4782fb3db7f744fb7"

# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
# functions: ddb_plugin_doins
inherit deadbeef-plugin
# functions: tc-getPKG_CONFIG
inherit toolchain-funcs

DESCRIPTION="Spectrogram plugin for the DeaDBeeF audio player"
LICENSE="GPL-2"

SLOT="0"

[[ "${PV}" != *9999* ]] && \
	KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( +gtk2 +gtk3 )

CDEPEND_A=(
	"gtk2? ( x11-libs/gtk+:2 )"
	"gtk3? ( x11-libs/gtk+:3 )"
	"sci-libs/fftw:3.0"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"|| ( gtk2 gtk3 )"
)

inherit arrays

src_prepare() {
	default

	sed -e '/^CFLAGS/ s, -g,,' -i -- Makefile || die
}

src_compile() {
	emake $(usev gtk2) $(usev gtk3) \
		FFTW_LIBS="$($(tc-getPKG_CONFIG) --libs fftw3)" \
		SHELL='sh -x'
}

src_install() {
	use gtk2 && ddb_plugin_doins gtk2/ddb_vis_spectrogram_GTK2.so
	use gtk3 && ddb_plugin_doins gtk3/ddb_vis_spectrogram_GTK3.so

	dodoc README.md
}
