# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="gitlab:gnuwget"
## git-r3.eclass (part of git-hosting.eclass):
EGIT_SUBMODULES=()

## functions: rindeal:dsf:eval rindeal:dsf:prefix_flags
inherit rindeal-utils
## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## functions: eautoreconf
inherit autotools
## functions: prune_libtool_files
inherit ltprune

DESCRIPTION="Successor of GNU Wget, a file and recursive website downloader."
LICENSE_A=(
	"GPL-3+" # wget2
	"LGPL-3+" # libwget
)

SLOT="0"

[[ "${PV}" == *9999* ]] || \
	KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
	nls static-libs assert xattr doc test
	+openssl +gnutls

	$(rindeal:dsf:prefix_flags 'compression_' \
		bzip2 +zlib lzma brotli)

	+libpsl
	nghttp2
	libidn libidn2
	libpcre libpcre2
	plugin-support
	gpgme
)

RESTRICT+=""

CDEPEND_A=(
	"nls? ( sys-devel/gettext )"

	"compression_bzip2? ( app-arch/bzip2:0 )"
	"compression_zlib? ( sys-libs/zlib:0 )"
	"compression_lzma? ( app-arch/xz-utils:0 )"
	"compression_brotli? ( app-arch/brotli:0 )"

	"openssl? ( dev-libs/openssl:0 )"
	"gnutls? ( net-libs/gnutls:0 )"
	"nghttp2? ( net-libs/nghttp2:0 )"
	"libpsl? ( net-libs/libpsl:0 )"

	"libidn? ( net-dns/libidn:0 )"
	"libidn2? ( net-dns/libidn2:0 )"

	"libpcre? ( dev-libs/libpcre:0 )"
	"libpcre2? ( dev-libs/libpcre2:0 )"

	"$(rindeal:dsf:eval \
		'libidn|libidn2' \
			'virtual/libiconv' )"

	"gpgme? ( app-crypt/gpgme )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-libs/gnulib"
	"sys-devel/flex"
	"test? ( net-libs/libmicrohttpd )"
	"virtual/pkgconfig"
	"sys-devel/libtool"
	"doc? ("
		"app-doc/doxygen"
		"|| ("
			"app-text/pandoc-bin"
			"app-text/pandoc"
		")"
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"?? ( libidn libidn2 )"
	"?? ( libpcre libpcre2 )"
)

inherit arrays

src_prepare() {
	eapply_user

	# lzip is only needed for tarball generation
	esed -e "/^lzip/d" -i -- bootstrap.conf

	esed -e "/^SUBDIRS/ s|\bexamples\b||" -i -- Makefile.am

	esed -e "/^bin_PROGRAMS/ s|wget2_noinstall||" -e "/^wget2_noinstall/d" -i -- src/Makefile.am

	./bootstrap --no-git --gnulib-srcdir="${EROOT}"/usr/share/gnulib $(usex nls '' '--skip-po') || die

	eautoreconf
}

src_configure() {
	local my_econf_args=(
		--disable-rpath
		$(use_enable static-libs static)
		$(use_enable assert)
		$(use_enable nls)
		$(use_enable doc)
		$(use_enable xattr)

		$(use_with openssl)
		$(use_with gnutls)
		$(use_with libpsl)
		$(use_with nghttp2 libnghttp2)

		$(use_with {compression_,}bzip2)
		$(use_with {compression_,}zlib)
		$(use_with {compression_,}lzma)
		$(use_with compression_brotli brotlidec)

		$(use_with libidn2)
		$(use_with libidn)
		$(use_with libpcre2)
		$(use_with libpcre)
		$(use_with test libmicrohttpd) # build tests requiring libmicrohttpd
		$(use_with plugin-support)
		$(use_with gpgme)
	)

	econf "${my_econf_args[@]}"
}

src_install() {
	emake DESTDIR="${D}" install

	einstalldocs

	prune_libtool_files
}
