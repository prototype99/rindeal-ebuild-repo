# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

if [[ "${PV}" == *9999* ]] ; then
	EGIT_REPO_URI="https://git.savannah.gnu.org/r/${PN}.git"
	EGIT_SUBMODULES=()
	EGIT_CLONE_TYPE="shallow"

	## EXPORT_FUNCTIONS: src_unpack
	inherit git-r3
else
	## EXPORT_FUNCTIONS: src_unpack
	inherit vcs-snapshot

	git_ref="b86c332541eb5f2e9de073cbde4c8bb9776497d9" # 2017-11-24
	SRC_URI="https://git.savannah.gnu.org/gitweb/?p=${PN}.git;a=snapshot;h=${git_ref};sf=tgz -> ${PF}.tar.gz"
	RESTRICT+=" mirror"
fi

DESCRIPTION="Library of common routines intended to be shared at the source level"
HOMEPAGE="https://www.gnu.org/software/${PN}"
LICENSE="GPL-2"

SLOT="0"

[[ "${PV}" == *9999* ]] || \
	KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( doc )

inherit arrays

src_compile() {
	if use doc ; then
		emake -C doc info html
	fi
}

src_install() {
	einstalldocs

	local inst_dir="/usr/share/${PN}"

	## install data
	## NOTE: this will take some time as it's ~10k inodes
	insinto "${inst_dir}"
	doins -r build-aux
	doins -r doc # required for `gnulib-tool`
	doins -r lib
	doins -r m4
	doins -r modules
	doins -r tests # required for `gnulib-tool`
	doins -r top

	## install gnulib script
	exeinto "${inst_dir}"
	doexe gnulib-tool
	dosym {/usr/share/${PN},/usr/bin}/gnulib-tool
}
