# Copyright 1999-2016 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:shadow-maint"

inherit git-hosting
inherit eutils
# functions: elibtoolize
inherit libtool
# functions: dopamd, newpamd
inherit pam
# functions: eautoreconf
inherit autotools

DESCRIPTION="Utilities to deal with user accounts"
HOMEPAGE="${GH_HOMEPAGE} http://pkg-shadow.alioth.debian.org/"
LICENSE="BSD GPL-2"

SLOT="0"

KEYWORDS="amd64 arm arm64"
IUSE_A=(
	nls rpath +man +largefile
	audit selinux
	acl libcrack pam skey xattr account-tools-setuid subordinate-ids utmpx shadowgrp +sha-crypt +nscd
)

L10N_LOCALES=( bs ca cs da de dz el es eu fi fr gl he hu id it ja kk km ko nb ne nl nn pl pt pt_BR ro ru sk sq sv tl tr uk vi zh_CN zh_TW )
inherit l10n-r1

# TODO: review deps in configure.ac
CDEPEND_A=(
	"acl? ( sys-apps/acl:0= )"
	"audit? ( >=sys-process/audit-2.6:0= )"
	"libcrack? ( >=sys-libs/cracklib-2.7-r3:0= )"
	"pam? ( virtual/pam:0= )"
	"skey? ( sys-auth/skey:0= )"
	"selinux? ("
		">=sys-libs/libselinux-1.28:0="
		"sys-libs/libsemanage:0="
	")"
	"nls? ( virtual/libintl )"
	"xattr? ( sys-apps/attr:0= )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"app-arch/xz-utils"
	"nls? ("
		"app-text/gnome-doc-utils" # `xml2po` utility
		"sys-devel/gettext"
	")"
	"man? ("
		"dev-libs/libxslt" # `xsltproc` utility
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"pam? ( >=sys-auth/pambase-20150213 )"
)

REQUIRED_USE_A=(
	"account-tools-setuid? ( pam )"
)

inherit arrays

src_prepare-locales() {
	local l locales dir="po" pre="" post=".po"

	l10n_set_LINGUAS
	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	if use nls ; then
		l10n_get_locales locales app off
		for l in ${locales} ; do
			if use man ; then
				# not all langs in `po/` dir are present also in `man/` dir
				sed -r -e "/^SUBDIRS/ s, ${l}( |$), ," -i -- man/Makefile.am || die
				local f="man/${dir}/${pre}${l}${post}"
				[[ -e "${f}" ]] && erm "${f}"
			fi
		done
	fi
}

src_prepare() {
	eapply "${FILESDIR}"/4.1.3-dots-in-usernames.patch
	eapply_user

	src_prepare-locales

	if ! use man ; then
		sed -r -e '/^SUBDIRS/ s, man( |$), ,' -i -- Makefile.am || die
	fi

	eautoreconf
	elibtoolize
}

src_configure() {
	local my_econf_args=(
		--enable-shared=yes
		--enable-static=no

		--without-tcb # unsupported by upstream and actually by everything
		# HP-UX 10 limits to 16 characters, so 64 should be pretty safe, unlimited is too dangerous
		--with-group-name-max-length=64

		$(use_enable shadowgrp)
		$(use_enable man)
		$(use_enable account-tools-setuid)
		$(use_enable utmpx)
		$(use_enable subordinate-ids)
		$(use_enable nls)
		$(use_enable rpath)
		$(use_enable largefile)

		$(use_with audit)
		$(use_with pam libpam)
		$(use_with selinux)
		$(use_with acl)
		$(use_with xattr attr)
		$(use_with skey)

		$(use_with libcrack)
		$(use_with sha-crypt)
		$(use_with nscd)
	)
	econf "${my_econf_args[@]}"
}

set_login_opt() {
	local comment="" opt="$1" val="$2"
	if [[ -z ${val} ]] ; then
		comment="#"
		sed -e "/^${opt}\>/ s|^|#|" \
			-i -- "${ED}"/etc/login.defs || die
	else
		sed -r -e "/^#?${opt}\>/ s|.*|${opt} ${val}|" \
			-i -- "${ED}"/etc/login.defs || die
	fi
	local res="$(grep "^${comment}${opt}\>" "${ED}"/etc/login.defs)"
	elog "${res:-"Unable to find ${opt} in /etc/login.defs"}"
}

