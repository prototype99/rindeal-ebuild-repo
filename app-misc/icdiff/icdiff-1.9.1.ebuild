# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## python-*.eclass:
PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

## git-hosting.eclass:
GH_RN="github:jeffkaufman"
GH_REF="release-${PV}"

## EXPORT_FUNCTIONS: pkg_setup
inherit python-single-r1
## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

DESCRIPTION="Colourized diff that supports side-by-side diffing"
HOMEPAGE="https://www.jefftk.com/icdiff ${HOMEPAGE}"
LICENSE="PSF-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"

CDEPEND="${PYTHON_DEPS}"
DEPEND="${CDEPEND}"
RDEPEND="${CDEPEND}"

REQUIRED_USE+=" ${PYTHON_REQUIRED_USE}"

src_test() {
	./test.sh "${EPYTHON%.*}" || die "Tests failed"
}

src_install() {
	dobin ${PN} git-${PN}

	einstalldocs
}
