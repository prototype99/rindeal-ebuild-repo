# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# git-hosting.eclass
GH_RN="github:${PN}:${PN}-stable"
# https://github.com/systemd/systemd-stable/commits/v238-stable
GH_REF="c58ab03f64890e7db88745a843bd4520e307099b"  # 2018-03-20
# python-.eclass
PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
# EXPORT_FUNCTIONS: pkg_setup
inherit python-any-r1
# EXPORT_FUNCTIONS: pkg_setup
inherit linux-info
# EXPORT_FUNCTIONS: src_configure src_compile src_test src_install
inherit meson
# functions: getpam_mod_dir
inherit pam
# functions: tc-*()
inherit toolchain-funcs
# functions: enewuser,/enewgroup
inherit user
# functions: get_bashcompdir()
inherit bash-completion-r1
# functions: systemd_update_catalog
inherit systemd
# functions: udev_reload
inherit udev

DESCRIPTION="System and service manager for Linux"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/systemd ${GH_HOMEPAGE}"
# licences are described in the 'README' file
LICENSE_A=(
	'LGPL-2.1+' # most of the code
	'GPL-2' # udev
	'public-domain' # MurmurHash2, siphash24, lookup3
)

# The subslot versioning follows the Gentoo repo.
# Explanation: "incremented for ABI breaks in libudev or libsystemd".
SLOT="0/2"
SRC_URI+=" http://snapshot.debian.org/archive/debian/20180401T155009Z/pool/main/s/systemd/systemd_238-4.debian.tar.xz"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
	link-udev-shared











	## generic
	+man nls python sysv-utils test vanilla debug

	## daemons
	+hostnamed importd +localed +logind machined networkd resolved +timedated timesyncd

	## utils
	backlight +coredump +firstboot quotacheck +randomseed rfkill +sysusers +tmpfiles

	## security modules (kernel)
	apparmor audit ima seccomp selinux smack
	## security modules2 (userspace)
	acl +pam +polkit tpm

	## compression
	bzip2 +lz4 +lzma +zlib

	## EFI
	efi gnuefi

	## gimmick
	-qrcode -microhttpd -gnutls

	## misc
	binfmt +blkid cryptsetup curl +elfutils gcrypt hibernate +hwdb idn +kmod libiptc myhostname
	+utmp +vconsole xkb

	## compatibility USE-flags with `gentoo` repo
	acl audit pam policykit


	remote doc-html compat-gateway-hostname smack-run-label libcryptsetup libcurl libidn2 libidn nss-systemd qrencode xz xkbcommon
	glib dbus gnu-efi
)

