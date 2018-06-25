# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github"
GH_REF="curl-${PV//./_}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## functions: rindeal:dsf:eval, rindeal:dsf:prefix_flags
inherit rindeal-utils
## functions: eautoreconf
inherit autotools
## functions: prune_libtool_files
inherit ltprune
## functions: eprefixify
inherit prefix

DESCRIPTION="Command line tool and library for transferring data with URLs"
HOMEPAGE="https://curl.haxx.se/ ${GH_HOMEPAGE}"
LICENSE="MIT"

SLOT="0"

KEYWORDS="amd64 arm arm64"
IUSE_A=(
	curldebug +largefile libgcc +rt +symbol-hiding versioned-symbols static-libs test threads
	
	#improve compatibility with external packages referencing these official use flags
	curl_ssl_axtls curl_ssl_gnutls curl_ssl_libressl curl_ssl_mbedtls curl_ssl_nss curl_ssl_openssl

	libcurl-option manual +verbose

	ipv6 +unix-sockets +zlib brotli dns_c-ares dns_threaded idn psl

	+cookies metalink proxy libssh2 libssh

	$(rindeal:dsf:prefix_flags \
		"auth_" \
		+digest gssapi kerberos ntlm ntlm-wb spnego tls-srp)

	$(rindeal:dsf:prefix_flags \
		"protocol_" \
		+http +https http2 +ftp +ftps +file telnet ldap ldaps dict tftp gopher pop3 pop3s imap imaps \
		smb smbs smtp smtps rtsp rtmp scp sftp)

	+ssl
	$(rindeal:dsf:prefix_flags \
		"ssl_" \
		axtls gnutls libressl mbedtls nss +openssl)
)

# tests lead to lots of false negatives, bug gentoo#285669
RESTRICT+=" test"

CDEPEND_A=(
	"protocol_ldap? ( net-nds/openldap )"
	"ssl? ("
		"$(rindeal:dsf:eval \
			"ssl_openssl|ssl_libressl|ssl_gnutls" \
				"app-misc/ca-certificates")"

		"ssl_axtls?		( net-libs/axtls )"
		"ssl_gnutls?	("
			"net-libs/gnutls:0=[static-libs?]"
			"dev-libs/nettle:0="
		")"
		"ssl_libressl?	( dev-libs/libressl:0=[static-libs?] )"
		"ssl_mbedtls?	( net-libs/mbedtls:0= )"
		"ssl_openssl?	( dev-libs/openssl:0=[static-libs?] )"
		"ssl_nss?		( dev-libs/nss:0 )"
	")"
	"protocol_http2?	( net-libs/nghttp2 )"
	"idn?				( net-dns/libidn2:0[static-libs?] )"
	"dns_c-ares?		( net-dns/c-ares:0 )"
	"auth_kerberos?		( >=virtual/krb5-0-r1 )"
	"metalink?			( >=media-libs/libmetalink-0.1.1 )"
	"protocol_rtmp?		( media-video/rtmpdump )"
	"libssh2?			( net-libs/libssh2[static-libs?] )"
	"libssh?			( net-libs/libssh[static-libs?] )"
	"zlib?				( sys-libs/zlib )"
	"brotli?			( app-arch/brotli )"
	"protocol_ldap?		( net-nds/openldap )"
	"protocol_ldaps?	( net-nds/openldap[ssl] )"
	"psl?				( net-libs/libpsl )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
	"test? ("
		"sys-apps/diffutils"
		"dev-lang/perl"
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"?? ( dns_threaded dns_c-ares )"
	# `if test "$want_pthreads" = "yes" && test "$dontwant_rt" = "yes"; then AC_MSG_ERROR`
	"?? ( threads !rt )"
	# `dnl turn off pthreads if no threaded resolver	`
	"threads? ( dns_threaded )"
	"ssl? ("
		"|| ("
			$(rindeal:dsf:prefix_flags \
				"ssl_" \
				axtls gnutls libressl mbedtls nss openssl)
		")"
	")"
	"?? ( libssh2 libssh )"

	"auth_kerberos?	( auth_digest auth_gssapi )"
	"auth_ntlm-wb?	( auth_ntlm protocol_http )"
	"auth_ntlm?		( auth_digest ssl )"
	"auth_spnego?	( || ( auth_digest auth_gssapi ) )"

	"protocol_https?	( protocol_http ssl )"
	"protocol_ftps?		( protocol_ftp ssl )"
	"protocol_ldaps?	( protocol_ldap )"
	"protocol_pop3s?	( protocol_pop3 ssl )"
	"protocol_imaps?	( protocol_imap ssl )"
	"protocol_smb?		( auth_digest ^^ ( $(rindeal:dsf:prefix_flags "ssl_" openssl libressl gnutls nss) ) )"
	"protocol_smbs?		( protocol_smb ssl )"
	"protocol_smtps?	( protocol_smtp ssl )"
	"protocol_scp?		( || ( libssh2 libssh ) )"
	"protocol_sftp?		( || ( libssh2 libssh ) )"
	#ensure these use flags have the intended effect
	"curl_ssl_axtls? 	( ssl_axtls ) !curl_ssl_axtls? ( !ssl_axtls )"
	"curl_ssl_gnutls? 	( ssl_gnutls ) !curl_ssl_gnutls? ( !ssl_gnutls )"
	"curl_ssl_libressl? 	( ssl_libressl ) !curl_ssl_libressl? ( !ssl_libressl )"
	"curl_ssl_mbedtls? 	( ssl_mbedtls ) !curl_ssl_mbedtls? ( !ssl_mbedtls )"
	"curl_ssl_nss? 		( ssl_nss ) !curl_ssl_nss? ( !ssl_nss )"
	"curl_ssl_openssl? 	( ssl_openssl ) !curl_ssl_openssl? ( !ssl_openssl )"
)

