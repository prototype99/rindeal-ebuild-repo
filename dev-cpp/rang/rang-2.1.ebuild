# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:agauniyal"

inherit git-hosting
inherit cmake-utils

DESCRIPTION="Minimal, Header only Modern c++ library for colors in your terminal"
LICENSE="Unlicense"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE=""

# CMake is only used to build & run tests, so override phases
src_configure() { :; }
src_compile() { :; }

src_test() {
	cmake-utils_src_configure
	cmake-utils_src_compile
	cmake-utils_src_test
}

src_install() {
	doheader include/${PN}.hpp
	einstalldocs
}