src_install() {
	emake DESTDIR="${D}" suidperms=4711 install

	dodoc ChangeLog NEWS TODO doc/{HOWTO,README*,WISHLIST,*.txt}
	newdoc README README.download

	if use man ; then
		# Remove manpages that are handled by other packages (sys-apps/coreutils sys-apps/man-pages)
		erm "${ED}"/usr/share/man/man5/passwd.5
		erm "${ED}"/usr/share/man/man3/getspnam.3
	fi

	# needed for 'useradd -D'
	insinto /etc/default
	insopts -m0600
	doins "${FILESDIR}"/default/useradd

	# move passwd to / to help recover broke systems #64441
	emv "${ED}"/usr/bin/passwd "${ED}"/bin/
	dosym ../../bin/passwd /usr/bin/passwd

	insinto /etc
	insopts -m0644
	newins etc/login.defs login.defs

	if ! use pam ; then
		insinto /etc
		insopts -m0600
		doins etc/login.access etc/limits
	fi

	set_login_opt CREATE_HOME yes
	if use pam ; then
		dopamd "${FILESDIR}"/pam.d-include/shadow

		local x
		for x in ch{,g}passwd newusers ; do
			newpamd "${FILESDIR}"/pam.d-include/passwd ${x}
		done
		for x in ch{age,sh,fn} user{add,del,mod} group{add,del,mod} ; do
			newpamd "${FILESDIR}"/pam.d-include/shadow ${x}
		done

		# comment out login.defs options that pam hates
		local sed_args=() opt opts=(
			CHFN_AUTH
			CONSOLE
			CRACKLIB_DICTPATH
			ENV_HZ
			ENVIRON_FILE
			FAILLOG_ENAB
			FTMP_FILE
			LASTLOG_ENAB
			MAIL_CHECK_ENAB
			MOTD_FILE
			NOLOGINS_FILE
			OBSCURE_CHECKS_ENAB
			PASS_ALWAYS_WARN
			PASS_CHANGE_TRIES
			PASS_MIN_LEN
			PORTTIME_CHECKS_ENAB
			QUOTAS_ENAB
			SU_WHEEL_ONLY
		)
		for opt in "${opts[@]}" ; do
			set_login_opt ${opt}
			sed_args+=( -e "/^#${opt}\>/b pamnote" )
		done
		sed "${sed_args[@]}" \
			-e 'b exit' \
			-e ': pamnote; i# NOTE: This setting should be configured via /etc/pam.d/ and not in this file.' \
			-e ': exit' \
			-i -- "${ED}"/etc/login.defs || die

		if use man ; then
			# remove manpages that pam will install for us
			# and/or don't apply when using pam
			erm "${ED}"/usr/share/man/man5/suauth.5
			use pam || erm "${ED}"/usr/share/man/man5/limits.5
		fi

		# Remove pam.d files provided by sys-auth/pambase
		erm "${ED}"/etc/pam.d/{login,passwd,su}
	else
		set_login_opt MAIL_CHECK_ENAB no
		set_login_opt SU_WHEEL_ONLY yes
		set_login_opt CRACKLIB_DICTPATH /usr/$(get_libdir)/cracklib_dict
		set_login_opt LOGIN_RETRIES 3
		set_login_opt ENCRYPT_METHOD SHA512
		set_login_opt CONSOLE
	fi
}

pkg_preinst() {
	nonfatal erm "${EROOT}"etc/pam.d/system-auth.new \
		"${EROOT}"etc/login.defs.new
}

pkg_postinst() {
	# Enable shadow groups.
	if [[ ! -f "${EROOT}"/etc/gshadow ]] ; then
		if grpck -r -R "${EROOT}" 2>/dev/null ; then
			grpconv -R "${EROOT}"
		else
			ewarn "Running 'grpck' returned errors. Please run it by hand, and then"
			ewarn "run 'grpconv' afterwards!"
		fi
	fi

	einfo "The 'adduser' symlink to 'useradd' has been dropped."
}
