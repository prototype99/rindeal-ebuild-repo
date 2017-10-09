# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:zevv"

inherit git-hosting
# functions: tc-getCC
inherit toolchain-funcs
# functions: systemd_douserunit, systemd_get_userunitdir
inherit systemd
# functions: rindeal:expand_vars
inherit rindeal-utils

DESCRIPTION="Nostalgia bucklespring keyboard (IBM Model-M) sound emulator"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~x86"
IUSE_A=( doc )

CDEPEND_A=(
	"media-libs/openal"
	"media-libs/alure"
	"x11-libs/libX11"
	"x11-libs/libXtst"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"sys-apps/help2man"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_prepare() {
	# https://github.com/zevv/bucklespring/pull/27 https://github.com/zevv/bucklespring/pull/27
	# fixed in version >1.4.0
	eapply "${FILESDIR}/1.4.0-Makefile_flags.patch"
	eapply_user
}

src_configure() {
	export LD="$(tc-getCC)"

	declare -g -r -- BIN_NAME="buckle"
	export PATH_AUDIO="${EPREFIX}/usr/share/${BIN_NAME}/wav"
}

src_compile() {
	default

	# TODO: help2man.eclass
	local help2man=(
		help2man
		--name="${PN}" --version-string="${PV}"
		--no-info  --no-discard-stderr --help-option="-h"
		--output="${BIN_NAME}.1"
		"${BIN_NAME}"
	)
	echo "${help2man[@]}"
	PATH=".:${PATH}" "${help2man[@]}" || die

	rindeal:expand_vars "${FILESDIR}/${BIN_NAME}.service.in" "${BIN_NAME}.service"
	rindeal:expand_vars "${FILESDIR}/${BIN_NAME}.service.conf.in" "${BIN_NAME}.service.conf"
}

src_install() {
	dobin "${BIN_NAME}"

	doman "${BIN_NAME}.1"
	einstalldocs

	insinto "${PATH_AUDIO##"${EPREFIX}"}"
	doins -r wav/*

	systemd_douserunit "${BIN_NAME}.service"
	insinto "$(systemd_get_userunitdir)/${BIN_NAME}.service.d"
	newins "${BIN_NAME}.service.conf" "00gentoo.conf"
}
