# Copyright 2015-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# functions: get_major_version, get_version_component_range
inherit versionator
# xdg: src_prepare, pkg_preinst, pkg_postinst, pkg_postrm
inherit xdg
# functions: newicon, make_desktop_entry
inherit eutils

# upstream moves older versions to a different SRC_URI, while the other one return 301 code instead of 404,
# thus the only way is to manually reflect the upstream in the ebuild
ARCHIVED=0

DESCRIPTION="Git client with support for GitHub Pull Requests+Comments, SVN and Mercurial"
HOMEPAGE="https://www.syntevo.com/${PN}"
LICENSE="${PN}"

# slot number is based on the upstream slotting mechanism which creates a new subdir
# in `~/.smartgit/` for each new major release. The subdir name corresponds with SLOT.
PV_MAJ="$(get_major_version)"
PV_MIN="$(get_version_component_range 2)"

SLOT="${PV_MAJ}$( (( PV_MIN )) && echo ".${PV_MIN}" )"
PN_SLOTTED="${PN}${SLOT}"
if (( ARCHIVED )) ; then
	SRC_URI="https://www.syntevo.com/static/smart/download/${PN}hg/archive/${PN}-linux-${PV//./_}.tar.gz"
else
	SRC_URI="https://www.syntevo.com/static/smart/download/${PN}/${PN}-linux-${PV//./_}.tar.gz"
fi

KEYWORDS="~amd64"

RDEPEND="
	>=virtual/jre-1.7
"

RESTRICT+=" mirror strip"

S="${WORKDIR}/${PN}"

src_install() {
	local -r VENDOR="syntevo"
	local -r install_dir="/opt/${VENDOR}/${PN_SLOTTED}"

	## copy files to the install image
	insinto "${install_dir}"
	doins -r .

	## install icons
	local s
	for s in 32 48 64 128 256 ; do
		newicon -s ${s} "bin/${PN}-${s}.png" "${PN_SLOTTED}.png"
	done

	## make scripts executable
	echmod a+x "${ED%/}${install_dir}/"{bin,lib}/*.sh

	## install symlink to /usr/bin
	dosym "${install_dir}/bin/${PN}.sh" "/usr/bin/${PN_SLOTTED}"

	## generate .desktop entry
	local make_desktop_entry_args=(
		"${PN_SLOTTED} %U"	# exec
		"SmartGit ${SLOT}"	# name
		"${PN_SLOTTED}"	# icon
		"Development"	# categories
	)
	local make_desktop_entry_extras=(
	)
	make_desktop_entry "${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "${PN} relies on external git/hg executables to work."
	optfeature "Git support" dev-vcs/git
	optfeature "Mercurial support" dev-vcs/mercurial
}
