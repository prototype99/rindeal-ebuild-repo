# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:rg3"

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit bash-completion-r1
inherit distutils-r1
inherit eutils
inherit git-hosting

DESCRIPTION="Download videos from YouTube.com (and more sites...)"
LICENSE="public-domain"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( +man test )

CDEPEND_A=(
	"dev-python/setuptools[${PYTHON_USEDEP}]"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"man? ("
		"|| ("
			"app-text/pandoc-bin"
			"app-text/pandoc"
		")"
	")"
	"test? ( dev-python/nose[coverage(+)] )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

python_compile_all() {
	local emake_args=(
		V=1
		bash-completion
		zsh-completion
		fish-completion
		$(use man && echo ${PN}.1)
	)
	emake "${emake_args[@]}"
}

python_test() {
	emake test
}

python_install_all() {
	use man && doman ${PN}.1

	newbashcomp ${PN}.bash-completion ${PN}

	insinto /usr/share/zsh/site-functions
	newins youtube-dl.zsh _youtube-dl

	insinto /usr/share/fish/completions
	doins youtube-dl.fish

	distutils-r1_python_install_all

	erm -r "${ED}"/usr/etc
	erm -r "${ED}"/usr/share/doc/youtube_dl
}