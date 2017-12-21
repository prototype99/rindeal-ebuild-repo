# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:ckolivas"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## functions: tc-getCC
inherit toolchain-funcs

DESCRIPTION="Con Kolivas' Benchmarking Suite - Successor to Contest"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"

src_prepare() {
	default

	# "Fix numerous compile issues. Fix cpu calibration being unstable without affinity. Fix affinity. Determine processors automatically."
	# https://github.com/ckolivas/interbench/commit/718667cb5dbc92e9142de61ed7fbdfa227ac788b
	eapply "${FILESDIR}"/718667cb5dbc92e9142de61ed7fbdfa227ac788b.patch

	# do not hardcode sched_priority (taken from FreeBSD Ports)
	sed -e 's|sched_priority = 99|sched_priority = sched_get_priority_max(SCHED_FIFO)|' \
		-e 's|set_fifo(96)|set_fifo(sched_get_priority_max(SCHED_FIFO) - 1)|' \
		-e 's|\(set_thread_fifo(thi->pthread,\) 95|\1 sched_get_priority_max(SCHED_FIFO) - 1|' \
		-i -- ${PN}.c || die
}

src_compile() {
	emake CC="$(tc-getCC)" CFLAGS="${CFLAGS}"
}

src_install() {
	dobin ${PN}
	doman ${PN}.8

	dodoc readme*
}

pkg_postinst() {
	einfo
	einfo "For best and consistent results, it is recommended to boot to init level 1 or"
	einfo "use telinit 1. See documentation or ${HOMEPAGE} for more info."
	einfo
}