inherit arrays

src_prepare() {
	eapply "${FILESDIR}/${PN}-7.30.0-prefix.patch"
	eapply "${FILESDIR}/${PN}-respect-cflags-3.patch"
	eapply "${FILESDIR}/${PN}-fix-gnutls-nettle.patch"
	eapply_user

	eprefixify curl-config.in

	eautoreconf
}

src_configure() {
	local my_econf_args=(
		--disable-debug # just sets -g* flags
		--disable-optimize # just sets -O* flags
		--enable-warnings
		--disable-werror
		--disable-soname-bump
		--with-zsh-functions-dir="${EPREFIX}"/usr/share/zsh/site-functions

		$(use_enable	curldebug)
		$(use_enable	largefile)
		$(use_enable	libgcc)
		$(use_enable	rt)
		$(use_enable	symbol-hiding)
		$(use_enable	versioned-symbols)
		$(use_enable	static-libs static)
		# --with-pic=yes|no|default

		$(use_enable	libcurl-option)
		$(use_enable	manual)
		$(use_enable	verbose)

		$(use_enable	ipv6)
		$(use_enable	unix-sockets)
		$(use_with		zlib)
		$(use_with		brotli)
		$(use_enable	dns_c-ares ares) # =PATH
		$(use_enable	dns_threaded threaded-resolver)
		$(use_with		idn libidn2)
		$(use_with		psl libpsl)

		$(use_enable	cookies)
		$(use_with		metalink libmetalink)
		$(use_enable	proxy)
		$(use_with		libssh2)
		$(use_with		libssh)
	)

	my_econf_args+=(
		"$(use_with		auth_gssapi		gssapi "${EPREFIX}"/usr)"
		$(use_enable	auth_ntlm-wb	ntlm-wb)
		$(use_enable	auth_tls-srp	tls-srp)
		$(use_enable	auth_digest		crypto-auth)
	)

	### Protocols
	myprotouse() {
		use_$1 protocol_$2 ${3:-${2}}
	}
	my_econf_args+=(
		$(myprotouse enable	http)
		$(myprotouse with	http2 nghttp2)
		$(myprotouse enable	ftp)
		$(myprotouse enable	file)
		$(myprotouse enable	telnet)
		$(myprotouse enable	ldap)
		$(myprotouse enable	ldaps)
		$(myprotouse enable	dict)
		$(myprotouse enable	tftp)
		$(myprotouse enable	gopher)
		$(myprotouse enable	pop3)
		$(myprotouse enable	imap)
		$(myprotouse enable	smb)
		$(myprotouse enable	smtp)
		$(myprotouse enable	rtsp)
		$(myprotouse with	rtmp librtmp)
	)

	### SSL
	my_use_ssl() {
		usex ssl ssl_$1 ssl
	}
	my_econf_args+=(
		# "Don't use the built in CA store of the SSL library"
		--without-ca-fallback
		--with-ca-bundle="${EPREFIX}"/etc/ssl/certs/ca-certificates.crt
		--without-winssl	# disable Windows native SSL/TLS
		--without-darwinssl	# disable Apple OS native SSL/TLS
		--without-winidn	# disable Windows native IDN

		$(use_with $(my_use_ssl axtls)		axtls)
		$(use_with $(my_use_ssl gnutls)		gnutls)
		$(use_with $(my_use_ssl gnutls)		nettle)
		$(use_with $(my_use_ssl libressl)	ssl)
		$(use_with $(my_use_ssl mbedtls)	mbedtls)
		$(use_with $(my_use_ssl nss)		nss)
		$(use_with $(my_use_ssl openssl)	ssl)
		# TODO: --with-wolfssl as an alias for --with-cyassl
	)
	if use ssl_openssl || use ssl_libressl || use ssl_gnutls ; then
		my_econf_args+=( --with-ca-path="${EPREFIX}"/etc/ssl/certs )
	else
		my_econf_args+=( --without-ca-path )
	fi

	econf "${my_econf_args[@]}"

	## Fix up the pkg-config file to be more robust.
	## https://github.com/curl/curl/issues/864
	local priv=() libs=()
	if use zlib ; then
		libs+=( "-lz" )
		priv+=( "zlib" )
	fi
	if use protocol_http2 ; then
		libs+=( "-lnghttp2" )
		priv+=( "libnghttp2" )
	fi
	if use ssl_openssl ; then
		libs+=( "-lssl" "-lcrypto" )
		priv+=( "openssl" )
	fi
	grep -q Requires.private libcurl.pc && die "need to update ebuild"
	libs=$(printf '|%s' "${libs[@]}")
	esed -r -e "/^Libs.private/s:(${libs#|})( |$)::g" \
		-i -- libcurl.pc
	echo "Requires.private: ${priv[*]}" >> libcurl.pc
}

src_install() {
	emake DESTDIR="${D}" install

	local DOCS=( CHANGES README docs/FEATURES docs/INTERNALS.md
		docs/MANUAL docs/FAQ docs/BUGS docs/CONTRIBUTE.md )
	einstalldocs

	prune_libtool_files
}
