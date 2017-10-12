# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# autotools.eclass
# WANT_AUTOMAKE=2.64

# functions: eautoreconf
inherit autotools
# functions: replace_version_separator
inherit versionator

DESCRIPTION="GNU Compiler Collection"
HOMEPAGE="https://gcc.gnu.org/"
LICENSE="GPL-3+ LGPL-3+ || ( GPL-3+ libgcc libstdc++ gcc-runtime-library-exception-3.1 ) FDL-1.3+"

# According to gcc/c-cppbuiltin.c, GCC_CONFIG_VER MUST match this regex.
# ([^0-9]*-)?[0-9]+[.][0-9]+([.][0-9]+)?([- ].*)?
GCC_CONFIG_VER=${GCC_CONFIG_VER:-$(replace_version_separator 3 '-' ${GCC_PV})}

SLOT="${GCC_CONFIG_VER}"
SRC_URI_A=(
	"mirror://gnu/gcc/${P}/${P}.tar.xz"
)

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( doc ada graphite nls test
	+ld gold libquadmath libquadmath-support libada libssp +libstdcxx static-libjava
	+lto objc-gc vtable-verify werror host-shared
)

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	### https://gcc.gnu.org/install/prerequisites.html

	## ISO C++98 compiler
	"|| ("
		"sys-devel/gcc"
		"sys-devel/clang"
		"dev-lang/icc"
	")"
	## C standard library and headers
	## GNAT
	"ada? ( dev-lang/gnat-gpl )"
	## A "working" POSIX compatible shell, or GNU bash
	# N/A
	## A POSIX or SVR4 awk
	# N/A
	## GNU binutils
	"sys-devel/binutils"
	## gzip version 1.2.4 (or later) or
	## bzip2 version 1.0.2 (or later)
	# N/A
	## GNU make version 3.80 (or later)
	">=sys-devel/make-3.80"
	## GNU tar version 1.14 (or later)
	">=app-arch/tar-1.14"
	## Perl version 5.6.1 (or later)
	">=dev-lang/perl-5.6.1"
	## GNU Multiple Precision Library (GMP) version 4.3.2 (or later)
	">=dev-libs/gmp-4.3.2"
	## MPFR Library version 2.4.2 (or later)
	">=dev-libs/mpfr-2.4.2"
	## MPC Library version 0.8.1 (or later)
	">=dev-libs/mpc-0.8.1"
	## isl Library version 0.15 or later
	"graphite? ( >=dev-libs/isl-0.15 )"

	## autoconf version 2.64
	## GNU m4 version 1.4.6 (or later)
	"~sys-devel/autoconf-2.64"
	">=sys-devel/m4-1.4.6"
	## automake version 1.11.6
	">=sys-devel/automake-1.11.6"
	## gettext version 0.14.5 (or later)
	"nls? ( >=sys-devel/gettext-0.14.5 )"
	## gperf version 2.7.2 (or later)
	# N/A
	## DejaGnu 1.4.4
	## Expect
	## Tcl
	"test? ("
		"~dev-util/dejagnu-1.4.4"
		"dev-tcltk/expect"
		"dev-lang/tcl"
	")"
	## autogen version 5.5.4 (or later) and
	## guile version 1.4.1 (or later)
	">=sys-devel/autogen-5.5.4"
	">=dev-scheme/guile-1.4.1"
	## Flex version 2.5.4 (or later)
	">=sys-devel/flex-2.5.4"
	## Texinfo version 4.7 (or later)
	"doc? ( >=sys-apps/texinfo-4.7 )"
	## TeX (any working version)
	# N/A
	## Sphinx version 1.0 (or later)
	"doc? ( >=dev-python/sphinx-1.0 )"
	## SVN (any version)
	##SSH (any version)
	# N/A
	## GNU diffutils version 2.7 (or later)
	# N/A
	## patch version 2.5.4 (or later)
	# N/A
)
RDEPEND_A=( "${CDEPEND_A[@]}" )
PDEPEND=">=sys-devel/gcc-config-1.7"

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

export CTARGET=${CTARGET:-${CHOST}}
if [[ "${CTARGET}" == "${CHOST}" ]] ; then
	if [[ "${CATEGORY}" == cross-* ]] ; then
		export CTARGET="${CATEGORY#cross-}"
	fi
fi

PREFIX="${EPREFIX}/usr"
LIBPATH="${PREFIX}/lib/gcc/${CTARGET}/${GCC_CONFIG_VER}"


OBJDIR="${WORKDIR}/build"

pkg_setup() {
	filter-flags -frecord-gcc-switches # gentoo#490738
	filter-flags -mno-rtm -mno-htm # gentoo#506202
}

src_prepare() {
    eapply_user

#     # Fixup libtool to correctly generate .la files with portage
# 	elibtoolize --portage --shallow --no-uclibc

	gnuconfig_update

	WANT_AUTOCONF=2.64 eautoreconf

# 	if [[ -x contrib/gcc_update ]] ; then
# 		einfo "Touching generated files"
# 		./contrib/gcc_update --touch | \
# 			while read f ; do
# 				einfo "  ${f%%...}"
# 			done
# 	fi
}

src_configure() {
	emkdir "${OBJDIR}"
    epushd "${OBJDIR}"

    local myeconfargs=(
		# --enable-as-accelerator-for=ARG
		# --enable-offload-targets=LIST
		$(use_enable gold)
		$(use_enable ld)
		$(use_enable libquadmath)
		$(use_enable libquadmath-support)
		$(use_enable libada)
		$(use_enable libssp)
		$(use_enable libstdcxx)
		# --enable-liboffloadmic=ARG
		--enable-static-libjava=$(usex static-libjava)
		--enable-bootstrap
		# --disable-isl-version-check
		$(use_enable lto)
		# --enable-linker-plugin-configure-flags
		# --enable-linker-plugin-flags=FLAGS
		# --enable-stage1-languages
		$(use_enable objc-gc)
		$(use_enable vtable-verify)
		--enable-stage1-checking
		$(use_enable werror)
		$(use_enable host-shared)
		--disable-multilib

		--with-bugurl="https://ebuilds.janchren.eu/repos/rindeal/issues"
    )

	### language options

	local GCC_LANG="c"
	is_cxx && GCC_LANG+=",c++"
	is_d   && GCC_LANG+=",d"
	is_gcj && GCC_LANG+=",java"
	is_go  && GCC_LANG+=",go"
	is_jit && GCC_LANG+=",jit"
	if is_objc || is_objcxx ; then
		GCC_LANG+=",objc"
		if tc_version_is_at_least 4 ; then
			use objc-gc && confgcc+=( --enable-objc-gc )
		fi
		is_objcxx && GCC_LANG+=",obj-c++"
	fi

	# fortran support just got sillier! the lang value can be f77 for
	# fortran77, f95 for fortran95, or just plain old fortran for the
	# currently supported standard depending on gcc version.
	is_fortran && GCC_LANG+=",fortran"
	is_f77 && GCC_LANG+=",f77"
	is_f95 && GCC_LANG+=",f95"

	# We do NOT want 'ADA support' in here!
	# is_ada && GCC_LANG+=",ada"

	confgcc+=( --enable-languages=${GCC_LANG} )

    ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"

    epopd
}

src_compile() {
	epushd "${OBJDIR}"

	local emake_opts=(
		$(usex pgo profiledbootstrap bootstrap-lean)
	)

	emake "${emake_opts[@]}"

	epopd
}

src_compile() {
	epushd "${OBJDIR}"
	default
	epopd
}