# deps are specified in 'README' file
CDEPEND_A=(
	">=sys-libs/glibc-2.16"
	"sys-libs/libcap:0="
	# >v2.27.1 since 228
	# "*must* be built with --enable-libmount-force-mountinfo"
	# TODO: how to enforce the above condition?
	">=sys-apps/util-linux-2.27.1:0="

	"acl?	( sys-apps/acl:0= )"
	"apparmor?	( sys-libs/libapparmor:0= )"
	"audit?	( >=sys-process/audit-2:0= )"
	"cryptsetup?	( sys-fs/cryptsetup:0= )"
	"curl?	( net-misc/curl:0= )"
	"elfutils?	( >=dev-libs/elfutils-0.158:0= )"
	"gcrypt?	("
		"dev-libs/libgcrypt:0="
		"dev-libs/libgpg-error"
	")"
	"microhttpd?	("
		"net-libs/libmicrohttpd:0="
		"gnutls?	( net-libs/gnutls:0= ) )"
	"idn?		( net-dns/libidn:0= )"
	"kmod?	( >=sys-apps/kmod-15:0= )"

	## compression
	"bzip2?	( app-arch/bzip2:0= )"
	"lz4?		("
		# `PKG_CHECK_MODULES(LZ4, [ liblz4 >= 125 ],`
		">=app-arch/lz4-0_p131:0="
	")"
	"lzma?	( app-arch/xz-utils:0= )"
	"zlib?	( sys-libs/zlib:0= )"

	"libiptc?		( net-firewall/iptables:0= )"
	"pam?	( virtual/pam:= )"
	"qrcode?	( media-gfx/qrencode:0= )"
	"seccomp?	( >=sys-libs/libseccomp-2.3.1:0= )"
	"selinux?	( sys-libs/libselinux:0= )"
	"sysv-utils?	("
		"!sys-apps/systemd-sysv-utils"
		"!sys-apps/sysvinit )"
	"xkb?		( x11-libs/libxkbcommon:0= )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	# for keymap; TODO: find out more
	"dev-util/gperf"
	# systemd depends heavily on a recent version of binutils
	">=sys-devel/binutils-2.23.1"
	"sys-kernel/linux-headers"
	"sys-devel/gettext" # localed, core-dbus
	"virtual/pkgconfig"

	"gnuefi? ( >=sys-boot/gnu-efi-3.0.2 )"
	"man? ("
		# for creating the man pages (used in {less-variables,standard-options}.xml)
		"app-text/docbook-xml-dtd:4.5"
		# xsltproc - for creating the man pages
		"dev-libs/libxslt:0"
		"app-text/docbook-xsl-stylesheets"

		"python? ("
			# lxml is for generating the man page index
			"$(python_gen_any_dep 'dev-python/lxml[${PYTHON_USEDEP}]')"
		")"
	")"
	"nls? ( dev-util/intltool )"
	"python? ( ${PYTHON_DEPS} )"
	# tests use dbus
	"test? ("
		"sys-apps/dbus:0"
		">=dev-lang/python-3" # since v233
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"selinux? ( sec-policy/selinux-base-policy[systemd] )"
	"myhostname? ( !sys-auth/nss-myhostname )" # bundled since 197
	"!<sys-kernel/dracut-044"
	## udev is now part of systemd
	"!sys-fs/eudev"
	"!sys-fs/udev"
)
PDEPEND_A=(
	# the daemon only (+ build-time lib dep for tests)
	">=sys-apps/dbus-1.4.0:0[systemd]"
	# Gentoo specific suplement of bundled hwdb.d rules + some more
	"hwdb?	( sys-apps/hwids[udev] )"
	# ">=sys-fs/udev-init-scripts-25" # required for systemd+OpenRC support only
	"polkit? ( sys-auth/polkit[systemd] )"
	"!vanilla?	( sys-apps/gentoo-systemd-integration )"
)

REQUIRED_USE_A=(
	# specified in Makefile.am
	"efi?		( blkid )"
	"gnuefi?	( efi )"
	"importd?	( curl lzma zlib bzip2 gcrypt )"
	# systemd-journal-remote requires systemd-sysusers
# 	"microhttpd?	( sysusers )"

	## compatibility USE-flags
	"acl? ( acl )"
	"audit? ( audit )"
	"pam? ( pam )"
	"policykit? ( polkit )"
)

inherit arrays

DEBIANDIR="${WORKDIR}/debian"
DEBPATCHDIR="${DEBIANDIR}/patches/debian"

my_get_rootprefix() {
	echo "${ROOTPREFIX-"/usr"}"
}

python_check_deps() {
	# choose the first python that has lxml
	has_version --host-root "dev-python/lxml[${PYTHON_USEDEP}]"
}

pkg_pretend() {
	[[ -n "${EPREFIX}" ]] && \
		die "Gentoo Prefix is not supported"

	if [[ ${MERGE_TYPE} != buildonly ]] ; then
		if linux_config_exists ; then
			local uevent_helper_path="$(linux_chkconfig_string UEVENT_HELPER_PATH)"
			if [[ -n "${uevent_helper_path}" ]] && [[ "${uevent_helper_path}" != '""' ]] ; then
				ewarn "Legacy hotplug slows down the system and confuses udev."
				ewarn "It's recommended to set an empty value to the following kernel config option:"
				ewarn "CONFIG_UEVENT_HELPER_PATH=\"${uevent_helper_path}\""
			fi
		fi

		# config options are specified in 'README'
		local CONFIG_CHECK_A=(
			##  file as required
			'~DEVTMPFS'
			'~CGROUPS'
			'~INOTIFY_USER'
			'~SIGNALFD'
			'~TIMERFD'
			'~EPOLL'
			'~NET'
			'~SYSFS'
			'~PROC_FS'
			'~FHANDLE'
			# udev
			'~!SYSFS_DEPRECATED'
			'~!SYSFS_DEPRECATED_V2'
			# Userspace firmware loading is not supported
			'~!FW_LOADER_USER_HELPER'

			# Required for PrivateNetwork and PrivateDevices
			'~NET_NS'
			"$(kernel_is -lt 4 7 &>/dev/null && echo '~DEVPTS_MULTIPLE_INSTANCES')"

			# Required for CPUShares= in resource control unit settings
			'~CGROUP_SCHED'
			'~FAIR_GROUP_SCHED'

			## optional
			# HW support
			'~DMIID'
			'~BLK_DEV_BSG'
			# ipv6
			'~IPV6'
			#if deselected, systemd issues warning on each boot, but otherwise works the same
			'~AUTOFS4_FS'
			# acl
			'~TMPFS_XATTR'
			"$(use acl && echo '~TMPFS_POSIX_ACL')"
			# seccomp
			"$(use seccomp && echo '~SECCOMP')"
			# for the kcmp() syscall
			'~CHECKPOINT_RESTORE'
			# Required for CPUQuota= in resource control unit settings
			'~CFS_BANDWIDTH'
			# efi
			"$(use efi && echo '~EFIVAR_FS ~EFI_PARTITION')"
			# real-time group scheduling - see 'README'
			'~!RT_GROUP_SCHED'
			# systemd doesn't like it - see 'README'
			'~!AUDIT'

			'~!GRKERNSEC_PROC'
			'~!IDE'
		)

		CONFIG_CHECK="${CONFIG_CHECK_A[@]}"

		check_extra_config
	fi
}

