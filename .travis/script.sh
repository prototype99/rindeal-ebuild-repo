#!/bin/bash

set -vue

DOCKER_REPO="${1}" ; shift
DOCKER_TAG="${1}" ; shift

docker=(
	docker run
	-v ${PWD}:/repo:ro
	"${DOCKER_REPO}:${DOCKER_TAG}"
	repoman-pretty-scan --travis-ci -- --xmlparse --without-mask
)

"${docker[@]}"
