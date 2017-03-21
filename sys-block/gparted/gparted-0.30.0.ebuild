# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GNOME2_EAUTORECONF="yes"
inherit gnome2

DESCRIPTION="Gnome Partition Editor"
HOMEPAGE="https://gparted.sourceforge.io/"
LICENSE="GPL-2+ FDL-1.2+"

MY_P="${PN^^}_${PV//./_}"
SLOT="0"
SRC_URI="https://git.gnome.org/browse/${PN}/snapshot/${MY_P}.tar.xz"

KEYWORDS="~amd64"
IUSE_A=( doc libparted-dmraid nls btrfs dmraid f2fs fat hfs jfs kde mdadm ntfs policykit reiserfs reiser4 xfs )

CDEPEND_A=(
	">=dev-cpp/glibmm-2.14:2"
	">=dev-cpp/gtkmm-2.22:2.4"
	">=dev-libs/glib-2:2"
	">=sys-block/parted-3.2:="
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"kde? ( kde-plasma/kde-cli-tools[kdesu] )"

	">=sys-apps/util-linux-2.20"
	">=sys-fs/e2fsprogs-1.41"
	"btrfs? ( sys-fs/btrfs-progs )"
	"dmraid? ("
		">=sys-fs/lvm2-2.02.45"
		"sys-fs/dmraid"
		"sys-fs/multipath-tools"
	")"
	"f2fs? ( sys-fs/f2fs-tools )"
	"fat? ("
		"sys-fs/dosfstools"
		"sys-fs/mtools"
	")"
	"hfs? ("
		"sys-fs/diskdev_cmds"
		"virtual/udev"
		"sys-fs/hfsutils"
	")"
	"jfs? ( sys-fs/jfsutils )"
	"mdadm? ( sys-fs/mdadm )"
	"ntfs? ( >=sys-fs/ntfs3g-2011.4.12[ntfsprogs] )"
	"reiserfs? ( sys-fs/reiserfsprogs )"
	"reiser4? ( sys-fs/reiser4progs )"
	"xfs? ( sys-fs/xfsprogs sys-fs/xfsdump )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"app-text/docbook-xml-dtd:4.1.2"
	"app-text/gnome-doc-utils"
	"dev-util/intltool"
	"sys-devel/gettext"
	"virtual/pkgconfig"
)

inherit arrays

S="${WORKDIR}/${MY_P}"

src_prepare() {
	eapply_user

	esed -e 's:Exec=@gksuprog@ :Exec=:' -i -- gparted.desktop.in.in
	esed -e "/^ *polkit_action_DATA/ s,=.*,=," -i -- Makefile.am

	gnome2_src_prepare
}

src_configure() {
	local my_econf_args=(
		$(use_enable doc)
		$(use_enable nls)
		--enable-online-resize
		--disable-scrollkeeper
		$(use_enable libparted-dmraid)
		GKSUPROG=$(type -P true)
	)
	gnome2_src_configure "${my_econf_args[@]}"
}

src_install() {
	gnome2_src_install

	local _ddir="${ED}"/usr/share/applications

	if use kde ; then
		ecp "${_ddir}"/gparted{,-kde}.desktop
		esed -e 's:Exec=:Exec=kdesu5 :' -i -- "${_ddir}"/gparted-kde.desktop
		echo 'OnlyShowIn=KDE;' >> "${_ddir}"/gparted-kde.desktop
		echo 'NotShowIn=KDE;' >> "${_ddir}"/gparted.desktop
	fi
}
