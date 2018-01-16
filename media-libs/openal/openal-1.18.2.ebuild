# Copyright 1999-2015 Gentoo Foundation
# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:kcat:openal-soft"
GH_REF="openal-soft-${PV}"

## EXPORT_FUNCTIONS: src_unpack
## variables: GH_HOMEPAGE
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake-utils
## EXPORT_FUNCTIONS: src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg
## functions: make_desktop_entry
inherit desktop

DESCRIPTION="Software implementation of the OpenAL 3D audio API"
HOMEPAGE="http://kcat.strangesoft.net/openal.html ${GH_HOMEPAGE}"
LICENSE="LGPL-2+"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
backends=( alsa coreaudio jack oss portaudio pulseaudio )
IUSE_A=(
	${backends[@]}
	debug examples gui tests utils
	cpu_flags_x86_{sse,sse2,sse3,sse4_1} cpu_flags_arm_neon
)

CDEPEND_A=(
	"alsa? ( media-libs/alsa-lib )"
	"jack? ( virtual/jack )"
	"portaudio? ( media-libs/portaudio )"
	"pulseaudio? ( media-sound/pulseaudio )"
	"gui? ("
		"dev-qt/qtcore:5"
		"dev-qt/qtgui:5"
		"dev-qt/qtwidgets:5"
	")"

	"examples? ("
		"media-libs/libsdl2[sound]"
		"media-video/ffmpeg"
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"oss? ( virtual/os-headers )"
	"utils? ( sys-apps/help2man )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	# at least one backend must be selected otherwise it segfaults
	"|| ( ${backends[*]} )"
	# IF(ALSOFT_UTILS AND NOT ALSOFT_NO_CONFIG_UTIL) add_subdirectory(utils/alsoft-config)
	"gui? ( utils )"
)

inherit arrays

# upstream uses this pre-created dir
BUILD_DIR="${S}/build"

src_prepare() {
	eapply "${FILESDIR}"/1.17.2-disable_pulseaudio_auto_spawn.patch
	eapply_user

	# TODO: when some dependency is not found for examples/utils/tests, build doesn't die

	xdg_src_prepare
	cmake-utils_src_prepare
}

src_configure() {
		local mycmakeargs=(
			-D "ALSOFT_BACKEND_ALSA=$(usex alsa)"
			-D "ALSOFT_BACKEND_COREAUDIO=$(usex coreaudio)"
			-D "ALSOFT_BACKEND_JACK=$(usex jack)"
			-D "ALSOFT_BACKEND_OSS=$(usex oss)"
			-D "ALSOFT_BACKEND_PORTAUDIO=$(usex portaudio)"
			-D "ALSOFT_BACKEND_PULSEAUDIO=$(usex pulseaudio)"
			-D "ALSOFT_BACKEND_WAVE=ON" # Wave File Writer

			-D "ALSOFT_CPUEXT_SSE=$(usex cpu_flags_x86_sse)"
			-D "ALSOFT_CPUEXT_SSE2=$(usex cpu_flags_x86_sse2)"
			-D "ALSOFT_CPUEXT_SSE3=$(usex cpu_flags_x86_sse3)"
			-D "ALSOFT_CPUEXT_SSE4_1=$(usex cpu_flags_x86_sse4_1)"
			-D "ALSOFT_CPUEXT_NEON=$(usex cpu_flags_arm_neon)"

			-D "ALSOFT_EXAMPLES=$(usex examples)"
			-D "ALSOFT_INSTALL=ON"
			# Disable building the alsoft-config utility
			-D "ALSOFT_NO_CONFIG_UTIL=$(usex '!gui')"
			-D "ALSOFT_TESTS=$(usex tests)"
			# Build and install utility programs
			-D "ALSOFT_UTILS=$(usex utils)"
		)

		cmake-utils_src_configure
}

H2M_BINS=( )

src_compile() {
	cmake-utils_src_compile

	use tests && H2M_BINS+=( altonegen )
	use utils && H2M_BINS+=( makehrtf openal-info )

	local h2m_opts=(
		--no-discard-stderr
		--no-info
		--version-string=${PV}
	)

	local b
	for b in "${H2M_BINS[@]}" ; do
		set -- help2man "${h2m_opts[@]}" --output=${b}.1 build/${b}
		echo "$@"
		"$@" || die
	done
}

src_install() {
	DOCS=( alsoftrc.sample docs/env-vars.txt docs/hrtf.txt ChangeLog README )

	cmake-utils_src_install

	(( ${#H2M_BINS[*]} )) && doman "${H2M_BINS[@]/%/.1}"

	# NOTE: alsoft.conf doesn't support PREFIX, needs patching in ${S}/Alc/alcConfig.c
	insinto /etc/openal
	newins alsoftrc.sample alsoft.conf

	if use gui ; then
		local make_desktop_entry_args=(
			"${EPREFIX}"/usr/bin/alsoft-config	# exec
			"OpenAL Soft Configuration"	# name
			settings-configure	# icon
			"Settings;HardwareSettings;Audio;AudioVideo;"	# categories
		)
		local make_desktop_entry_extras=(  )
		make_desktop_entry "${make_desktop_entry_args[@]}" \
			"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"
	fi
}
