# Copyright 1999-2018 Gentoo Foundation
# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## functions: eautoreconf
inherit autotools
## functions: filter-lfs-flags, append-cppflags
inherit flag-o-matic
## functions: makeopts_jobs
inherit multiprocessing
## functions: host-is-pax
inherit pax-utils

DESCRIPTION="sandbox'd LD_PRELOAD hack"
HOMEPAGE="https://gitweb.gentoo.org/proj/${PN}.git https://wiki.gentoo.org/wiki/Project:Sandbox"
LICENSE="GPL-2"

SLOT="0"
SRC_URI="https://gitweb.gentoo.org/proj/${PN}.git/snapshot/${P}.tar.bz2"

KEYWORDS="amd64 arm arm64"
IUSE_A=( +ptrace )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"app-arch/xz-utils"
	">=app-misc/pax-utils-0.1.19" #265376
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

RESTRICT+=" mirror"

inherit arrays

has sandbox_death_notice ${EBUILD_DEATH_HOOKS} || EBUILD_DEATH_HOOKS="${EBUILD_DEATH_HOOKS} sandbox_death_notice"

sandbox_death_notice() {
	ewarn "If configure failed with a 'cannot run C compiled programs' error, try this:"
	ewarn "FEATURES='-sandbox -usersandbox' emerge sandbox"
}

src_prepare() {
	eapply_user

	eautoreconf
}

src_configure() {
	filter-lfs-flags #90228
	use ptrace || append-cppflags -DSB_NO_TRACE

	local myconf=()
	host-is-pax && myconf+=( --disable-pch ) #301299 #425524 #572092

	ECONF_SOURCE="${S}" \
	econf "${myconf[@]}"
}

src_test() {
	# Default sandbox build will run with --jobs set to # cpus.
	emake check TESTSUITEFLAGS="--jobs=$(makeopts_jobs)"
}

src_install() {
	default

	doenvd "${FILESDIR}"/09sandbox

	keepdir /var/log/sandbox
	fowners root:portage /var/log/sandbox
	fperms 0770 /var/log/sandbox
}

pkg_preinst() {
	echown root:portage "${ED}"/var/log/sandbox
	echmod 0770 "${ED}"/var/log/sandbox

	local v
	for v in ${REPLACING_VERSIONS} ; do
		if [[ ${v} == 1.* ]] ; then
			local old=$(find "${EROOT}"/lib* -maxdepth 1 -name 'libsandbox*')
			if [[ -n ${old} ]] ; then
				elog "Removing old sandbox libraries for you:"
				find "${EROOT}"/lib* -maxdepth 1 -name 'libsandbox*' -print -delete
			fi
		fi
	done
}

pkg_postinst() {
	local v
	for v in ${REPLACING_VERSIONS} ; do
		if [[ ${v} == 1.* ]] ; then
			echmod 0755 "${EROOT}"/etc/sandbox.d #265376
		fi
	done
}
