# Copyright 1999-2018 Gentoo Foundation
# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:GNOME"
inherit git-hosting

PYTHON_COMPAT=( python2_7 )

## functions: linux-info_pkg_setup
inherit linux-info
## variables: PYTHON_REQUIRED_USE, PYTHON_DEPS
## functions: python_setup
inherit python-r1
## EXPORT_FUNCTIONS: src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg
## functions: gnome2_environment_reset, gnome2_giomodule_cache_update, gnome2_schemas_update
inherit gnome2-utils
## EXPORT_FUNCTIONS: src_configure src_compile src_test src_install
inherit meson

DESCRIPTION="The GLib library of C routines"
HOMEPAGE="${GH_HOMEPAGE} https://developer.gnome.org/glib"
LICENSE="LGPL-2.1+"

SLOT="2"
# - pkg.m4 for eautoreconf to avoid circular dependency on pkg-config
# - use 0.28 as newer version need to run their autoconf in order to create the necessary files
git-hosting_gen_snapshot_url "freedesktop::pkg-config" "pkg-config-0.28" pkg_config_snap_url pkg_config_distfile
SRC_URI+=" ${pkg_config_snap_url} -> ${pkg_config_distfile}"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
	dbus debug +mime selinux static-libs systemtap utils xattr
	+iconv_libc iconv_gnu iconv_native
	internal-pcre man libmount doc nls
)

# FIXME: verify all deps

CDEPEND_A=(
	"dev-libs/libpcre:3[static-libs?]"
	"virtual/libiconv"
	"virtual/libffi"
	"virtual/libintl"
	"sys-libs/zlib"
	"sys-apps/util-linux"
	"selinux? ( sys-libs/libselinux )"
	"xattr? ( sys-apps/attr )"
	"utils? ("
		"${PYTHON_DEPS}"
		"virtual/libelf:0="
	")"
	"libmount? ( sys-apps/util-linux[libmount] )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"app-text/docbook-xml-dtd:4.1.2"
	"dev-libs/libxslt"
	"sys-devel/gettext"
	"systemtap? ( dev-util/systemtap )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )
PDEPEND_A=(
	"!<gnome-base/gvfs-1.6.4-r990"
	"dbus? ( gnome-base/dconf )"
	"mime? ( x11-misc/shared-mime-info )"
)

REQUIRED_USE_A=(
	"utils? ( ${PYTHON_REQUIRED_USE} )"
	"^^ ( iconv_gnu iconv_libc iconv_native )"
)

inherit arrays

L10N_LOCALES=( af am an ar as ast az be be@latin bg bn bn_IN bs ca ca@valencia cs cy da de dz el en@shaw en_CA en_GB eo es et eu fa fi fr fur ga gd gl gu he hi hr hu hy id is it ja ka kk kn ko ku lt lv mai mg mk ml mn mr ms nb nds ne nl nn oc or pa pl ps pt pt_BR ro ru rw si sk sl sq sr sr@ije sr@latin sv ta te tg th tl tr tt ug uk vi wa xh yi zh_CN zh_HK zh_TW )
inherit l10n-r1

pkg_setup() {
	CONFIG_CHECK="~INOTIFY_USER"
	linux-info_pkg_setup

	python_setup

	GIOMODULE_CACHE="usr/$(get_libdir)/gio/modules/giomodule.cache"
	GSCHEMAS_CACHE="usr/share/glib-2.0/schemas/gschemas.compiled"
}

src_unpack() {
	git-hosting_src_unpack
	default
}

src_prepare-locales() {
	local l locales dir="po" pre="" post=".po"

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	l10n_get_locales locales app off
	for l in ${locales} ; do
		erm "${dir}/${pre}${l}${post}"
	done
}

src_prepare() {
	eapply_user

	src_prepare-locales

	# Prevent build failure in stage3 where pkgconfig is not available, bug #481056
	emv -f "${WORKDIR}"/pkg-config-*/pkg.m4 "${S}"/m4macros/

	# Don't build tests, also prevents extra deps, bug gentoo#512022
	esed -e "s/subdir('tests')//" -i -- meson.build
	if ! use nls ; then
		esed -e "s/subdir('po')//" -i -- meson.build
	fi

	# Leave python shebang alone - handled by python_replicate_script
	# We could call python_setup and give configure a valid --with-python
	# arg, but that would mean a build dep on python when USE=utils.
	esed -e '/${PYTHON}/d' -i -- glib/Makefile.am

	xdg_src_prepare
	gnome2_environment_reset
}

src_configure() {
	local myconf

	local emesonargs=(
		# -D runtime_libdir
		$(use iconv_gnu    && echo "-D iconv=gnu")
		$(use iconv_libc   && echo "-D iconv=libc")
		$(use iconv_native && echo "-D iconv=native")
		# -D charsetalias_dir
		# -D gio_module_dir
		$(meson_use selinux)
		$(meson_use xattr)
		$(meson_use libmount)
		$(meson_use internal-pcre internal_pcre)
		-D with-man=$(usex man true false)
		$(meson_use systemtap enable-dtrace)
		$(meson_use systemtap enable-systemtap)
		# -D tapset_install_dir
		-D gtk_doc=$(usex doc true false)
	)

	meson_src_configure

	local d
	for d in glib gio gobject; do
		eln -s "${S}"/docs/reference/${d}/html docs/reference/${d}/html
	done
}

src_install() {
	meson_src_install
	keepdir /usr/$(get_libdir)/gio/modules

	einstalldocs

	if use utils ; then
		python_replicate_script "${ED}"/usr/bin/gtester-report
	else
		erm "${ED}/usr/bin/gtester-report"
	fi

	# Do not install charset.alias even if generated, leave it to libiconv
	erm -f "${ED}/usr/lib/charset.alias"

	# Don't install gdb python macros, bug 291328
	erm -r "${ED}/usr/share/gdb/" "${ED}/usr/share/glib-2.0/gdb/"
}

pkg_preinst() {
	## Make gschemas.compiled belong to glib alone
	if [[ -e ${EROOT}${GSCHEMAS_CACHE} ]]; then
		ecp "${EROOT}"${GSCHEMAS_CACHE} "${ED}"/${GSCHEMAS_CACHE}
	else
		touch "${ED}"/${GSCHEMAS_CACHE} || die
	fi

	## Make giomodule.cache belong to glib alone
	if [[ -e ${EROOT}${GIOMODULE_CACHE} ]]; then
		ecp "${EROOT}${GIOMODULE_CACHE}" "${ED}/${GIOMODULE_CACHE}"
	else
		touch "${ED}/${GIOMODULE_CACHE}" || die
	fi
}

pkg_postinst() {
	# force (re)generation of gschemas.compiled
	GNOME2_ECLASS_GLIB_SCHEMAS="force"

	gnome2_giomodule_cache_update || die
	gnome2_schemas_update
}

pkg_postrm() {
	if [[ -z ${REPLACED_BY_VERSION} ]]; then
		erm -f "${EROOT}${GIOMODULE_CACHE}"
		erm -f "${EROOT}${GSCHEMAS_CACHE}"
	fi

	gnome2_giomodule_cache_update || die
	gnome2_schemas_update
}
