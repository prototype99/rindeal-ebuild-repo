# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# git-hosting.eclass
GH_RN="github:blackears"
GH_REF="v${PV}"

# java-pkg-2.eclass:
EANT_BUILD_TARGET="jar"
EANT_GENTOO_CLASSPATH="
	ant-core
"

# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
# EXPORT_FUNCTIONS: pkg_setup src_prepare src_compile pkg_preinst
inherit java-pkg-2
# EXPORT_FUNCTIONS: src_configure
inherit java-ant-2

DESCRIPTION="SVG engine for Java"
LICENSE="|| ( LGPL-2.1 BSD )"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jdk-1.8"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jre-1.8"
)

inherit arrays

OLD_S="${S}"
S+="/svg-core"

src_prepare() {
	default

	epushd "${OLD_S}"
	eapply "${FILESDIR}/0002-Disable-useless-automated-jar-signing.patch"
	eapply "${FILESDIR}/0005-dont-call-netbeans-ant-tasks.patch"
	eapply "${FILESDIR}/0006-modify-broken-upstream-pom.patch"
	eapply "${FILESDIR}/0007-CVE-2017-5617-Allow-only-data-scheme.patch"
	epopd

	# remove bundled jars
	erm -r "${OLD_S}/libraries"/{junit*,CopyLibs,*.jar}

	# fix path to javacc.jar
	local javacc_home="$(java-pkg_getjars javacc)"
	javacc_home="${javacc_home/#\/\///}"
	javacc_home="${javacc_home%%/*}"
	sed -e "/name=\"javacc.home\"/ s|location=\".*\"|location=\"${javacc_home}\"|" -i -- build.xml || die

	# fix manually what java-ant_bsfix_one() won't
	sed -e 's|"@{classpath}"|"${gentoo.classpath}"|g' -i -- nbproject/build-impl.xml || die

	# these dirs are checked for presence during the build
	emkdir src/gen/{res,java}

	java-pkg-2_src_prepare
}

src_configure() {
	java-ant-2_src_configure
	java-ant_bsfix_one "nbproject/build-impl.xml"
}

src_install() {
	java-pkg_dojar dist/svg-salamander-core.jar

	dodoc "${OLD_S}/README.md"
}
