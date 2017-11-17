# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
inherit rindeal

GH_RN="gitlab:rindeal-mirrors"
GH_REF="5e2b3ddde7cda5eb6bc09a5546a76b00e49d888f" # 2017-10-12

PYTHON_COMPAT=( python2_7 )
DISTUTILS_SINGLE_IMPL=1

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: pkg_setup + src_prepare src_configure src_compile src_test src_install
inherit distutils-r1

DESCRIPTION="GYP (Generate Your Projects) meta-build system"
HOMEPAGE="https://gyp.gsrc.io/ https://chromium.googlesource.com/external/gyp ${GH_HOMEPAGE}"
LICENSE="BSD"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=(
	"${PYTHON_DEPS}"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=( "${PYTHON_REQUIRED_USE}" )
RESTRICT+=""

inherit arrays

src_test() {
	# More errors when DeprecationWarnings enabled.
	local -x PYTHONWARNINGS=""

	"${PYTHON}" gyptest.py --all --verbose
}
