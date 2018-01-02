# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:nlohmann"
GH_REF="v${PV}"

inherit git-hosting
inherit cmake-utils

DESCRIPTION="JSON for Modern C++"
HOMEPAGE="https://nlohmann.github.io/json/ ${GH_HOMEPAGE}"
LICENSE="MIT"

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
	doheader src/${PN}.hpp
	einstalldocs
}
