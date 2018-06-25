# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:F1ash"

## EXPORT_FUNCTIONS: src_unpack
## variables: SRC_URI
inherit git-hosting

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake-utils

## EXPORT_FUNCTIONS: src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg

DESCRIPTION="GUI application for managing virtual machines"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64"
IUSE_A=( libcacard spice-audio spice vnc lxc )

CDEPEND_A=(
	"app-emulation/libvirt:0"
	"dev-qt/qtwidgets:5"
	"dev-qt/qtxml:5"
	"dev-qt/qtsvg:5"
	"dev-qt/qtmultimedia:5"
	"dev-qt/qtnetwork:5"

	"lxc? ( x11-libs/qtermwidget:0 )"
	"vnc? ("
		"net-libs/libvncserver:0"
		"kde-apps/krdc:5"
	")"
	"spice? ("
		"dev-libs/glib:2"
		"app-emulation/spice:0"
# 		"net-misc/spice-gtk:0"
		"libcacard? ( app-emulation/libcacard:0 )"
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-qt/linguist-tools:5"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

L10N_LOCALES=( it ru )
inherit l10n-r1

src_prepare-locales() {
	local l locales dir="src/translations" pre="qt_virt_manager_" post=".ts"

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	l10n_get_locales locales app off
	for l in ${locales} ; do
		erm "${dir}/${pre}${l}${post}"
		esed -e "\,${dir}/${pre}${l}${post},d" -i -- CMakeLists.txt
	done
}

src_prepare() {
	eapply_user

	src_prepare-locales

	xdg_src_prepare

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-D WITH_SPICE_SUPPORT=$(usex spice)
		-D WITH_VNC_SUPPORT=$(usex vnc)
		-D WITH_LXC_SUPPORT=$(usex lxc)
	)
	if use spice ; then
		mycmakeargs+=(
			-D WITH_LIBCACARD=$(usex libcacard)
			-D USE_SPICE_AUDIO=$(usex spice-audio)
		)
	fi

	cmake-utils_src_configure
}

src_install() {
	default

	cmake-utils_src_install
}
