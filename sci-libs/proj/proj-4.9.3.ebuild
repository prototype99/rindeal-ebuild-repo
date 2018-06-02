# Copyright 1999-2018 Gentoo Foundation
# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:OSGeo:proj.4"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## functions: prune_libtool_files
inherit ltprune
## functions: java-pkg_javac-args, java-pkg_get-jni-cflags
inherit java-pkg-opt-2
## functions: append-cflags
inherit flag-o-matic
## functions eautoreconf
inherit autotools

DESCRIPTION="Proj.4 cartographic projection software"
HOMEPAGE="https://proj4.org ${GH_HOMEPAGE}"
LICENSE="MIT"

SLOT="0"

# arm doesn't have stable deps
KEYWORDS="amd64 ~arm ~arm64"
IUSE="java static-libs"

RDEPEND=""
DEPEND="
	app-arch/unzip
	java? ( >=virtual/jdk-1.5 )"

inherit arrays

src_unpack() {
	git-hosting_src_unpack

	ecp "${S}"/nad/README{,.NAD}
}

src_prepare() {
	eapply_user

	eautoreconf
}

src_configure() {
	if use java ; then
		export JAVACFLAGS="$(java-pkg_javac-args)"
		append-cflags "$(java-pkg_get-jni-cflags)"
	fi

	local my_econf_args=(
		$(use_enable static-libs static)
		$(use_with java jni)
	)

	econf "${my_econf_args[@]}"
}

src_install() {
	default

	dodoc nad/README.NAD

	prune_libtool_files
}
