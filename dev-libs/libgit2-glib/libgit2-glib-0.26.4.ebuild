# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:GNOME"
GH_REF="v${PV}"

## python-*.eclass:
PYTHON_COMPAT=( python3_{4,5,6} )

## vala.eclass:
VALA_USE_DEPEND="vapigen"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_configure src_compile src_test src_install
inherit meson
## EXPORT_FUNCTIONS: src_prepare
## functions: vala_depend
inherit vala
## functions: python_foreach_impl, python_moduleinto, python_domodule, python_get_sitedir
## variables: PYTHON_DEPS, PYTHON_USEDEP
inherit python-r1
## functions: get_version_component_range
inherit versionator

DESCRIPTION="Glib wrapper library around the libgit2 git access library"
LICENSE="LGPL-2+"

SLOT="0"

KEYWORDS="amd64 arm arm64"
IUSE_A=( debug doc introspection python ssh vala )

CDEPEND_A=(
	"dev-libs/glib:2"
	"dev-libs/libgit2:0/$(get_version_component_range 2)[ssh?]"
	"introspection? ( dev-libs/gobject-introspection:= )"
	"python? ("
		"${PYTHON_DEPS}"
		"dev-python/pygobject:3[${PYTHON_USEDEP}] )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
	"doc? ( dev-util/gtk-doc )"
	"vala? ( $(vala_depend) )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_prepare() {
	eapply_user

	use vala && vala_src_prepare
}

src_configure() {
	local emesonargs=(
		-D buildtype="optimized $(usev debug)"

		$(meson_use doc gtk-doc)
		$(meson_use introspection)
		$(meson_use python)
		$(meson_use ssh)
		$(meson_use vala vapi)
	)
	meson_src_configure
}

src_install() {
	meson_src_install

	if use python ; then
		install_gi_override() {
			python_moduleinto "$(python_get_sitedir)/gi/overrides"
			python_domodule "${S}"/${PN}/Ggit.py
		}
		python_foreach_impl install_gi_override
	fi
}
