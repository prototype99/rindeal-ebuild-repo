# Copyright 1999-2017 Gentoo Foundation
# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="gitlab:procps-ng"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## functions: eautoreconf
inherit autotools
## functions: append-lfs-flags
inherit flag-o-matic
## functions: gen_usr_ldscript
inherit toolchain-funcs
## functions: prune_libtool_files
inherit ltprune

DESCRIPTION="standard informational utilities and process-handling tools"
LICENSE="GPL-2"

SLOT="0/6"  # libprocps.so

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
	test

	### Optional Features:
	+largefile +shared-libs static-libs nls +rpath unicode selinux +pidof +kill examples sigwinch
	wide-percent +wide-memory modern-top numa w-from +whining
	### Optional Packages:
	gnu-ld +ncurses systemd
)

CDEPEND_A=(
	"ncurses? ( >=sys-libs/ncurses-5.7-r7:=[unicode?] )"
	"selinux? ( sys-libs/libselinux )"
	"systemd? ( sys-apps/systemd )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
	"test? ( dev-util/dejagnu )"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"kill? ("
		"!sys-apps/coreutils[kill]"
		"!sys-apps/util-linux[kill]"
	")"
	"!<sys-apps/sysvinit-2.88-r6"
)

inherit arrays

src_prepare() {
	eapply "${FILESDIR}"/${PN}-3.3.8-kill-neg-pid.patch # http://crbug.com/255209
	eapply "${FILESDIR}"/${PN}-3.3.11-sysctl-manpage.patch # 565304
	eapply "${FILESDIR}"/${PN}-3.3.12-proc-tests.patch # 583036

	eapply_user

	# required for successful Makefile generation; taken from autogen.sh
	po/update-potfiles || die

	eautoreconf
}

src_configure() {
	# http://www.freelists.org/post/procps/PATCH-enable-transparent-large-file-support
	append-lfs-flags #471102

	local my_econf_args=(
		### Fine tuning of the installation directories:
		--docdir='$(datarootdir)'/doc/${PF}

		### Optional Features:
		$(use_enable largefile)
		$(use_enable shared-libs shared)
		$(use_enable static-libs static)
		$(use_enable nls)
		$(use_enable rpath)
		$(use_enable unicode watch8bit)
		$(use_enable selinux libselinux)
		$(use_enable pidof)
		$(use_enable kill)
		--disable-skill # obsolete tools
		$(use_enable examples)
		$(use_enable sigwinch)
		$(use_enable wide-percent)
		$(use_enable wide-memory)
		$(use_enable modern-top)
		$(use_enable numa)
		$(use_enable w-from)
		$(use_enable whining)

		### Optional Packages:
		$(use_with gnu-ld)
		$(use_with ncurses)
		$(use_with systemd)
	)

	econf "${my_econf_args[@]}"
}

src_test() {
	emake check </dev/null #461302
}

src_install() {
	default
	#dodoc sysctl.conf

	dodir /bin
	emv "${ED}"/usr/bin/ps "${ED}"/bin/
	if use kill ; then
		emv "${ED}"/usr/bin/kill "${ED}"/bin/
	fi

	gen_usr_ldscript -a procps

	prune_libtool_files
}
