# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:cloudflare:python-cloudflare"

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
inherit distutils-r1

DESCRIPTION="Example package"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/future[${PYTHON_USEDEP}]"
	"dev-python/requests[${PYTHON_USEDEP}]"
	"dev-python/pyyaml[${PYTHON_USEDEP}]"
)

inherit arrays

src_prepare() {
	default

	sed -r -e "/packages *=/ s|\[[^]]*\]\+||" -i -- setup.py || die

	erm -r examples
}