pkg_setup() {
	linux-info_pkg_setup
	python-any-r1_pkg_setup

	# check if get_udevdir() returns sane value
	local udevdir="$(get_udevdir)"
	if [[ "${udevdir}" == *"/lib/udev"*"/lib/udev"* ]] ; then
		die
	fi
}

src_unpack() {
	git-hosting_src_unpack
	default
}

src_prepare() {
	# BEGIN - Debian patches
	## https://salsa.debian.org/systemd-team/systemd/tree/master/debian
	# `Add-env-variable-for-machine-ID-path.patch`
	# `Add-support-for-TuxOnIce-hibernation.patch`
	# `Avoid-requiring-a-kvm-system-group.patch`
	# `Bring-tmpfiles.d-tmp.conf-in-line-with-Debian-defaul`
	eapply "${DEBPATCHDIR}"/Don-t-enable-audit-by-default.patch
	eapply "${DEBPATCHDIR}"/Let-graphical-session-pre.target-be-manually-started.patch
	eapply "${DEBPATCHDIR}"/Make-sd_login_monitor_new-work-for-logind-without-sy.patch
	eapply "${DEBPATCHDIR}"/Only-start-logind-if-dbus-is-installed.patch
	# `Re-enable-journal-forwarding-to-syslog.patch`
	eapply "${DEBPATCHDIR}"/Revert-core-enable-TasksMax-for-all-services-by-default-a.patch
	# `Revert-core-one-step-back-again-for-nspawn-we-actual.patch`
	eapply "${DEBPATCHDIR}"/Revert-core-set-RLIMIT_CORE-to-unlimited-by-default.patch
	eapply "${DEBPATCHDIR}"/Revert-udev-rules-Permission-changes-for-dev-dri-renderD.patch
	eapply "${DEBPATCHDIR}"/Skip-filesystem-check-if-already-done-by-the-initram.patch
	eapply "${DEBPATCHDIR}"/Start-logind-on-demand-via-libpam-systemd.patch
	# `Use-Debian-specific-config-files.patch`
	eapply "${DEBPATCHDIR}"/cgroup-don-t-trim-cgroup-trees-created-by-someone-el.patch
	eapply "${DEBPATCHDIR}"/don-t-try-to-start-autovt-units-when-not-running-wit.patch
	# `fsckd-daemon-for-inter-fsckd-communication.patch`
	# END - Debian patches

	# -------------------------------------------------------------------------

	# BEGIN - Custom patches
	eapply "${FILESDIR}/228-noclean-tmp.patch"
	# END - Custom patches

	# -------------------------------------------------------------------------

	# BEGIN - User patches
	eapply_user
	# END - User patches

	# -------------------------------------------------------------------------

	# BEGIN - Scripted modifications
	esed -r -e "s,^(udevlibexecdir *=).*,\1 '$(get_udevdir)'," \
		-i -- meson.build
	# Avoid the log bloat to the user
	esed -e 's,#SystemMaxUse=,SystemMaxUse=500M,' \
		-i -- src/journal/journald.conf
	# END - Scripted modifications
}

meson_use() {
	usex "$1" true false
}

