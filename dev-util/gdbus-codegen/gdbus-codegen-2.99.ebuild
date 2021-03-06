# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

DESCRIPTION="Virtual package to satisfy gentoo deps"
HOMEPAGE="https://developer.gnome.org/gio/stable/gdbus-codegen.html"
LICENSE="no-source-code"

SLOT="0"

KEYWORDS="amd64 arm arm64"

S="${WORKDIR}"

RDEPEND="dev-libs/glib:2"

src_configure() { : ; }
src_compile()   { : ; }
src_install()   { : ; }

pkg_postinst() {
	if ! rindeal::has_version dev-libs/glib:2::rindeal ; then
		echo
		ewarn "This is a virtual package existing just to satisfy gentoo deps."
		ewarn "Make sure you use ${CATEGORY}/${PN} package from 'rindeal' repo."
		ewarn "Otherwise you'll end up with no ${PN}, which will cause subsequent builds to fail."
		echo
	fi
}
