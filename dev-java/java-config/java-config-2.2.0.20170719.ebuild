# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# jython depends on java-config, so don't add it or things will break
PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit distutils-r1
inherit vcs-snapshot

DESCRIPTION="Java environment configuration query tool"
HOMEPAGE="https://gitweb.gentoo.org/proj/java-config.git/"
LICENSE="GPL-2"

commit="82a5a6343e7b6172af6aaa1b3ea0a61a43afd206"
SRC_URI="https://gitweb.gentoo.org/proj/java-config.git/snapshot/${commit}.tar.bz2 -> ${PF}.tar.bz2"
SLOT="2"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="test"

CDEPEND_A=(
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"test? ( sys-apps/portage[${PYTHON_USEDEP}] )"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"!dev-java/java-config-wrapper"
	# baselayout-java is added as a dep till it can be added to eclass.
	"sys-apps/baselayout-java"
	"sys-apps/portage[${PYTHON_USEDEP}]"
)

inherit arrays

python_compile_all() {
	# this fixes at least variable expansion in `launcher.bash`
	BUILD_DIR="${S}" esetup.py build
}

python_install_all() {
	distutils-r1_python_install_all

	# This replaces the file installed by java-config-wrapper.
	dosym java-config-2 /usr/bin/java-config
}

python_test() {
	esetup.py test
}
