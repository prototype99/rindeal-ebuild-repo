# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

DESCRIPTION="Smartmontools drive database file"
HOMEPAGE="https://www.smartmontools.org/"
LICENSE="GPL-2+"

SLOT="0"
ref="9e368adcbaee51db95d32d5e23730869e3c4658a"
distfile="${ref}--drivedb.h"
SRC_URI="https://github.com/mirror/smartmontools/raw/${ref}/drivedb.h -> ${distfile}"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

S="${WORKDIR}"

MY_DB_PATH="/var/db/smartmontools"

src_unpack() {
	ecp "${DISTDIR}"/*"drivedb.h" "drivedb.h"
}

src_prepare() {
	eapply_user
}

src_configure() { : ; }
src_compile() { : ; }
src_test() { : ; }

src_install() {
	insinto "${MY_DB_PATH}"
	doins "drivedb.h"
}
