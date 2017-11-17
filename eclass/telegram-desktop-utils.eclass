# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: telegram-desktop-utils.eclass
# @MAINTAINER:
# Jan Chren (rindeal) <dev.rindeal+gentoo-overlay@gmail.com>
# @BLURB: <SHORT_DESCRIPTION>
# @DESCRIPTION:

if [ -z "${_TELEGRAM_DESKTOP_UTILS}" ] ; then

case "${EAPI:-0}" in
    6) ;;
    *) die "Unsupported EAPI='${EAPI}' for '${ECLASS}'" ;;
esac


tgd-utils_get_qt_P() {
	echo "dev-qt/qt-telegram-static"
}

tgd-utils_get_QT_PREFIX() {
	(( $# != 3 )) && die
	local -n -- dst_var="$1" ; shift
	local -r -- qt_ver="$1" ; shift
	local -r -- qt_patch_num="$1" ; shift
	local -r -- qt_tg_static_PN="$(tgd-utils_get_qt_P | cut -d/ -f2)"

	dst_var="${EPREFIX}/opt/${qt_tg_static_PN}/${qt_ver}/${qt_patch_num}"
}


_TELEGRAM_DESKTOP_UTILS=1
fi
