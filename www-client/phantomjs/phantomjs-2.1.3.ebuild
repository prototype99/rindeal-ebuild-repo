# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

## git-hosting.eclass:
GH_RN='github:ariya'

inherit git-hosting
inherit python-any-r1
## functions: qt5_get_bindir
inherit qmake-utils
## functions: makeopts_jobs
inherit multiprocessing
## functions: pax-mark
inherit pax-utils
## functions: virtx
inherit virtualx

DESCRIPTION='Headless WebKit scriptable with a JavaScript API'
HOMEPAGE='http://phantomjs.org'
LICENSE='BSD'

SLOT='0'

KEYWORDS='amd64 ~arm ~arm64'
IUSE_A=( examples test )

## http://phantomjs.org/build.html - says pretty much nothing
## https://anonscm.debian.org/cgit/collab-maint/phantomjs.git/tree/debian
CDEPEND_A=(
	'dev-qt/qtcore:5'
	'dev-qt/qtgui:5'
	'dev-qt/qtnetwork:5'
	'dev-qt/qtprintsupport:5'
	'dev-qt/qtwebkit:5'
	'dev-qt/qtwidgets:5'

	'dev-libs/icu:='
	'dev-libs/openssl:0'
	'dev-db/sqlite:3'
	'sys-libs/zlib'

	'x11-libs/libXext'
	'x11-libs/libX11'

	'media-libs/mesa'
	'media-libs/libpng:0='
	'virtual/jpeg:0'
)
DEPEND_A=( "${CDEPEND_A[@]}"
	'sys-devel/bison'
	'sys-devel/flex'

	"${PYTHON_DEPS}"
	'dev-lang/perl'
	'test? ( dev-lang/ruby )'
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_prepare() {
	PATCHES=(
		"${FILESDIR}/${PN}-no-ghostdriver.patch"
		"${FILESDIR}/${PN}-qt-components.patch"
		"${FILESDIR}/${PN}-qt55-evaluateJavaScript.patch"
		"${FILESDIR}/${PN}-qt55-no-websecurity.patch"
		"${FILESDIR}/${PN}-qt55-print.patch"
		"${FILESDIR}"/05-qt-qpa-platform-plugin.patch
	)
	default

	# c&p from qmake5()
	local qmake_args=(
		-makefile
		QMAKE_AR="$(tc-getAR) cqs"
		QMAKE_CC="$(tc-getCC)"
		QMAK_ELINK_C="$(tc-getCC)"
		QMAKE_LINK_C_SHLIB="$(tc-getCC)"
		QMAKE_CXX="$(tc-getCXX)"
		QMAKE_LINK="$(tc-getCXX)"
		QMAKE_LINK_SHLIB="$(tc-getCXX)"
		QMAKE_OBJCOPY="$(tc-getOBJCOPY)"
		QMAKE_RANLIB=
		QMAKE_STRIP=
		QMAKE_CFLAGS="${CFLAGS}"
		QMAKE_CFLAGS_RELEASE=
		QMAKE_CFLAGS_DEBUG=
		QMAKE_CXXFLAGS="${CXXFLAGS}"
		QMAKE_CXXFLAGS_RELEASE=
		QMAKE_CXXFLAGS_DEBUG=
		QMAKE_LFLAGS="${LDFLAGS}"
		QMAKE_LFLAGS_RELEASE=
		QMAKE_LFLAGS_DEBUG=
	)

	## make sure correct qmake is used
	esed -r -e "s|qmake = qmakePath.*|qmake = \"$(qt5_get_bindir)/qmake\"|" -i -- 'build.py'
	esed -r -e "s|command = \[qmake\].*|command = [qmake, $( printf '"%s",' "${qmake_args[@]}" )\"\"]|" -i -- 'build.py'

	# delete check for Qt version as Portage has already taken care of it
	esed -r -e '/^if\(!equals\(QT_MAJOR_VERSION/ , /}/d' -i -- 'src/phantomjs.pro'
}

src_compile() {
	local build_py=(
		"${PYTHON}" 'build.py'

		'--confirm'
		'--release'
		'--jobs' $(makeopts_jobs)

		'--skip-'{git,qtbase,qtwebkit}
	)

	einfo "Executing: '${build_py[*]}'"
	"${build_py[@]}" || die
}

src_test() {
	virtx "${PYTHON}" 'test/run-tests.py' || die
	# ./bin/phantomjs test/run-tests.js || die
}

src_install() {
	pax-mark m "bin/${PN}"
	dobin "bin/${PN}"
	doman "${FILESDIR}/${PN}.1"

	einstalldocs

	if use examples ; then
		docinto examples
		dodoc -r examples
	fi
}
