# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

GH_USER='supercrabtree'

inherit github

DESCRIPTION='Directory listings for zsh with git features'
LICENSE='MIT'

SLOT='0'

KEYWORDS='~amd64 ~x86 ~arm'

RDEPEND="app-shells/zsh"

src_install() {
	insinto "usr/share/${PN}"
	doins 'k.sh'

	dodoc 'readme.md'
}
