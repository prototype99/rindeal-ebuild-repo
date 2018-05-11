# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

PN_NO_BIN="${PN%-bin}"

DESCRIPTION="command line tool for processing HTML"
HOMEPAGE="https://github.com/ericchiang/pup"
LICENSE="MIT"

SLOT="0"
SRC_URI="
	amd64? ( https://github.com/ericchiang/${PN_NO_BIN}/releases/download/v${PV}/${PN_NO_BIN}_v${PV}_linux_amd64.zip )
	arm?   ( https://github.com/ericchiang/${PN_NO_BIN}/releases/download/v${PV}/${PN_NO_BIN}_v${PV}_linux_arm.zip )
	arm64? ( https://github.com/ericchiang/${PN_NO_BIN}/releases/download/v${PV}/${PN_NO_BIN}_v${PV}_linux_arm64.zip )
"

KEYWORDS="-* amd64 arm arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=" mirror"

inherit arrays

S="${WORKDIR}"

src_prepare() { eapply_user ; }
src_configure() { : ; }
src_compile() { : ; }
src_test() { : ; }

src_install() {
	into "/opt/${PN_NO_BIN}"
	dobin "${PN_NO_BIN}"
	into "/"
	dosym "../../opt/${PN_NO_BIN}/bin/${PN_NO_BIN}" "/usr/bin/${PN_NO_BIN}"
}
