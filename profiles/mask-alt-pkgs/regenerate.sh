#!/bin/bash

set -xvue

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

printf "" > "${SCRIPT_DIR}/all/parent"

for d in "${SCRIPT_DIR}"/* ; do
	if ! [[ -d "${d}" ]] ; then
		echo "'${d}' is not a directory -> skipping"
		continue
	fi

	repo_name="$(basename "${d}")"

	if [[ "${repo_name}" == "all" ]] ; then
		echo "repo_name == 'all' -> skipping"
		continue
	fi

	echo "../${repo_name}" >> "${SCRIPT_DIR}/all/parent"

	EIX_LIMIT=0 eix --in-overlay rindeal --and --in-overlay "${repo_name}" --only-names | sed "s|$|::${repo_name}|" > "${d}/package.mask"
done