src_configure() {
	# work around bug in gobject-introspection (gentoo#463846)
# 	tc-export CC

	# safe defaults
# 	export EFI_CFLAGS="${EFI_CFLAGS-"-O2"}"
# 	export CTARGET="${CTARGET:-"${CHOST}"}" # `configure: WARNING: you should use --build, --host, --target`

	my_use() {
		local -r mode="${1}" prefix="${2}" flag="${3}" option="${4}" value="${5}"
		if [[ -n "${value}" ]] ; then
			use_${mode} ${prefix}_${flag} ${option:-${flag}} "${value}"
		else
			use_${mode} ${prefix}_${flag} ${option:-${flag}}
		fi
	}

	local my_meson_options=(
		# make sure we get /bin:/sbin in $PATH
		# "Assume that /bin, /sbin aren't symlinks into /usr"
		-D split-usr="true"
		-D rootlibdir="$(my_get_rootprefix)/$(get_libdir)"
		-D rootprefix="$(my_get_rootprefix)"
		-D link-udev-shared="$(meson_use link-udev-shared)"


		## disable sysv compatibility
		-D sysvinit-path=""
		-D sysvrcnd-path=""
		##
		-D telinit-path="/sbin/telinit"
# 		-D rc-local="/etc/rc.local"
# 		-D halt-local="/usr/sbin/halt.local"


		## hardcode a few paths to prevent meson from looking for them and
		## thus sparing some deps
		-D quotaon-path="/usr/sbin/quotaon"
		-D quotacheck-path="/usr/sbin/quotacheck"
		-D kill-path="/bin/kill"
# 		-D kmod-path=""
# 		-D kexec-path=""
# 		-D sulogin-path=""
# 		-D mount-path=""
# 		-D umount-path=""
		-D loadkeys-path="/usr/bin/loadkeys"
		-D setfont-path="/usr/bin/setfont"


# 		-D debug-shell="/bin/sh" # TODO my_with
# 		-D debug-tty="/dev/tty9" # TODO my_with
		-D debug="$(meson_use debug)"


		-D utmp="$(meson_use utmp)"
		-D hibernate="$(meson_use hibernate)"
		# just install ldconfig.service
		-D ldconfig="true"
		-D resolve="$(meson_use resolved)"
		-D efi="$(meson_use efi)"
		-D tpm="$(meson_use tpm)"
# 		-D environment-d="$(meson_use environment-d)"
		-D binfmt="$(meson_use binfmt)"
		-D coredump="$(meson_use coredump)"
		-D logind="$(meson_use logind)"
		-D hostnamed="$(meson_use hostnamed)"
		-D localed="$(meson_use localed)"
		-D machined="$(meson_use machined)"
		-D networkd="$(meson_use networkd)"
		-D timedated="$(meson_use timedated)"
		-D timesyncd="$(meson_use timesyncd)"
		-D remote="$(meson_use remote)"
		-D myhostname="$(meson_use myhostname)"
		-D firstboot="$(meson_use firstboot)"
		-D randomseed="$(meson_use randomseed)"
		-D backlight="$(meson_use backlight)"
		-D vconsole="$(meson_use vconsole)"
		-D quotacheck="$(meson_use quotacheck)"
		-D sysusers="$(meson_use sysusers)"
		-D tmpfiles="$(meson_use tmpfiles)"
		-D importd="$(meson_use importd)"
		-D hwdb="$(meson_use hwdb)"
		-D rfkill="$(meson_use rfkill)"
		-D man="$(meson_use man)"
		-D html="$(meson_use doc-html)"


# 		-D certificate-root="/etc/ssl" # TODO my_with
		-D dbuspolicydir="/etc/dbus-1/system.d"
		-D dbussessionservicedir="/usr/share/dbus-1/services"
		-D dbussystemservicedir="/usr/share/dbus-1/system-services"
# 		-D pkgconfigdatadir="share/pkgconfig" # TODO
# 		-D pkgconfiglibdir="" # TODO
# 		-D rpmmacrosdir="lib/rpm/macros.d"
		-D pamlibdir="$(getpam_mod_dir)"
# 		-D pamconfdir="" # TODO


# 		-D fallback-hostname="localhost" # TODO my_with
		-D compat-gateway-hostname="$(meson_use compat-gateway-hostname)"
# 		-D default-hierarchy="hybrid" # TODO my_with
# 		-D time-epoch="" # TODO my_with
# 		-D system-uid-max="" # TODO my_with
# 		-D system-gid-max="" # TODO my_with
# 		-D tty-gid="5" # TODO my_with
# 		-D adm-group="" # TODO my_with
# 		-D wheel-group="" # TODO my_with
# 		-D nobody-user="nobody" # TODO my_with
# 		-D nobody-group="nobody" # TODO my_with
# 		-D dev-kvm-mode="0660" # TODO my_with
# 		-D default-kill-user-processes="" # TODO my_with
# 		-D gshadow=""	# TODO my_with


# 		-D default-dnssec="allow-downgrade"	# TODO my_with
# 		-D dns-servers="8.8.8.8 8.8.4.4 2001:4860:4860::8888 2001:4860:4860::8844"	# TODO my_with
# 		-D ntp-servers="time1.google.com time2.google.com time3.google.com time4.google.com"	# TODO my_with
# 		-D support-url="https://lists.freedesktop.org/mailman/listinfo/systemd-devel"	# TODO my_with
# 		-D www-target="www.freedesktop.org:/srv/www.freedesktop.org/www/software/systemd"	# TODO my_with


		-D seccomp="$(meson_use seccomp)"
		-D selinux="$(meson_use selinux)"
		-D apparmor="$(meson_use apparmor)"
		-D smack="$(meson_use smack)"
		-D smack-run-label="$(meson_use smack-run-label)"
		-D polkit="$(meson_use polkit)"
		-D ima="$(meson_use ima)"


		-D acl="$(meson_use acl)"
		-D audit="$(meson_use audit)"
		-D blkid="$(meson_use blkid)"
		-D kmod="$(meson_use kmod)"
		-D pam="$(meson_use pam)"
		-D microhttpd="$(meson_use microhttpd)"
		-D libcryptsetup="$(meson_use libcryptsetup)"
		-D libcurl="$(meson_use libcurl)"
		-D idn="$(meson_use idn)"
		-D libidn2="$(meson_use libidn2)"
		-D libidn="$(meson_use libidn)"
		-D nss-systemd="$(meson_use nss-systemd)"
		-D libiptc="$(meson_use libiptc)"
		-D qrencode="$(meson_use qrencode)"
		-D gcrypt="$(meson_use gcrypt)"
		-D gnutls="$(meson_use gnutls)"
		-D elfutils="$(meson_use elfutils)"
		-D zlib="$(meson_use zlib)"
		-D bzip2="$(meson_use bzip2)"
		-D xz="$(meson_use xz)"
		-D lz4="$(meson_use lz4)"
		-D xkbcommon="$(meson_use xkbcommon)"
		-D glib="$(meson_use glib)"
		-D dbus="$(meson_use dbus)"


		-D gnu-efi="$(meson_use gnu-efi)"
		-D efi-cc="$(tc-getCC)"
		-D efi-ld="$(tc-getLD)"
# 		-D efi-libdir=""
# 		-D efi-ldsdir=""
# 		-D efi-includedir="/usr/include/efi"
# 		-D tpm-pcrindex="8"	# TODO my_with


		-D bashcompletiondir=""$(get_bashcompdir)""
		# FIXME: ZSH completion dir
# 		-D zshcompletiondir=""


# 		-D tests="false" # unsafe # TODO
		-D slow-tests="$(meson_use test)"
		-D install-tests="false"
	)

# 	local econf_args=(
# 		# Disable -fuse-ld=gold since Gentoo supports explicit linker
# 		# choice and forcing gold is undesired. (gentoo#539998)
# 		# ld.gold may collide with user's LDFLAGS. (gentoo#545168)
# 		cc_cv_LDFLAGS__Wl__fuse_ld_gold=no
#
# 		# TODO: we may need to restrict this to gcc
# 		EFI_CC="$(tc-getCC)"
#
# 		--disable-lto
# 		--disable-static
# 		# workaround for bug 516346
# # 		--enable-dependency-tracking
# 		# controverse autoconf feature
# 		--disable-maintainer-mode
#
# 		### Paths
# 		## hardcode a few paths to prevent autoconf from looking for them and
# 		## thus sparing some deps
# 		KILL="/bin/kill"
# 		QUOTAON="/usr/sbin/quotaon"
# 		QUOTACHECK="/usr/sbin/quotacheck"
# 		--with-kbd-loadkeys="/usr/bin/loadkeys"
# 		--with-kbd-setfont="/usr/bin/setfont"
# 		--with-telinit="/sbin/telinit"
#
# 		--localstatedir=/var
# 		## avoid bash-completion dep (configure.ac would call pkg-config)
# 		--with-bashcompletiondir="$(get_bashcompdir)"
# 		# FIXME: ZSH completion dir
# 		# --with-zshcompletiondir # defaults to ${datadir}/zsh/site-functions
# 		## dbus paths
# 		--with-dbuspolicydir="/etc/dbus-1/system.d"
# 		--with-dbussessionservicedir="/usr/share/dbus-1/services"
# 		--with-dbussystemservicedir="/usr/share/dbus-1/system-services"
# 		# TODO: ??
# 		--with-pamlibdir="$(getpam_mod_dir)"
# 		## For testing.
# 		--with-rootprefix="$(my_get_rootprefix)"
# 		--with-rootlibdir="$(my_get_rootprefix)/$(get_libdir)"
# 		## disable sysv compatibility
# 		--with-sysvinit-path=
# 		--with-sysvrcnd-path=
#
# 		# make sure we get /bin:/sbin in $PATH
# 		# "Assume that /bin, /sbin aren't symlinks into /usr"
# 		--enable-split-usr
# 		# just install ldconfig.service
# 		--enable-ldconfig
# 		## enable administrative ACL settings for these groups
# 		--enable-adm-group
# 		--enable-wheel-group
#
# 		# do not kill user process on logout, it breaks screen/tmux sessions, etc.
# 		--without-kill-user-processes
#
# 		## generic options
# 		"$(use_enable nls)"
# 		"$(use_enable test tests)"	# disable tests, or enable extra tests with =unsafe
# 		"$(use_enable test dbus)"		# disable usage of dbus-1 in tests
# 		"$(use_enable man manpages)"
# 		#--enable-debug[=LIST]   enable extra debugging (hashmap,mmap-cache)
# 		"$(use_with python)"
#
# 		## systemd daemons
# 		"$(my_use enable d hostnamed)"
# 		"$(my_use enable d importd)"
# 		"$(my_use enable d localed)"
# 		"$(my_use enable d logind)"
# 		"$(my_use enable d machined)"
# 		"$(my_use enable d networkd)"
# 		"$(my_use enable d resolved)"
# 		"$(my_use enable d timedated)"
# 		"$(my_use enable d timesyncd)"
#
# 		## systemd utils
# 		"$(my_use enable u backlight)"
# 		"$(my_use enable u binfmt)"
# 		"$(my_use enable u coredump)"
# 		"$(my_use enable u cryptsetup libcryptsetup)"
# 		"$(my_use enable u firstboot)"
# 		"$(my_use enable u hwdb)"
# 		"$(my_use enable u quotacheck)"
# 		"$(my_use enable u randomseed)"
# 		"$(my_use enable u rfkill)"
# 		"$(my_use enable u sysusers)"
# 		"$(my_use enable u tmpfiles)"
#
# 		## kernel-space security modules
# 		"$(my_use enable s1 apparmor)"
# 		"$(my_use enable s1 audit)"
# 		"$(my_use enable s1 ima)"
# 		"$(my_use enable s1 seccomp)"
# 		"$(my_use enable s1 selinux)"
# 		"$(my_use enable s1 smack)"
#
# 		## user-space security modules
# 		"$(my_use enable s2 acl)"
# 		"$(my_use enable s2 pam)"
# 		"$(my_use enable s2 polkit)"
# 		"$(my_use enable s2 tpm)"
#
# 		## compression algorithms
# 		"$(my_use enable c bzip2)"
# 		"$(my_use enable c lz4)"
# 		"$(my_use enable c lzma xz)"
# 		"$(my_use enable c zlib)"
#
# 		## EFI
# 		"$(my_use enable e efi)"
# 		"$(my_use enable e gnuefi)"
#
# 		## gimmick
# 		"$(my_use enable g microhttpd)"
# 		# if use_http && use_ssl then --enable-gnutls else --disable-gnutls
# 		"$(my_use enable g "$(usex microhttpd gnutls microhttpd)" gnutls)"
# 		"$(my_use enable g qrcode qrencode)"
#
# 		## misc
# 		"$(my_use enable m blkid)"
# 		"$(my_use enable m curl libcurl)"
# 		"$(my_use enable m elfutils)"
# 		"$(my_use enable m gcrypt)"
# 		"$(my_use enable m hibernate)"
# 		"$(my_use enable m idn libidn)"
# 		"$(my_use enable m kmod)"
# 		"$(my_use enable m libiptc)"
# 		"$(my_use enable m myhostname)"
# 		"$(my_use enable m utmp)"
# 		"$(my_use enable m vconsole)"
# 		# - NEWS: "systemd-localed will verify x11 keymap settings by compiling the given keymap"
# 		# - enable for desktops
# 		"$(my_use enable m xkb xkbcommon)"
# 	)

	: "${SYSTEMD_WITH_NTP_SERVERS:="$( echo {0..3}'.gentoo.pool.ntp.org' )"}"
	# Google DNS servers by default, alternatives: https://www.opennicproject.org/ or leave empty
	: "${SYSTEMD_WITH_DNS_SERVERS:="$( echo 8.8.{8.8,4.4} 2001:4860:4860::88{88,44} )"}"

	# used for options which can be modified with env vars
	# Example:
	#     my_with debug-shell
	# Prints:
	#     --with-debug-shell="${SYSTEMD_WITH_DEBUG_SHELL}"
	my_with() {
		local -r -- use_flag="${1}" option_name="${2}"

		local var="${use_flag^^}" ;						var="${var//-/_}"
		local with="${option_name:-"${use_flag,,}"}" ;	with="${with//_/-}"
		readonly var with

		local -r full_var_name="SYSTEMD_WITH_${var}"

		[[ -v "${full_var_name}" ]] && \
			printf "%s-%s=%s\n" "--with" "${with}" "${!full_var_name}"

		return 0
	}

	econf_args+=(
		"$(my_with debug-shell)"	# Path to debug shell binary, defaults to `/bin/sh`
		"$(my_with debug-tty)"		# Specify the tty device for debug shell
		"$(my_with certificate-root)"	# Specify the prefix for TLS certificates [/etc/ssl]

		"$(my_with support-url)"	# Specify the supoport URL to show in catalog entries included in systemd

		"$(my_with smack-run-label)"	# run systemd --system itself with a specific SMACK label
		"$(my_with smack-default-process-label)"	# default SMACK label for executed processes

		"$(my_with ntp-servers)"	# systemd-timesyncd default servers
		"$(my_with time-epoch)"		# minimal clock value specified as UNIX timestamp

		"$(my_with tpm-pcrindex)"	# TPM PCR register number to use

		"$(my_with system-uid-max)"
		"$(my_with system-gid-max)"

		"$(my_with dns-servers)"	# systemd-resolved default servers
		"$(my_with default-dnssec)"	# Default DNSSEC mode, accepts boolean, defaults to "allow-downgrade"

		"$(my_with tty-gid)"

		"$(my_with nobody-user)"	# Specify the name of the nobody user (the one with UID 65534)
		"$(my_with nobody-group)"	# Specify the name of the nobody group (the one with GID 65534)

		"$(my_with fallback-hostname)" # fallback hostname to use if none is configured in /etc/hostname
	)

# 	econf "${econf_args[@]}"
	meson_src_configure "${my_meson_options[@]}"
}

