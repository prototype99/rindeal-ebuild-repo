# Copyright 1999-2018 Gentoo Foundation
# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:balabit"
GH_REF="${P}"

## python-*.eclass:
# python3 support is tracked here https://github.com/balabit/syslog-ng/issues/1832
PYTHON_COMPAT=( python2_7 )

## variables: EPYTHON
inherit python-utils-r1

## EXPORT_FUNCTIONS: pkg_setup
inherit python-single-r1

## EXPORT_FUNCTIONS: src_unpack
## variables: GH_HOMEPAGE
inherit git-hosting

## functions: eautoreconf
inherit autotools

## functions: systemd_get_systemunitdir
inherit systemd

## functions: prune_libtool_files
inherit ltprune

## functions: rindeal:expand_vars
inherit rindeal-utils

DESCRIPTION="syslog replacement with advanced filtering features"
HOMEPAGE="https://syslog-ng.com/ ${GH_HOMEPAGE}"
LICENSE="GPL-2+ LGPL-2.1+"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( doc test

	debug env-wrapper memtrace ipv6 tcpd spoof-source sql pacct caps mongodb json amqp stomp smtp
	http redis systemd geoip2 python man native largefile valgrind +systemd-journal
)

CDEPEND_A=(
	"tcpd? ( >=sys-apps/tcp-wrappers-7.6 )"
	"sql? ( dev-db/libdbi )"
	"dev-libs/glib:2"
	"geoip2? ( dev-libs/libmaxminddb )"
	"dev-libs/libpcre"
	"dev-libs/openssl:0="
	"spoof-source? ( net-libs/libnet:1.1 )"
	"dev-libs/ivykis"
	"json? ( dev-libs/json-c:= )"
	"mongodb? ( >dev-libs/mongo-c-driver-1 )"
	"smtp? ( net-libs/libesmtp )"
	"http? ( net-misc/curl )"
	"redis? ( dev-libs/hiredis )"
	"amqp? ( >=net-libs/rabbitmq-c-0.8.0 )"
	"caps? ( sys-libs/libcap )"
	# libuuid is not used
	"systemd? ( sys-apps/systemd )"
	"systemd-journal? ( sys-apps/systemd )"

	# for --with-docbook-dir
	"app-text/docbook-xsl-stylesheets"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"sys-devel/flex"
	"virtual/yacc"
	"virtual/pkgconfig"

	"test? ( dev-util/criterion )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"man? ( doc )"
)
RESTRICT="test"

inherit arrays

