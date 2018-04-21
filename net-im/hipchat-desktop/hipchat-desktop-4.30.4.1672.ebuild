# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## EXPORT_FUNCTIONS: src_unpack
inherit unpacker
## functions: get_major_version
inherit versionator
## EXPORT_FUNCTIONS: src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg
## functions: domenu
inherit desktop

DESCRIPTION="HipChat desktop client for Linux"
HOMEPAGE="https://www.hipchat.com/downloads#linux"
LICENSE="atlassian"

MY_PN="HipChat$(get_major_version)"
SLOT="0"
SRC_URI="https://atlassian.artifactoryonline.com/atlassian/hipchat-apt-client/pool/${MY_PN}-${PV}-Linux.deb"

KEYWORDS="~amd64"

CDEPEND=""
DEPEND="${CDEPEND}"
RDEPEND="${CDEPEND}"

RESTRICT+=" mirror"

inherit arrays

S="${WORKDIR}"

src_prepare() {
	eapply_user
	eapply "${FILESDIR}/linuxbrowserlaunch.patch"
}

src_install() {
	insinto /opt/
	doins -r opt/${MY_PN}

	domenu "usr/share/applications/${MY_PN,,}.desktop"

	insinto /usr/share/icons/
	doins -r usr/share/icons/hicolor

	fperms a+x /opt/${MY_PN}/bin/{${MY_PN},QtWebEngineProcess,hellocpp}
	fperms a+x /opt/${MY_PN}/lib/{linuxbrowserlaunch.sh,HipChat.bin,QtWebEngineProcess.bin}
}

QA_PREBUILT="opt/${MY_PN}/*"