src_install() {
	local mymakeopts=(
		# do not install hwdb.d rules
		# Gentoo packages it separately as sys-apps/hwids
		dist_udevhwdb_DATA=

		DESTDIR="${D}"

		# automake fails with parallel libtool relinking (gentoo#491398)
		-j1
	)

	emake "${mymakeopts[@]}" install
	prune_libtool_files --modules

	einstalldocs
	dodoc "${FILESDIR}/nsswitch.conf"

	# python script generates the index
	use python && \
		doman "${WORKDIR}"/man/systemd.{directives,index}.7

	if use sysv-utils ; then
		local app
		for app in halt poweroff reboot runlevel shutdown telinit ; do
			dosym ".."$(my_get_rootprefix)"/bin/systemctl" "/sbin/${app}"
		done
		dosym ".."$(my_get_rootprefix)"/lib/systemd/systemd" '/sbin/init'
	elif use man ; then
		## we just keep sysvinit tools, so no need for the mans
		erm "${D}"/usr/share/man/man8/{halt,poweroff,reboot,runlevel,shutdown,telinit}.8
		erm "${D}"/usr/share/man/man1/init.1
	fi

	# Preserve empty dirs in /etc & /var, (gentoo#437008)
	keepdir \
		/etc/binfmt.d \
		/etc/kernel/install.d \
		/etc/modules-load.d \
		/etc/systemd/network \
		/etc/systemd/ntp-units.d \
		/etc/systemd/user \
		/etc/tmpfiles.d \
		/etc/udev/hwdb.d \
		/etc/udev/rules.d \
		/usr/lib/modules-load.d \
		/usr/lib/systemd/{user-generators,system-{sleep,shutdown}} \
		/var/lib/systemd \
		/var/log/journal/remote

	# Symlink /etc/sysctl.conf for easy migration.
	dosym "../sysctl.conf" "/etc/sysctl.d/99-sysctl.conf"

	## If we install these symlinks, there is no way for the sysadmin to remove
	## them permanently.
	epushd "${D}"/etc/systemd/system # {
	use sysv-utils && erm -r \
		sysinit.target.wants
	use networkd && erm -r \
		multi-user.target.wants/systemd-networkd.service \
		{network-online,sockets}.target.wants
	use resolved && erm -r \
		multi-user.target.wants/systemd-resolved.service
	epopd # }
}