src_prepare() {
	eapply_user

	# remove bundled libs
	local autogen_sh_submodules=(
		lib/ivykis
		modules/afmongodb/mongo-c-driver/src/libbson
		modules/afmongodb/mongo-c-driver
		lib/jsonc
	)
	local d
	for d in "${autogen_sh_submodules[@]}" ; do
		erm -rf "${d}"
		esed -r -e "/^SUBMODULES/ s,( |\")${d}(/[^ ]*)?,\1,g"  -i -- autogen.sh
	done

	if ! use doc ; then
		esed -e '/^include doc/d' -i -- Makefile.am
	fi

	# drop scl modules requiring json
	if ! use json ; then
		esed -r -e '/\b(osquery|nodejs|graylog2|ewmm|elasticsearch|cim)\b/d' -i -- scl/Makefile.am
	fi

	# use gentoo default path
	if use systemd ; then
		esed -e 's,/etc/syslog-ng.conf,/etc/syslog-ng/syslog-ng.conf,g' \
			-e 's,/var/run,/run,g' \
			-i -- contrib/systemd/syslog-ng@default
	fi

	if use systemd ; then
		# TODO: change this to `systemctl restart ...`
		local GENTOO_RESTART="systemctl kill -s HUP syslog-ng@default"
	fi

	for f in "${FILESDIR}"/*logrotate*.in ; do
		local bn=$(basename "${f}")

		rindeal:expand_vars "${f}" "${T}/${bn/.in}"
	done

	use python && python_fix_shebang .

	eautoreconf
}

src_configure() {
	local my_econf_args=(
		### Fine tuning of the installation directories:
		--sysconfdir="${EPREFIX}/etc/syslog-ng" # defaults to `/etc`, which would result in config files in the root of `/etc`
		--localstatedir=/var/lib/syslog-ng

		### Optional Features:
		--enable-forced-server-mode # force syslog-ng to start in server mode, only paid versions can have this disabled
		$(use_enable debug) # lot's of debugging output and stuff
		--enable-extra-warnings # extra compiler warnings
		$(use_enable env-wrapper) # enable wrapper which does some mangling of env vars
		--disable-gprof
		$(use_enable memtrace) # mem leak debugging
		--enable-dynamic-linking # Link everything dynamically.
		--disable-mixed-linking # Link 3rd party libraries statically, system libraries dynamically
		$(use_enable ipv6)
		$(use_enable tcpd tcp-wrapper)
		$(use_enable spoof-source)
		--disable-sun-streams # collect syslog messages from Solaris systems
		--disable-openbsd-system-source
		$(use_enable sql) # support for storing messages in SQL DBs through libdbi
		$(use_enable pacct) # process accounting logs
		$(use_enable caps linux-caps)
		--disable-gcov
		$(use_enable mongodb)
		--disable-legacy-mongodb-options  # Support libmongo-client non-URI MongoDB options.
		$(use_enable json) # JSON processing support
		$(use_enable amqp) # AMQP (Advanced Message Queuing Protocol)
		$(use_enable stomp) #  Simple (or Streaming) Text Oriented Message Protocol (STOMP)
		$(use_enable smtp)
		$(use_enable http)
		$(use_enable redis)
		$(use_enable systemd)
		--disable-geoip  # NOTE: deprecated in gentoo
		$(use_enable geoip2)
		--disable-riemann # no support and no support forever
		$(use_enable python)
		$(use_enable man manpages)
		# TODO: add support for JAVA
# 		$(use_enable java)
# 		$(use_enable java-modules)
		--disable-java
		--disable-java-modules
		$(use_enable native)
		--disable-all-modules
		# TODO: enable optional static
		--disable-static
		--enable-shared
		$(use_enable largefile)
		$(use_enable valgrind)

		### Optional Packages:
# 		--with-libnet=path
		--with-pidfile-dir=/var/run
		--with-module-dir=/usr/$(get_libdir)/syslog-ng
# 		--with-module-path=path
# 		--with-timezone-dir=path
# 		--with-ld-library-path=path
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)"
		# --with-package-name=package
		$(use_with mongodb mongoc system)
		$(use_with json jsonc system)
		--with-ivykis=system
# 		--with-libesmtp=DIR
# 		--with-libcurl=DIR
# 		--with-libhiredis=DIR
		--with-compile-date
		$(use_with systemd-journal systemd-journal system)
		$(use_with python python "python-${EPYTHON##python}")
		# supplement for `http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl`
		--with-docbook-dir="${EROOT}usr/share/sgml/docbook/xsl-stylesheets/manpages/docbook.xsl"
# 		--with-pic
		--with-gnu-ld
	)

	econf "${my_econf_args[@]}"
}

src_install() {
	emake DESTDIR="${D}" install

	dodoc AUTHORS NEWS.md CONTRIBUTING.md contrib/syslog-ng.conf* contrib/syslog2ng

	## hardened
	dodoc "${FILESDIR}/syslog-ng.conf.gentoo.hardened"
	dodoc "${T}/syslog-ng.logrotate.hardened"
	dodoc "${FILESDIR}/README.hardened"

	# Install default configuration
	insinto /etc/default
	doins contrib/systemd/syslog-ng@default

	insinto /etc/syslog-ng
	newins "${FILESDIR}/syslog-ng.conf.gentoo" syslog-ng.conf

	insinto /etc/logrotate.d
	newins "${T}/syslog-ng.logrotate" syslog-ng

	keepdir /etc/syslog-ng/patterndb.d /var/lib/syslog-ng

	prune_libtool_files --modules

	use python && python_optimize
}

pkg_postinst() {
	# bug #355257
	if ! has_version app-admin/logrotate ; then
		echo
		elog "It is highly recommended that app-admin/logrotate be emerged to"
		elog "manage the log files. ${PN} installs a file in /etc/logrotate.d"
		elog "for logrotate to use."
		echo
	fi
}
