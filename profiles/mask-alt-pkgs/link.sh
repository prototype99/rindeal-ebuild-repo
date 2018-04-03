#!/bin/bash

# set -vx
set -ue

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if (( $# != 1 )) ; then
	echo "Usage: $0 DST_DIR"
	echo ""
	echo "Example:"
	echo ""
	echo "    $0 /etc/portage/package.mask/rindeal-mask-alt-pkgs"
	echo ""
	exit 1
fi

DST_DIR="${1}"

if ! [[ -d "${DST_DIR}" ]] ; then
	if ! mkdir -v "${DST_DIR}" ; then
		echo "DST_DIR is not a directory or it couldn't be created"
		exit 1
	fi
fi

for d in "${SCRIPT_DIR}"/* ; do
	if ! [[ -d "${d}" ]] ; then
		echo "'${d}' is not a directory -> skipping"
		continue
	fi

	pmask_file="${d}/package.mask"
	repo_name="$(basename "${d}")"

	ln -vfs "${pmask_file}" "${DST_DIR}/${repo_name}"
done
