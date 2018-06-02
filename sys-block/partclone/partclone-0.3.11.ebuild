# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:Thomas-Tsai"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## functions: eautoreconf
inherit autotools

DESCRIPTION="Partition clone and restore tool similar to partimage"
HOMEPAGE="http://www.partclone.org/ ${HOMEPAGE}"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
	nls +tui static debug test

	# filesystems
	btrfs exfat +extfs f2fs +fat jfs minix nilfs2 +ntfs reiser4 reiserfs xfs
	# ufs # no support on amd64/arm
	# hfsp # no support on amd64/arm
	# vmfs # requires vmfs-tools, currently not present in gentoo repos
)

# deps specified in `<root>/INSTALL`
CDEPEND_A=(
	# libblkid, libuuid, ...
	"sys-apps/util-linux"

	"nls? ( sys-devel/gettext )"
	"tui? ( sys-libs/ncurses:*[unicode] )"

	"btrfs?	( sys-fs/btrfs-progs )"
	"exfat?	( sys-fs/fuse-exfat )"
	"extfs?	( sys-libs/e2fsprogs-libs )"
	"f2fs?	( sys-fs/f2fs-tools )"
# 	"hfsp?	( sys-fs/hfsplusutils )"  # see IUSE comment
	"jfs?	( sys-fs/jfsutils )"
	"nilfs2?	( >=sys-fs/nilfs-utils-2 )"
	"ntfs?	( sys-fs/ntfs3g[ntfsprogs] )"
	"reiser4?	( sys-fs/reiser4progs )"
	"reiserfs?	( sys-fs/progsreiserfs )"
# 	"ufs?	( sys-fs/ufsutils )"  # see IUSE comment
	"xfs?	( sys-fs/xfsprogs )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE=""
RESTRICT+=""

inherit arrays

src_prepare() {
	eapply_user

	eautoreconf
}

src_configure() {
	local econfargs=(
		$(use_enable nls)
		$(use_enable tui ncursesw)	# enable TEXT User Interface
		$(use_enable static)	# enable static linking
		$(use_enable debug mtrace)	# enable memory tracing
		$(use_enable test fs-test)	# enable file system clone/restore test

		$(use_enable btrfs)		# enable btrfs file system
		$(use_enable exfat)		# enable EXFAT file system
		$(use_enable extfs)		# enable ext2/3/4 file system
		$(use_enable f2fs)		# enable f2fs file system
		$(use_enable fat)		# enable FAT file system
# 		$(use_enable hfsp)		# enable HFS plus file system  # see IUSE comment
		$(use_enable jfs)		# enable jfs file system
		$(use_enable minix)		# enable minix file system
		$(use_enable nilfs2)	# enable nilfs2 file system
		$(use_enable ntfs)		# enable NTFS file system
		$(use_enable reiser4)	# enable Reiser4 file system
		$(use_enable reiserfs)	# enable REISERFS 3.6/3.6 file system
# 		$(use_enable ufs)		# enable UFS(1/2) file system  # see IUSE comment
# 		$(use_enable vmfs)		# enable vmfs file system  # see IUSE comment
		$(use_enable xfs)		# enable XFS file system
	)

	use ntfs && einfo "Please ignore ntfsprogs warnings, they're false positives"
	use tui && einfo "Please ignore tinfo warnings, they're false positives"

	econf "${econfargs[@]}"
}

DOCS=(
	README.md NEWS AUTHORS
	# dumb git log
# 	ChangeLog
)
