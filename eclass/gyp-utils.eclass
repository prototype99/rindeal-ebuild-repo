# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: gyp-utils.eclass
# @MAINTAINER:
# Jan Chren (rindeal) <dev.rindeal+gentoo-overlay@gmail.com>
# @BLURB: <SHORT_DESCRIPTION>
# @DESCRIPTION:

if [ -z "${_GYP_UTILS_ECLASS}" ] ; then

case "${EAPI:-0}" in
    6) ;;
    *) die "Unsupported EAPI='${EAPI}' for '${ECLASS}'" ;;
esac


inherit ninja-utils


DEPEND="dev-util/gyp"


: "${EGYP_COMMAND:=gyp}"

: "${EGYP_VERBOSE:=on}"

## MY_EGYP_ARGS

egyp() {
	local run=(
		"${EGYP_COMMAND}"
		"$( [[ "${EGYP_VERBOSE}" == "on" ]] && echo '--debug=all' )"
		# workaround for some internal gyp issues
		--depth=.

		## - cmake format is unmaintained and broken
		## - make format is not nicely implemented and has some issues
		--format=ninja
	)
	[[ -n "${MY_EGYP_ARGS}" ]] && run+=( "${MY_EGYP_ARGS[@]}" )
	run+=( "${@}" )

	printf "'%s' " "${run[@]}" ; printf '\n'

	"${run[@]}" || die -n
}


_GYP_UTILS_ECLASS=1
fi
