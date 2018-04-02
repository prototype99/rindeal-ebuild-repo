# Copyright 1999-2018 Gentoo Foundation
# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:vaeth"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
inherit bash-completion-r1
inherit flag-o-matic
inherit tmpfiles
## EXPORT_FUNCTIONS: src_configure src_compile src_test src_install
inherit meson

DESCRIPTION="Search and query ebuilds"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
	debug doc nls sqlite
	+jumbo-build debug-format
)

CDEPEND_A=(
	"nls? ( virtual/libintl )"
	"sqlite? ( dev-db/sqlite:3= )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"app-arch/xz-utils"
	"nls? ( sys-devel/gettext )"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"app-shells/push"
	"app-shells/quoter"
)

inherit arrays

pkg_setup() {
	# remove stale cache file to prevent collisions
	erm -f "${EROOT%/}/var/cache/${PN}"
}

src_prepare() {
	eapply_user

	# - append `/var/cache/eix/portage.eix` to tmpfiles
	# - expand eprefix
	esed \
		-e "$ a f /var/cache/eix/portage.eix 0664 portage portage -" \
		-e "s, /, ${EPREFIX}/," \
		-i -- tmpfiles.d/eix.conf
	#
	esed \
		-e "/eixf_source=/ s,push.sh,cat '${EROOT}usr/share/push/push.sh'," \
		-e "/eixf_source=/ s,quoter_pipe.sh,cat '${EROOT}usr/share/quoter/quoter_pipe.sh'," \
		-i -- src/eix-functions.sh.in
# 	esed -e "s:'\$(bindir)/eix-functions.sh':cat '${EROOT}usr/share/eix/eix-functions':" -i -- src/Makefile.am
}

src_configure() {
	# https://github.com/vaeth/eix/issues/35
	append-cxxflags -std=c++11

	local emesonargs=(
		-Ddocdir="${EPREFIX}/usr/share/doc/${P}"
		-Dhtmldir="${EPREFIX}/usr/share/doc/${P}/html"

		### used purely to control/disrespect *FLAGS
		--disable-debugging
		--disable-new-dialect
		--disable-optimization
		--disable-strong-optimization
		--disable-security
		--disable-nopie-security
		--disable-strong-security

		### Optional Features:
		$(use_enable jumbo-build)
		# --enable-debugging  # handled else
		$(use_enable debug paranoic-asserts)
		$(use_enable debug-format)
		# --enable-new-dialect
		--disable-dead-code-eliminitation

		$(use_enable nls)
		$(use_with doc extra-doc)
		$(use_with sqlite)

		# default configuration
		$(use_with prefix always-accept-keywords)
		--with-dep-default
		--with-required-use-default

		# paths
		--with-portage-rootpath="${ROOTPATH}"
		--with-eprefix-default="${EPREFIX}"

		# build a single executable with symlinks
		--disable-separate-binaries
		--disable-separate-tools


	)

	meson_src_configure
}

src_install() {
	default
	dobashcomp bash/eix
	dotmpfiles tmpfiles.d/eix.conf

	erm -r "${ED%/}"/usr/bin/eix-functions.sh
}

pkg_postinst() {
	if ! use prefix ; then
		# note: if this is done in src_install(), portage:portage
		# ownership may be reset to root
		tmpfiles_process eix.conf
	fi

	local obs="${EROOT%/}/var/cache/eix.previous"
	if [[ -f ${obs} ]]; then
		ewarn "Found obsolete ${obs}, please remove it"
	fi
}

pkg_postrm() {
	if [[ ! -n ${REPLACED_BY_VERSION} ]]; then
		erm -rf "${EROOT%/}/var/cache/${PN}"
	fi
}
