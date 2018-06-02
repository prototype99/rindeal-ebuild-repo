# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:jonls"
GH_REF="v${PV}"

## python-*.eclass:
PYTHON_COMPAT=( python3_{4,5,6} )

# functions: rindeal:dsf:prefix_flags
inherit rindeal-utils
# functions: python_setup, python_get_sitedir
# EXPORT_FUNCTIONS: pkg_setup
inherit python-any-r1
# EXPORT_FUNCTIONS src_unpack
inherit git-hosting
# EXPORT_FUNCTIONS: src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg
# functions: eautoreconf
inherit autotools
# functions: systemd_get_userunitdir
inherit systemd

DESCRIPTION="Screen color temperature adjusting software"
HOMEPAGE="http://jonls.dk/redshift/ ${GH_HOMEPAGE}"
LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~amd64"
IUSE_A=(
	gui nls

	$(rindeal:dsf:prefix_flags \
		'methods_' \
		drm +randr vidmode
	)
	$(rindeal:dsf:prefix_flags \
		'location_providers_' \
		geoclue2
	)
)

CDEPEND_A=(
	"methods_drm? ( x11-libs/libdrm )"
	"methods_randr? ( x11-libs/libxcb )"
	"methods_vidmode? ("
		">=x11-libs/libX11-1.4"
		"x11-libs/libXxf86vm"
	")"

	"location_providers_geoclue2? ("
		"app-misc/geoclue:2.0"
		"dev-libs/glib:2"
	")"
	"gui? ( ${PYTHON_DEPS} )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	">=dev-util/intltool-0.50"
	"nls? ("
		"sys-devel/gettext"
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"gui? ("
		"$(python_gen_any_dep \
			'dev-python/pygobject[${PYTHON_USEDEP}]')"
		"$(python_gen_any_dep \
			'dev-python/pyxdg[${PYTHON_USEDEP}]')"
		"x11-libs/gtk+:3[introspection]"
	")"
)

REQUIRED_USE_A=(
	"gui? ( ${PYTHON_REQUIRED_USE} )"
	"|| ("
		"$(rindeal:dsf:prefix_flags \
			'methods_' \
			drm randr vidmode
		)"
	")"
)

inherit arrays

pkg_setup() {
	use gui && python-any-r1_pkg_setup
}

src_prepare() {
	xdg_src_prepare

	eautoreconf
}

src_configure() {
	local my_econf_args=(
		--disable-silent-rules # verbose build
		--disable-corelocation # OSX
		--disable-wingdi # Windows
		--disable-quartz # OSX
		--disable-ubuntu # Ubuntu icons

		$(use_enable nls)

		$(use_enable methods_drm drm)
		$(use_enable methods_vidmode vidmode)
		$(use_enable methods_randr randr)

		$(use_enable location_providers_geoclue2 geoclue2)

		$(use_enable gui)
		--without-systemduserunitdir # we install custom systemd services
	)

	econf "${my_econf_args[@]}"
}

src_install() {
	emake DESTDIR="${D}" UPDATE_ICON_CACHE=/bin/true $(usex nls '' INTLTOOL_MERGE=/bin/true) install

	if use gui ; then
		emake DESTDIR="${D}" pythondir="$(python_get_sitedir)" \
			-C src/redshift-gtk install
		dosym redshift-gtk /usr/bin/gtk-redshift
	fi

	for s in "${PN}.service" $(usex gui "${PN}-gtk.service" '') ; do
		rindeal:expand_vars "${FILESDIR}/${s}.in" "${T}/${s}"
		systemd_douserunit "${T}/${s}"
	done
}
