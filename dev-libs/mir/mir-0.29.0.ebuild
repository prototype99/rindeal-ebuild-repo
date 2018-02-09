# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## WARNING this package is not finished yet WARNING ##

## functions:
inherit rindeal-utils
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake-utils
## functions: get_version_component_range
inherit versionator

DESCRIPTION="Display server technology"
HOMEPAGE="https://launchpad.net/mir"
LICENSE="GPL-2 GPL-3 LGPL-3 MIT"

SLOT="0"
SRC_URI="https://launchpad.net/${PN}/$(get_version_component_range 1-2)/${PV}/+download/${P}.tar.xz"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
	test

	+mesa-kms +mesa-x11 eglstream-kms
	+libGL libGLESv2
)

CDEPEND_A=(
	"dev-libs/boost:0"
	"$(rindeal:dsf:eval \
		'mesa-kms|mesa-x11' \
			"media-libs/mesa
			x11-libs/libdrm"
	)"
	"libGL? ( media-libs/mesa )"
	"libGLESv2? ( media-libs/mesa[gles2] )"

	"eglstream-kms? ("
		"media-libs/libepoxy"
		"x11-libs/libdrm"
	")"

	"media-libs/glm"
	"dev-libs/protobuf"
	"dev-libs/capnproto"
	"dev-cpp/glog"
	"dev-cpp/gflags"

	"dev-libs/userspace-rcu" # LIBURCU_BP
	"dev-util/lttng-ust" # LTTNG_UST
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"|| ("
		"mesa-kms"
		"mesa-x11"
		"eglstream-kms"
	")"
	"^^ ( libGL libGLESv2 )"
)
RESTRICT+=""

inherit arrays

src_prepare()
{
	esed -e '/enable_coverage_report/d' -i -- CMakeLists.txt

	cmake-utils_src_prepare
}

src_configure()
{
	local mycmakeargs=(
		-D use_debflags=OFF
		-D MIR_USE_LD_GOLD=OFF
		-D MIR_LINK_TIME_OPTIMIZATION=OFF

		-D MIR_DISABLE_EPOLL_REACTOR=OFF # unly usable by old kernels
		-D MIR_ENABLE_TESTS=$(usex test)

		-D ENABLE_MEMCHECK_OPTION=OFF
		-D MIR_USE_PRECOMPILED_HEADERS=ON
	)

	local mir_backends=(
		$(usev mesa-kms)
		$(usev mesa-x11)
		$(usev eglstream-kms)
	)
	mycmakeargs+=( -D MIR_PLATFORM="$( IFS=";" ; echo "${mir_backends[*]}" )" )

	if use libGL ; then
		mycmakeargs+=( -D MIR_SERVER_LIBGL=libGL )
	elif use libGLESv2 ; then
		mycmakeargs+=( -D MIR_SERVER_LIBGL=libGLESv2 )
	else
		die
	fi
	cmake-utils_src_configure
}
