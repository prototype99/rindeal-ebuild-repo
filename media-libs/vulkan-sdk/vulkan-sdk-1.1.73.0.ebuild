# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:KhronosGroup:Vulkan-LoaderAndValidationLayers"
GH_REF="sdk-${PV}"

## python-any-r1.eclass:
PYTHON_COMPAT=( python3_{4,5,6} )

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake-utils
## EXPORT_FUNCTIONS: pkg_setup
inherit python-any-r1

DESCRIPTION="Vulkan ICD loader, validation layers, headers, demos, tests, ..."
LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
	+xcb +xlib wayland mir
	demos-target-{xcb,xlib,wayland,mir,display}
	+loader test layers demos vkjson +icd
)

CDEPEND_A=(
	"xcb? ( x11-libs/libxcb )"
	"xlib? ( x11-libs/libX11 )"
	"wayland? ( dev-libs/wayland )"
	"mir? ( dev-libs/mir )"

	"demos? ( dev-util/glslang )"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"?? ("
		demos-target-{xcb,xlib,wayland,mir,display}
	")"
)
RESTRICT+=""

inherit arrays

src_prepare() {
	eapply_user

	esed -r -e '/install\(.*\$\{CMAKE_INSTALL_BINDIR\}\)/ '"s|\\\$\{CMAKE_INSTALL_BINDIR\}\)|/usr/libexec/${PN})|" -i -- demos/CMakeLists.txt demos/*/CMakeLists.txt

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-D USE_CCACHE=OFF
		-D BUILD_WSI_XCB_SUPPORT=$(usex xcb)
		-D BUILD_WSI_XLIB_SUPPORT=$(usex xlib)
		-D BUILD_WSI_WAYLAND_SUPPORT=$(usex wayland)
		-D BUILD_WSI_MIR_SUPPORT=$(usex mir)
	)

	if use demos-target-xcb ; then
		mycmakeargs+=( -D DEMOS_WSI_SELECTION=XCB )
	elif use demos-target-xlib ; then
		mycmakeargs+=( -D DEMOS_WSI_SELECTION=XLIB )
	elif use demos-target-wayland ; then
		mycmakeargs+=( -D DEMOS_WSI_SELECTION=WAYLAND )
	elif use demos-target-mir ; then
		mycmakeargs+=( -D DEMOS_WSI_SELECTION=MIR )
	elif use demos-target-display ; then
		mycmakeargs+=( -D DEMOS_WSI_SELECTION=DISPLAY )
	fi

	mycmakeargs+=(
		-D BUILD_LOADER=$(usex loader)
		-D BUILD_TESTS=$(usex test)
		-D BUILD_LAYERS=$(usex layers)
		-D BUILD_DEMOS=$(usex demos)
		-D BUILD_VKJSON=$(usex vkjson)
		-D BUILD_ICD=$(usex icd)
	)

	cmake-utils_src_configure
}
