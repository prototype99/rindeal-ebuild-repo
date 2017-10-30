# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github"

# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
# functions: dobashcomp
inherit bash-completion-r1

DESCRIPTION="Use Git to upload only changed files to FTP servers"
LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( man )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"man? ( || ( app-text/pandoc-bin app-text/pandoc ) )"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-vcs/git"
	"net-misc/curl[protocol_ftps]"
)

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_compile() {
	use man && emake -C man man
}

src_install() {
	dobin ${PN}

	dodoc README.md CHANGELOG.md

	use man && doman man/${PN}.1
}