# set to 1 if some pkg_postinst phase fails
FAIL=0

my_migrate_locale_settings() {
	local envd_locale_def="${ROOT%/}/etc/env.d/02locale"
	local envd_locale=( "${ROOT%/}"/etc/env.d/??locale )
	local locale_conf="${ROOT%/}/etc/locale.conf"

	# If locale.conf does not exist...
	if [[ ! -L ${locale_conf} && ! -e ${locale_conf} ]] ; then
		# ...either copy env.d/??locale if there's one
		if [[ -e ${envd_locale} ]] ; then
			ebegin "Moving ${envd_locale} to ${locale_conf}"
			mv "${envd_locale}" "${locale_conf}"
			eend $? || FAIL=1

		# ...or create a dummy default
		else
			ebegin "Creating ${locale_conf}"
			cat > "${locale_conf}" <<-EOF
				# This file has been created by the ${CATEGORY}/${PF} ebuild.
				# See locale.conf(5) and localectl(1).

				# LANG=${LANG}
			EOF
			eend $? || FAIL=1
		fi
	fi

	# now, if env.d/??locale is not a symlink (to locale.conf)...
	if [[ ! -L ${envd_locale} ]] ; then
		# ... check if the user has duplicate locale settings
		if [[ -e ${envd_locale} ]] ; then
			ewarn
			ewarn "To ensure consistent behavior, you should replace ${envd_locale}"
			ewarn "with a symlink to ${locale_conf}. Please migrate your settings"
			ewarn "and create the symlink with the following command:"
			ewarn "    ln -s -n -f ../locale.conf ${envd_locale}"
			ewarn

		# ...or just create the symlink if there's nothing here
		else
			ebegin "Creating ${envd_locale_def} -> ../locale.conf symlink"
			ln --no-dereference -s '../locale.conf' "${envd_locale_def}"
			eend $? || FAIL=1
		fi
	fi
}

