# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: ninja-utils-patched.eclass
# @MAINTAINER:
# Jan Chren (rindeal) <dev.rindeal+gentoo-overlay@gmail.com>
# @BLURB: <SHORT_DESCRIPTION>
# @DESCRIPTION:


case "${EAPI:-0}" in
    5|6) ;;
    *) die "Unsupported EAPI='${EAPI}' for '${ECLASS}'" ;;
esac


inherit versionator


# make sure we apply the hook only once
if [[ -z "$(type -t __original_version_compare 2>/dev/null)" ]] ; then

# save original version_compare() implementation under different name
eval "__original_$(declare -f version_compare)"

version_compare() {
	if (( $# == 2 )) ; then
		__original_version_compare "${@}"
	elif (( $# == 3 )) ; then
		__original_version_compare "${1}" "${3}"
		local code=$?
		case "${2}" in
			"<") (( code == 1 )) ;;
			">") (( code == 3 )) ;;
			"==") (( code == 2 )) ;;
			*) die ;;
		esac
		return
	else
		die
	fi
}

fi
