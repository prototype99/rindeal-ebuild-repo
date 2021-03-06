# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## functions: make_desktop_entry, newicon
inherit desktop
## functions: tc-getCC
inherit toolchain-funcs
## EXPORT_FUNCTIONS: src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg

DESCRIPTION="Tool for ripping and streaming Blu-ray, HD-DVD and DVD discs"
HOMEPAGE="https://www.makemkv.com/"
LICENSE="LGPL-2.1 MPL-1.1 MakeMKV-EULA openssl"

MY_P_OSS="${PN}-oss-${PV}"
MY_P_BIN="${PN}-bin-${PV}"

SLOT="0"
SRC_URI_A=(
	https://www.makemkv.com/download{,/old}/${MY_P_OSS}.tar.gz
	https://www.makemkv.com/download{,/old}/${MY_P_BIN}.tar.gz
)

KEYWORDS="-* ~amd64"
IUSE_A=( +gui )

CDEPEND_A=(
	"dev-libs/expat"
	"sys-libs/glibc"
	"dev-libs/openssl:0[-bindist(-)]"
	"sys-libs/zlib"
	"media-video/ffmpeg:0="

	"gui? ("
		"dev-qt/qtcore:5"
		"dev-qt/qtdbus:5"
		"dev-qt/qtgui:5"
		"dev-qt/qtwidgets:5"
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	# used for http downloads, see 'HTTP_Download()' in '${MY_P_OSS}/libabi/src/httplinux.cpp'
	"net-misc/wget"
)

RESTRICT+=" test"

inherit arrays

declare -A L10N_LOCALES_MAP=(
	['zh']='chi'
	['da']='dan'
	['de']='deu'
	['nl']='dut'
	['fr']='fra'
	['it']='ita'
	['ja']='jpn'
	['no']='nor'
	['fa']='per'
	['pl']='pol'
	['pt_BR']='ptb'
	['es']='spa'
	['sv']='swe'
)
L10N_LOCALES=( "${!L10N_LOCALES_MAP[@]}" )
inherit l10n-r1

S="${WORKDIR}/${MY_P_OSS}"

pkg_setup() {
	[[ -n "${EPREFIX}" ]] && die "This package doesn't support EPREFIX, because of hardcoded paths in bundled binaries"
}

src_prepare() {
	eapply "${FILESDIR}"/path.patch

	xdg_src_prepare

	# make these vars global as they're used in src_install() as well
	declare -g -r -- \
        LOC_DIR="${WORKDIR}/${MY_P_BIN}"/src/share \
        LOC_PRE='makemkv_' \
        LOC_POST='.mo.gz'
	l10n_find_changes_in_dir "${LOC_DIR}" "${LOC_PRE}" "${LOC_POST}"
}

src_configure() {
	local econf_args=(
		--enable-debug # do not strip symbols -- this will be done by portage itself
		--disable-noec # use openssl instead of custom crypto
		--disable-qt4 # Qt4 is no longer supported in Gentoo repos
		$(use_enable gui qt5)
		$(use_enable gui)
	)

	econf "${econf_args[@]}"
}

src_compile() {
	emake GCC="$(tc-getCC) ${CFLAGS} ${LDFLAGS}"
}

my_install_envd() {
	newenvd <(cat <<-_EOF_
			# Automatically generated by ${CATEGORY}/${PF} on $(date --utc -Iminutes)
			#
			# MakeMKV can act as a drop-in replacement for libaacs and libbdplus allowing
			# transparent decryption of a wider range of titles under players like VLC and mplayer.
			#
			LIBAACS_PATH=libmmbd
			LIBBDPLUS_PATH=libmmbd

			_EOF_
		) "20-${PN}-libmmbd"
}

