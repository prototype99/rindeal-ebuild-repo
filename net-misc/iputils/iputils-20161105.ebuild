# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github"
GH_REF="s${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## functions: append-ldflags
inherit flag-o-matic
## functions: tc-export
inherit toolchain-funcs
## functions: fcaps
inherit fcaps
# functions: rindeal:dsf:eval
inherit rindeal-utils

DESCRIPTION="Network monitoring tools including ping and ping6"
HOMEPAGE="https://wiki.linuxfoundation.org/networking/iputils ${GH_HOMEPAGE}"
LICENSE="BSD GPL-2+ rdisc"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
	+arping caps clockdiff doc man gcrypt idn ipv6 libressl nettle +openssl rarpd rdisc SECURITY_HAZARD ssl static tftpd tracepath traceroute
)

LIB_DEPEND="
	caps? ( sys-libs/libcap[static-libs(+)] )
	idn? ( net-dns/libidn[static-libs(+)] )
	ipv6? (
		ssl? (
			gcrypt? ( dev-libs/libgcrypt:0=[static-libs(+)] )
			nettle? ( dev-libs/nettle[static-libs(+)] )
			openssl? ( dev-libs/openssl:0[static-libs(+)] )
		)
	)
"
CDEPEND_A=(
	"arping? ( !net-misc/arping )"
	"rarpd? ( !net-misc/rarpd )"
	"traceroute? ( !net-analyzer/traceroute )"
	"!static? ( ${LIB_DEPEND//\[static-libs(+)]} )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"static? ( ${LIB_DEPEND} )"
	"virtual/os-headers"
	"$(rindeal:dsf:eval \
		'doc | man' \
			"app-text/openjade
			dev-perl/SGMLSpm
			app-text/docbook-sgml-dtd
			app-text/docbook-sgml-utils" )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"ipv6? ("
		"ssl? ("
			"^^ ("
				"gcrypt"
				"nettle"
				"openssl"
			")"
		")"
	")"
)

inherit arrays

src_prepare() {
	eapply "${FILESDIR}/021109-uclibc-no-ether_ntohost.patch"
	use SECURITY_HAZARD && \
		eapply "${FILESDIR}"/${PN}-20150815-nonroot-floodping.patch
	eapply_user
}

src_configure() {
	use static && \
		append-ldflags -static

	TARGETS=(
		ping
		$(usev arping)
		$(usev clockdiff)
		$(usev rarpd)
		$(usev rdisc)
		$(usev tftpd)
		$(usev tracepath)
	)
	if use ipv6 ; then
		TARGETS+=(
			$(usex tracepath 'tracepath6' '')
			$(usex traceroute 'traceroute6' '')
		)
	fi

	MYCONF=()

	if use ipv6 && use ssl ; then
		MYCONF+=(
			USE_CRYPTO=$(usex openssl)
			USE_GCRYPT=$(usex gcrypt)
			USE_NETTLE=$(usex nettle)
		)
	else
		MYCONF+=(
			USE_CRYPTO=no
			USE_GCRYPT=no
			USE_NETTLE=no
		)
	fi
}

src_compile() {
	tc-export CC
	myemake=(
		emake
		USE_CAP=$(usex caps)
		USE_IDN=$(usex idn)
		IPV4_DEFAULT=$(usex ipv6 'no' 'yes')
		TARGETS="${TARGETS[*]}"
		"${MYCONF[@]}"
	)
	"${myemake[@]}"

	use doc && emake html
	use man && emake man
}

src_install() {
	### /
	into /

	dobin ping
	dosym ping /bin/ping4
	if use ipv6 ; then
		dosym ping /bin/ping6
		use man && dosym ping.8 /usr/share/man/man8/ping6.8
	fi
	use man && doman doc/ping.8

	if use arping ; then
		dobin arping
		use man && doman doc/arping.8
	fi

	### /usr
	into /usr

	local u
	for u in clockdiff rarpd rdisc tftpd tracepath ; do
		if use ${u} ; then
			case ${u} in
			clockdiff) dobin ${u};;
			*) dosbin ${u};;
			esac
			use man && doman doc/${u}.8
		fi
	done

	if use tracepath && use ipv6 ; then
		dosbin tracepath6
		use man && dosym tracepath.8 /usr/share/man/man8/tracepath6.8
	fi

	if use traceroute && use ipv6 ; then
		dosbin traceroute6
		use man && doman doc/traceroute6.8
	fi

	if use rarpd ; then
		newinitd "${FILESDIR}"/rarpd.init.d rarpd
		newconfd "${FILESDIR}"/rarpd.conf.d rarpd
	fi

	dodoc INSTALL.md RELNOTES

	if use doc ; then
		docinto html
		dodoc doc/*.html
	fi
}

pkg_postinst() {
	fcaps cap_net_raw \
		bin/ping \
		$(usex arping 'bin/arping' '') \
		$(usex clockdiff 'usr/bin/clockdiff' '')
}
