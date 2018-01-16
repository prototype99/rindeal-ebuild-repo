# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## EXPORT_FUNCTIONS: src_unpack
inherit unpacker

DESCRIPTION="Extra ffmpeg codecs for the Chromium Browser"
HOMEPAGE="https://packages.ubuntu.com/xenial/chromium-codecs-ffmpeg-extra"
LICENSE="GPL-2"

SLOT="0"
SRC_URI_A=(
	"amd64? ("
		"mirror://ubuntu/pool/universe/c/chromium-browser/${PN}_${PV}-0ubuntu1_amd64.deb"
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
