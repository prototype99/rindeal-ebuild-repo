# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN='github:ssvb'
[[ "${PV}" == *9999* ]] || \
	GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## functions: append-flags
inherit flag-o-matic

DESCRIPTION="Simple benchmark for memory throughput and latency"
LICENSE="MIT"

SLOT="0"

[[ "${PV}" == *9999* ]] || \
	KEYWORDS="amd64 arm arm64"

src_prepare() {
	# https://wiki.gentoo.org/wiki/Hardened/GNU_stack_quickstart
	append-flags '-Wa,--noexecstack'

	default
}

src_install() {
	dobin "${PN}"
}