pkg_postinst() {
	my_newusergroup() {
		enewgroup "$1"
		enewuser "$1" -1 -1 -1 "$1"
	}

	## NOTE: do not make the creation of users/groups conditional
	enewgroup input
	enewgroup systemd-journal
	my_newusergroup systemd-bus-proxy
	my_newusergroup systemd-coredump
	my_newusergroup systemd-journal-gateway
	my_newusergroup systemd-journal-remote
	my_newusergroup systemd-journal-upload
	my_newusergroup systemd-network
	my_newusergroup systemd-resolve
	my_newusergroup systemd-timesync

	systemd_update_catalog

	# Keep this here in case the database format changes so it gets updated
	# when required. Despite that this file is owned by sys-apps/hwids.
	if has_version "sys-apps/hwids[udev]" ; then
		einfo "Updating hwdb database"
		nonfatal udevadm hwdb --update --root="${ROOT%/}"
	fi

	udev_reload || FAIL=1

	# Make sure locales are respected, and ensure consistency between OpenRC & systemd.
	# Bug gentoo#465468.
	my_migrate_locale_settings

	if (( ${FAIL} )) ; then
		eerror "One of the post-installation commands failed. Please check the postinst output"
		eerror "for errors. You may need to clean up your system and/or try installing"
		eerror "${PN} again."
		eerror
	fi

	if use resolved ; then
		local resolv_conf_path="$(my_get_rootprefix)/lib/systemd/resolv.conf"
		if [[ "$(readlink "${ROOT}etc/resolv.conf")" != "${resolv_conf_path}" ]] ; then
			ewarn "To allow apps that use '${ROOT}etc/resolv.conf' to conenct to resolved,"
			ewarn "you should replace the resolv.conf symlink:"
			ewarn "    ln -snf '${resolv_conf_path}' '${ROOT}etc/resolv.conf'"
			echo
		fi
	fi

	if ! [[ "$(readlink "${ROOT}etc/mtab")" == */proc/self/mounts ]] ; then
		ewarn "'${ROOT}etc/mtab' is not a symlink to '/proc/self/mounts'! ${PN} may fail to work."
	fi
}

pkg_prerm() {
	# If removing systemd completely, remove the catalog database.
	if [[ -z "${REPLACED_BY_VERSION}" ]] ; then
		nonfatal erm -f "${ROOT}var/lib/systemd/catalog/database"
	fi
}
