# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:grishka"
GH_REF="6a0b3b23b79949828d36be2a45007602c6f493d4" # 2017-11-10

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
inherit flag-o-matic
inherit gyp-utils

DESCRIPTION="VoIP library for Telegram clients"
LICENSE="Unlicense"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=(
	"media-libs/opus"
	"media-libs/alsa-lib"
	"media-sound/pulseaudio"
	"dev-libs/openssl"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

# one of the 'configurations' values
GYP_BUILD_MODE="Release"
GYP_OUT_DIR="${WORKDIR}/${P}_gyp_out"
BUILD_DIR="${GYP_OUT_DIR}/${GYP_BUILD_MODE}"

src_prepare() {
	eapply_user

	sed -r \
		-e "/'-msse2',/ s|^|# flag # |" \
		-e "\|(.*(\.\./){2,}.*)| s|^|# rel paths # |" \
		-e "s|'static_library',|'shared_library', # shared lib|" \
		-i -- "${PN}.gyp" || die

	emkdir "${BUILD_DIR}"
}

src_configure() {
	append-cxxflags "-std=gnu++14" # default GCC6 mode
	append-flags "-fPIC" # required for a shared lib

	local MY_EGYP_ARGS=(
		--generator-output="${GYP_OUT_DIR}"
		# output_dir: relative path from generator_dir to the build directory. Defaults to `out`.
		-G output_dir=""
		-G config="${GYP_BUILD_MODE}"

		-D linux_path_opus_include="$(pkg-config --cflags-only-I opus | sed 's|-I||')"
	)
	egyp "${PN}.gyp"
}

src_compile() {
	epushd "${BUILD_DIR}"
	eninja
	epopd
}

src_install() {
	### shared lib
	epushd "${BUILD_DIR}"
	dolib.so "lib/${PN}.so"
	epopd

	### header files
	local tmpdir=(mktemp --directory)
	local header_dir="${tmpdir}/${PN}"
	NO_V=1 emkdir "${header_dir}"
	NO_V=1 ecp *.h "${header_dir}"
	doheader -r "${header_dir}"

	### docs
	einstalldocs
}
