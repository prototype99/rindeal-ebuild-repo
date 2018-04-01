#!/bin/bash

set -xvue

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


for d in "${SCRIPT_DIR}"/* ; do
	if ! [[ -d "${d}" ]] ; then
		echo "'${d}' is not a directory -> skipping"
		continue
	fi

	repo_name="$(basename "${d}")"

	EIX_LIMIT=0 eix --in-overlay rindeal --and --in-overlay "${repo_name}" --only-names | sed "s|$|::${repo_name}|" > "${d}/package.mask"
done
