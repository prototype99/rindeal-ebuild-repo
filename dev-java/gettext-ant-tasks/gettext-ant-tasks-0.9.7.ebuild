# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## java-pkg-2.eclass:
EANT_BUILD_TARGET="compile jar"
EANT_GENTOO_CLASSPATH="
	ant-core
"

## EXPORT_FUNCTIONS: pkg_setup src_prepare src_compile pkg_preinst
inherit java-pkg-2

## EXPORT_FUNCTIONS: src_configure
inherit java-ant-2

DESCRIPTION="Java classes for internationalization (i18n) - Ant tasks"
HOMEPAGE="https://tracker.debian.org/pkg/gettext-ant-tasks"
LICENSE="Apache-2.0"

SLOT="0"
SRC_URI="mirror://debian/pool/main/${PN:0:1}/${PN}/${PN}_0.9.7+svn206.orig.tar.xz"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=(
	"dev-java/ant-core:0"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jdk-1.7"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jre-1.7"
)

inherit arrays

S="${WORKDIR}/${PN}"

src_prepare() {
	eapply_user

	java-pkg-2_src_prepare
	java-ant_rewrite-classpath
}

src_install() {
	java-pkg_dojar "${PN}.jar"
}
