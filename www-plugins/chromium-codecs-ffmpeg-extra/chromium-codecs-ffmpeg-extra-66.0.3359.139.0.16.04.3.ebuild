# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## EXPORT_FUNCTIONS: src_unpack
inherit unpacker
## functions: get_version_component_range
inherit versionator

DESCRIPTION="Extra ffmpeg codecs for the Chromium Browser"
HOMEPAGE="https://packages.ubuntu.com/xenial/chromium-codecs-ffmpeg-extra"
LICENSE="GPL-2"

MY_PV_1="$(get_version_component_range 1-4)"
MY_PV_2="$(get_version_component_range 5-)"
SLOT="0/$(get_version_component_range 1)"
SRC_URI_A=(
	"amd64? ("
		# version must mutch Opera's Chrome version, which can be found in the about page,
		# and the library must be compiled against libc version available as stable in gentoo repos
		"mirror://ubuntu/pool/universe/c/chromium-browser/${PN}_${MY_PV_1}-0ubuntu${MY_PV_2}_amd64.deb"
	")"
)

KEYWORDS="-* ~amd64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=" mirror"

inherit arrays

S="${WORKDIR}"

src_install() {
	insinto /usr/lib/chromium-browser
	doins usr/lib/chromium-browser/libffmpeg.so
}

QA_PRESTRIPPED="usr/lib/chromium-browser/libffmpeg.so"