my_install_key_updater() {
	exeinto "/usr/libexec/${PN}"
	newexe <(cat <<-_EOF_
		#!/bin/sh
		echo "Retrieving new key..."
		new_key="\$( wget -q -O - 'https://www.makemkv.com/forum2/viewtopic.php?f=5&t=1053' | \
			grep -Po '(?<=<div class="codecontent">)T[^<>]+'
		)"
		echo "The newest beta key is: '\${new_key}'"
		echo
		echo "Updating config file..."

		config_dir="\$(realpath ~/.MakeMKV)"
		config_file="settings.conf"

		mkdir -p "\${config_dir}" 2>/dev/null
		f="\${config_dir}/\${config_file}"

		# delete old value
		if [ -f "\${f}" ] ; then
			sed -e '/app_Key/d' -i -- "\${f}"
		fi

		echo "app_Key = \"\${new_key}\"" >>"\${f}" || echo "Error appending to the config file"
		echo "OK"
		_EOF_
	) update-beta-key.sh
}

src_install-oss() {
	### Install OSS components
	cd "${WORKDIR}/${MY_P_OSS}" || die

	local lib
	for lib in libdriveio libmakemkv libmmbd ; do
		local path="$(echo "out/${lib}.so."?)"
		local name="${path##"out/"}"
		dolib.so "${path}"
		## these symlinks are not installed by upstream
		## TODO: are they still necessary?
		dosym "${name}"	"/usr/$(get_libdir)/${name}.${PV}"
		dosym "${name}"	"/usr/$(get_libdir)/${lib}.so"
	done

	find -type d -name "inc" | \
	while read -r dir ; do
		local insdir="/usr/include/makemkv"
		local libdirname="$( basename "$( dirname "${dir}" )" )"

		insinto "${insdir}/${libdirname}"
		doins -r "${dir}"

		instincdir="${ED}/${insdir}/${libdirname}/inc"
		emv "${instincdir}"/* "${instincdir%%"/inc"}"
		ermdir "${instincdir}"
	done
	assert

	if use gui ; then
		dobin "out/${PN}"

		local s
		for s in 16 22 32 64 128 ; do
			newicon -s "${s}" "makemkvgui/share/icons/${s}x${s}/makemkv.png" "${PN}.png"
		done

		# Although upstream supplies .desktop file in '${MY_P_OSS}/makemkvgui/share/makemkv.desktop',
		# the generated one is better.
		make_desktop_entry "${PN}" "MakeMKV" "${PN}" 'Qt;AudioVideo;Video'
	fi

	my_install_envd
	my_install_key_updater

	## example config file
	insinto "/usr/share/MakeMKV"
	doins "${FILESDIR}/settings.conf.example"
}

src_install-bin() {
	### Install binary/pre-compiled/pre-generated components
	cd "${WORKDIR}/${MY_P_BIN}" || die

	## install prebuilt bins
	use amd64 || die && \
		dobin bin/amd64/makemkvcon

	## BEGIN: install misc files
	# this directory is hardcoded in the binaries
	insinto /usr/share/MakeMKV

	# install bluray support
	doins src/share/*.jar

	# install locales
	local l locales
	l10n_get_locales locales app on
	for l in ${locales} ; do
		doins "${LOC_DIR}/${LOC_PRE}${l}${LOC_POST}"
	done

	## END
}

src_install() {
	src_install-oss
	src_install-bin
}

QA_PREBUILT="usr/bin/makemkvcon usr/bin/mmdtsdec"

pkg_postinst() {
	xdg_pkg_postinst

	elog ""
	elog "While MakeMKV is in beta mode, upstream has provided a license"
	elog "to use if you do not want to purchase one."
	elog "See this forum thread for more information, including the key:"
	elog "  https://www.makemkv.com/forum2/viewtopic.php?f=5&t=1053"
	elog "Note that beta license has an expiration date and you will"
	elog "need to check for newer licenses/releases. But you can do so"
	elog "automatically by using '/usr/libexec/makemkv/update-beta-key.sh'"
	elog "script."
	elog ""
	elog "MakeMKV can also act as a drop-in replacement for libaacs and"
	elog "libbdplus, allowing transparent decryption of a wider range of"
	elog "titles under players like VLC and mplayer."
	elog "See '/etc/env.d/20-makemkv-libmmbd'."
	elog ""
}
