# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
inherit rindeal

GH_RN="github:videolan"
EGIT_SUBMODULES=()

inherit git-hosting
inherit eutils
# inherit multilib
inherit autotools
inherit toolchain-funcs
inherit flag-o-matic
inherit versionator
inherit virtualx

DESCRIPTION="VLC media player - Video player and streamer"
HOMEPAGE="https://www.videolan.org/vlc/ ${GH_HOMEPAGE}"
LICENSE="LGPL-2.1 GPL-2"

SLOT="0/5-8" # vlc - vlccore

IUSE_A=(
	### Optional Features and Packages:
	+shared-libs
	static-libs
	pic
	+gnu-ld
	nls
	+rpath
	dbus

	### Optimization options:
	cpu_flags_x86_mmx
	cpu_flags_x86_sse
	cpu_flags_arm_neon
	debug
	gprof
	cprof
	optimize-memory
	run-as-root
	+sout
	+lua
	+vlm
	+addonmanagermodules

	### Input plugins:
	archive
	live555
	dc1394
	dv1394
	linsys
	cprof
	dvdread
	dvdnav
	bluray
	opencv
	samba # smbclient
	dsm
	sftp
	nfs
	libv4l # v4l2
	decklink
	vcd
	libcddb
	+screen
	vnc
	freerdp
	realrtsp
	asdcp

	### Mux/Demux plugins:
	dvbpsi
	gme
	sid
	ogg
	shout
	+matroska
	modplug # mod
	musepack # mpc

	### Codec plugins:
	wma-fixed
	+shine
	omxil
	omxil-vout
	rpi-omxil
	crystalhd
	mad
	mpg123
	+gstreamer # gst-decode
	merge-ffmpeg
	+avcodec
	vaapi # libva
	+avformat
	+swscale
	+postproc
	faad
	aom
	+vpx
	twolame
	fdkaac
	a52
	dts # dca
	flac
	libmpeg2
	vorbis
	tremor
	speex
	+opus
	spatialaudio
	theora
	oggspots
	daala
	schroedinger
	png
	jpeg
	bpg
	x262
	x265
	x26410b
	+x264
	mfx
	fluidsynth
	fluidlite
	zvbi
	telx
	+libass
	aribsub
	aribb25
	kate
	libtiger # tiger

	### Video plugins:
	gles2
	+X
	+xcb
	xvideo
	vdpau
	wayland
	sdl-image
	freetype
	fribidi
	harfbuzz
	fontconfig
	svg
	svgdec
	aa
	libcaca # caca
	mmal # TODO
	evas

	### Audio plugins:
	+pulseaudio # pulse
	+alsa
	jack
	opensles
	tizen-audio
	libsamplerate # samplerate
	soxr
	chromaprint
	chromecast

	### Interface plugins:
	+qt5
	skins # skins2
	libtar
	ncurses
	lirc
	srt

	### Visualisations and Video filter plugins:
	goom
	projectm
	vsxu

	### Service Discovery plugins:
	avahi
	udev
	mtp
	upnp
	microdns

	### Misc plugins:
	xml # libxml2
	+libgcrypt
	+gnutls
	+taglib
	secret
	kwallet
	+libnotify # notify

	### Components:
	+vlc

	### Custom ###
	+truetype
	+httpd
	sdl
)
[[ "${PV}" == *9999* ]] || \
KEYWORDS="~amd64 ~arm ~arm64"

CDEPEND_A=(
	"dev-libs/libgpg-error:0"
	"net-dns/libidn:0"
	">=sys-libs/zlib-1.2.5.1-r2:0[minizip]"
	"virtual/libintl:0"
	"a52? ( >=media-libs/a52dec-0.7.4-r3:0 )"
	"aa? ( media-libs/aalib:0 )"
	"alsa? ( >=media-libs/alsa-lib-1.0.24:0 )"
	"avcodec? ( media-video/ffmpeg:0= )"
	"avformat? ( media-video/ffmpeg:0= )"
	"fribidi? ( >=dev-libs/fribidi-0.10.4:0 )"
	"bluray? ( >=media-libs/libbluray-0.6.2:0 )"
	"libcddb? ( >=media-libs/libcddb-1.2:0 )"
	"chromaprint? ( >=media-libs/chromaprint-0.6:0 )"
	"chromecast? ( >=dev-libs/protobuf-2.5.0 )"
	"dbus? ( >=sys-apps/dbus-1.6:0 )"
	"dc1394? ( >=sys-libs/libraw1394-2.0.1:0 >=media-libs/libdc1394-2.1:2 )"
	"dts? ( >=media-libs/libdca-0.0.5:0 )"
	"dvbpsi? ( >=media-libs/libdvbpsi-1.2.0:0= )"
	"dvdread? ( >=media-libs/libdvdread-4.9:0 )"
	"dvdnav? ( >=media-libs/libdvdnav-4.9:0 )"
	"elibc_glibc? ( >=sys-libs/glibc-2.8:2.2 )"
	"faad? ( >=media-libs/faad2-2.6.1:0 )"
	"fdkaac? ( media-libs/fdk-aac:0 )"
	"flac? ( >=media-libs/libogg-1:0 >=media-libs/flac-1.1.2:0 )"
	"fluidsynth? ( >=media-sound/fluidsynth-1.1.2:0 )"
	"fontconfig? ( media-libs/fontconfig:1.0 )"
	"libgcrypt? ( >=dev-libs/libgcrypt-1.6.0:0= )"
	"gme? ( media-libs/game-music-emu:0 )"
	"gnutls? ( >=net-libs/gnutls-3.2.0:0 )"
	"gstreamer? ( >=media-libs/gst-plugins-base-1.4.5:1.0 )"
	"dv1394? ( >=sys-libs/libraw1394-2.0.1:0 >=sys-libs/libavc1394-0.5.3:0 )"
	"jack? ( >=media-sound/jack-audio-connection-kit-0.120.1:0 )"
	"jpeg? ( virtual/jpeg:0 )"
	"kate? ( >=media-libs/libkate-0.3:0 )"
	"libass? ( >=media-libs/libass-0.9.8:0 media-libs/fontconfig:1.0 )"
	"libcaca? ( >=media-libs/libcaca-0.99_beta14:0 )"
	"libnotify? ("
		"x11-libs/libnotify:0"
		"x11-libs/gtk+:2"
		"x11-libs/gdk-pixbuf:2"
		"dev-libs/glib:2"
	")"
	"libsamplerate? ( media-libs/libsamplerate:0 )"
	"libtar? ( >=dev-libs/libtar-1.2.11-r3:0 )"
	"libtiger? ( >=media-libs/libtiger-0.3.1:0 )"
	"linsys? ( >=media-libs/zvbi-0.2.28:0 )"
	"lirc? ( app-misc/lirc:0 )"
	"live555? ( >=media-plugins/live-2011.12.23:0 )"
	"lua? ( >=dev-lang/lua-5.1:0 )"
	"matroska? ("
		">=dev-libs/libebml-1:0="
		">=media-libs/libmatroska-1:0="
	")"
	"modplug? ("
		">=media-libs/libmodplug-0.8.4:0"
		"!~media-libs/libmodplug-0.8.8"
	")"
	"mad? ( media-libs/libmad:0 )"
	"libmpeg2? ( >=media-libs/libmpeg2-0.3.2:0 )"
	"mtp? ( >=media-libs/libmtp-1:0 )"
	"musepack? ( >=media-sound/musepack-tools-444:0 )"
	"ncurses? ( sys-libs/ncurses:0=[unicode] )"
	"ogg? ( >=media-libs/libogg-1:0 )"
	"opencv? ( >media-libs/opencv-2:0 )"
	"opus? ( >=media-libs/opus-1.0.3:0 )"
	"png? ( media-libs/libpng:0= sys-libs/zlib:0 )"
	"postproc? ( >=media-video/ffmpeg-3.1.3:0= )"
	"projectm? ( media-libs/libprojectm:0 media-fonts/dejavu:0 )"
	"pulseaudio? ( >=media-sound/pulseaudio-1:0 )"
	"qt5? ("
		"dev-qt/qtgui:5"
		"dev-qt/qtcore:5"
		"dev-qt/qtwidgets:5"
		"dev-qt/qtx11extras:5"
	")"
	"freerdp? ( >=net-misc/freerdp-1.0.1:0= )"
	"samba? ("
		"|| ("
			">=net-fs/samba-3.4.6:0[smbclient]"
			">=net-fs/samba-4:0[client]"
		")"
	")"
	"schroedinger? ( >=media-libs/schroedinger-1.0.10:0 )"
	"sdl? ( >=media-libs/libsdl-1.2.10:0"
		"sdl-image? ("
			">=media-libs/sdl-image-1.2.10:0"
			"sys-libs/zlib:0"
		")"
	")"
	"sftp? ( net-libs/libssh2:0 )"
	"shout? ( >=media-libs/libshout-2.1:0 )"
	"sid? ( media-libs/libsidplay:2 )"
	"skins? ("
		"x11-libs/libXext:0"
		"x11-libs/libXpm:0"
		"x11-libs/libXinerama:0"
	")"
	"speex? ( media-libs/speex:0 )"
	"svg? ( >=gnome-base/librsvg-2.9:2 >=x11-libs/cairo-1.13.1:0 )"
	"swscale? ( media-video/ffmpeg:0= )"
	"taglib? ( >=media-libs/taglib-1.9:0 sys-libs/zlib:0 )"
	"theora? ( >=media-libs/libtheora-1.0_beta3:0 )"
	"tremor? ( media-libs/tremor:0 )"
	"truetype? ( media-libs/freetype:2 virtual/ttf-fonts:0"
	"!fontconfig? ( media-fonts/dejavu:0 ) )"
	"twolame? ( media-sound/twolame:0 )"
	"udev? ( >=virtual/udev-142:0 )"
	"upnp? ( net-libs/libupnp:0 )"
	"libv4l? ( media-libs/libv4l:0 )"
	"vaapi? ("
		"x11-libs/libva:0[X,drm]"
		">=media-video/ffmpeg-3.1.3:0=[vaapi]"
	")"
	"vcd? ( >=dev-libs/libcdio-0.78.2:0 )"
	"avahi? ( >=net-dns/avahi-0.6:0[dbus] )"
)

DEPEND_A=( "${CDEPEND_A[@]}"
	"xcb? ( x11-proto/xproto:0 )"
	"app-arch/xz-utils:0"
	"dev-lang/yasm:*"
	">=sys-devel/gettext-0.19.6:*"
	"virtual/pkgconfig:*"
)

# Temporarily block non-live FFMPEG versions as they break vdpau, 9999 works;
# thus we'll have to wait for a new release there.
RDEPEND_A=( "${CDEPEND_A[@]}"
	"vdpau? ( >=x11-libs/libvdpau-0.6:0 )"
	"vnc? ( >=net-libs/libvncserver-0.9.9:0 )"
	"vorbis? ( >=media-libs/libvorbis-1.1:0 )"
	"vpx? ( media-libs/libvpx:0= )"
	"X? ( x11-libs/libX11:0 )"
	"x264? ( >=media-libs/x264-0.0.20090923:0= )"
	"x265? ( media-libs/x265:0= )"
	"xcb? ( >=x11-libs/libxcb-1.6:0 >=x11-libs/xcb-util-0.3.4:0 >=x11-libs/xcb-util-keysyms-0.3.4:0 )"
	"xml? ( >=dev-libs/libxml2-2.5:2 )"
	"zvbi? ( >=media-libs/zvbi-0.2.28:0 )"
)

REQUIRED_USE_A=(
	"^^ ( static-libs shared-libs )"

	"aa? ( X )"
	"fribidi? ( truetype )"
	"fontconfig? ( truetype )"
	"gnutls? ( libgcrypt )"
	"httpd? ( lua )"
	"libcaca? ( X )"
	"libtar? ( skins )"
	"libtiger? ( kate )"
	"qt5? ( X )"
	"sdl? ( X )"
	"skins? ( truetype X qt5 )"
	"vaapi? ( avcodec X )"
	"vlm? ( sout )"
	"xvideo? ( xcb )"
)

inherit arrays

pkg_setup() {
	# If qtchooser is installed, it may break the build, because moc,rcc and uic binaries for wrong qt version may be used.
	# Setting QT_SELECT environment variable will enforce correct binaries.
	use qt5 && export QT_SELECT=qt5

	# Compatibility fix for Samba 4.
	use samba && append-cppflags "-I/usr/include/samba-4.0"

	# VLC now requires C++11 after commit 4b1c9dcdda0bbff801e47505ff9dfd3f274eb0d8
	append-cxxflags -std=c++11

	# Needs libresid-builder from libsidplay:2 which is in another directory...
	# FIXME!
	append-ldflags "-L/usr/$(get_libdir)/sidplay/builders/"
}

src_prepare() {
	eapply_user

	# we call autoreconf manually in eautoreconf()
	sed -e '/^autoreconf/ s|^|# |' -i ./bootstrap || die
	# Bootstrap when we are on a git checkout.
	if [[ "${PV}" == *9999* ]] ; then
		./bootstrap || die
	fi

	# Make it build with libtool 1.5
# 	erm m4/lt* m4/libtool.m4

	# We are not in a real git checkout due to the absence of a .git directory.
	touch src/revision.txt || die

	# Fix build system mistake.
	eapply "${FILESDIR}"/${PN}-2.1.0-fix-libtremor-libs.patch

	# Fix up broken audio when skipping using a fixed reversed bisected commit.
	eapply "${FILESDIR}"/${PN}-2.1.0-TomWij-bisected-PA-broken-underflow.patch

	# Don't use --started-from-file when not using dbus.
	if ! use dbus ; then
		sed 's, --started-from-file,,' -i -- share/vlc.desktop.in || die
	fi

	eautoreconf

	# Disable automatic running of tests.
	find -name 'Makefile.in' -print0 | xargs -0 sed -i 's/\(..*\)check-TESTS/\1/'
	assert
}

src_configure() {
	local econf_args=(
		### Optional Features and Packages:
# 		--with-binary-version=STRING
		--without-macosx-sdk
		--without-macosx-version-min
		--disable-winstore-app
		--without-contrib
		$(use_enable shared-libs shared)
		$(use_enable static-libs static)
		$(use_with pic)
		--enable-fast-install
		# --with-aix-soname
		$(use_with gnu-ld)
		# --with-sysroot
		--enable-libtool-lock
		$(use_enable nls)
		$(use_enable rpath)
		$(use_enable dbus)

		$(use_enable debug)
		$(use_enable gprof)
		$(use_enable cprof)
		--disable-coverage
		--without-sanitizer

		### Optimization options:
		--disable-optimizations
		$(use_enable cpu_flags_x86_mmx mmx)
		$(use_enable cpu_flags_x86_sse sse) # SSE (1-4)
		$(use_enable cpu_flags_arm_neon neon)
		$(use_enable arm64) # arm 64-bit optimizations
		--disable-altivec # powerpc optimizations
		$(use_enable optimize-memory) # optimize memory usage over performance

		$(use_enable run-as-root) # allow running VLC as root
		$(use_enable sout) # disable streaming output
		$(use_enable lua) # LUA scripting support
		$(use_enable vlm) # stream manager
		$(use_enable addonmanagermodules) # disable the addons manager modules

		### Input plugins:
		$(use_enable archive)
		$(use_enable live555)
		$(use_enable dc1394)
		$(use_enable dv1394)
		$(use_enable linsys)
		$(use_enable cprof)
		$(use_enable dvdread)
		$(use_enable dvdnav)
		$(use_enable bluray)
		$(use_enable opencv)
		$(use_enable samba smbclient)
		$(use_enable dsm)
		$(use_enable sftp)
		$(use_enable nfs)
		$(use_enable libv4l v4l2)
		$(use_enable decklink)
		# --with-decklink-sdk=DIR
		$(use_enable vcd)
		$(use_enable libcddb)
		$(use_enable screen)
		$(use_enable vnc)
		$(use_enable freerdp)
		$(use_enable realrtsp)
		$(use_enable asdcp)
		--disable-macosx-qtkit
		--disable-macosx-avfoundation

		### Mux/Demux plugins:
		$(use_enable dvbpsi)
		$(use_enable gme)
		$(use_enable sid)
		$(use_enable ogg)
		$(use_enable shout)
		$(use_enable matroska)
		$(use_enable modplug mod)
		$(use_enable musepack mpc)

		### Codec plugins:
		$(use_enable wma-fixed)
		$(use_enable shine)
		$(use_enable omxil)
		$(use_enable omxil-vout)
		$(use_enable rpi-omxil)
		$(use_enable crystalhd)
		# --with-mad=PATH
		$(use_enable mad)
		$(use_enable mpg123)
		$(use_enable gstreamer gst-decode)
		$(use_enable merge-ffmpeg)
		$(use_enable avcodec)
		$(use_enable vaapi libva)
		--disable-dxva2 # Windows
		--disable-d3d11va # Windows
		$(use_enable avformat)
		$(use_enable swscale)
		$(use_enable postproc)
		$(use_enable faad)
		$(use_enable aom)
		$(use_enable vpx)
		$(use_enable twolame)
		$(use_enable fdkaac)
		$(use_enable a52)
		# --with-a52=PATH
		$(use_enable dts dca)
		$(use_enable flac)
		$(use_enable libmpeg2)
		$(use_enable vorbis)
		$(use_enable tremor)
		$(use_enable speex)
		$(use_enable opus)
		$(use_enable spatialaudio)
		$(use_enable theora)
		$(use_enable oggspots)
		$(use_enable daala)
		$(use_enable schroedinger)
		$(use_enable png)
		$(use_enable jpeg)
		$(use_enable bpg)
		$(use_enable x262)
		$(use_enable x265)
		$(use_enable x26410b)
		$(use_enable x264)
		$(use_enable mfx)
		$(use_enable fluidsynth)
		$(use_enable fluidlite)
		$(use_enable zvbi)
		$(use_enable telx)
		$(use_enable libass)
		$(use_enable aribsub)
		$(use_enable aribb25)
		$(use_enable kate)
		$(use_enable libtiger tiger)

		### Video plugins:
		$(use_enable gles2)
		$(use_with X x)
		$(use_enable xcb)
		$(use_enable xvideo)
		$(use_enable vdpau)
		$(use_enable wayland)
		$(use_enable sdl-image)
		$(use_enable freetype)
		$(use_enable fribidi)
		$(use_enable harfbuzz)
		$(use_enable fontconfig)
		# --with-default-font=PATH
		# --with-default-monospace-font=PATH
		# --with-default-font-family=NAME
		# --with-default-monospace-font-family=NAME
		$(use_enable svg)
		$(use_enable svgdec)
		--disable-directx # Windows
		$(use_enable aa)
		$(use_enable libcaca caca)
		--disable-kva # OS/2
		$(use_enable mmal)
		$(use_enable evas)

		### Audio plugins:
		$(use_enable pulseaudio pulse)
		$(use_enable alsa)
		--disable-oss # BSD
		--disable-sndio # BSD
		--disable-wasapi # Windows
		$(use_enable jack)
		$(use_enable opensles)
		$(use_enable tizen-audio)
		$(use_enable libsamplerate samplerate)
		$(use_enable soxr)
		--disable-kai # BSD
		$(use_enable chromaprint)
		$(use_enable chromecast)

		### Interface plugins:
		$(use_enable qt5 qt)
		$(use_enable skins skins2)
		$(use_enable libtar)
		--disable-macosx # OSX
		--disable-sparkle # OSX
		--disable-breakpad # OSX
		--disable-minimal-macosx # OSX
		$(use_enable ncurses)
		$(use_enable lirc)
		$(use_enable srt)

		### Visualisations and Video filter plugins:
		$(use_enable goom)
		$(use_enable projectm)
		$(use_enable vsxu)

		### Service Discovery plugins:
		$(use_enable avahi)
		$(use_enable udev)
		$(use_enable mtp)
		$(use_enable upnp)
		$(use_enable microdns)
		### Misc options:
		$(use_enable xml libxml2)
		$(use_enable libgcrypt)
		$(use_enable gnutls)
		$(use_enable taglib)
		$(use_enable secret)
		$(use_enable kwallet)
		--disable-update-check
		--disable-osx-notifications # OSX
		$(use_enable libnotify notify)
		# --with-kde-solid=PATH

		### Components:
		$(use_enable vlc)
	)

	if use truetype || use projectm ; then
		local dejavu_dir="${EPREFIX}/usr/share/fonts/dejavu/"
		econf_args+=(
			--with-default-font=${dejavu_dir}/DejaVuSans.ttf
			--with-default-font-family=Sans
			--with-default-monospace-font=${dejavu_dir}/DejaVuSansMono.ttf
			--with-default-monospace-font-family=Monospace
		)
	fi

	econf "${econf_args[@]}"

	# ^ We don't have these disabled libraries in the Portage tree yet.

	# _FORTIFY_SOURCE is set to 2 in config.h, which is also the default value on Gentoo.
	# Other values of _FORTIFY_SOURCE may break the build (bug 523144), so definition should not be removed from config.h.
	# To prevent redefinition warnings, we undefine _FORTIFY_SOURCE at the very start of config.h file
	sed -e '1i#undef _FORTIFY_SOURCE' -i -- "${S}"/config.h || die
}

src_test() {
	Xemake check-TESTS
}

src_install() {
	DOCS=( AUTHORS THANKS NEWS README doc/fortunes.txt )
	default

	prune_libtool_files
}

pkg_postinst() {
	## Refresh plugins cache, required to prevent error messages like:
	##
	##     core libvlc error: stale plugins cache: modified /usr/local/lib/vlc/plugins/video_output/libcaca_plugin.so
	##
	if [[ "$ROOT" = "/" ]] && [[ -x "/usr/$(get_libdir)/vlc/vlc-cache-gen" ]] ; then
		einfo "Running /usr/$(get_libdir)/vlc/vlc-cache-gen on /usr/$(get_libdir)/vlc/plugins/"
		"/usr/$(get_libdir)/vlc/vlc-cache-gen" "/usr/$(get_libdir)/vlc/plugins/"
	else
		ewarn "We cannot run vlc-cache-gen (most likely ROOT!=/)"
		ewarn "Please run /usr/$(get_libdir)/vlc/vlc-cache-gen manually"
		ewarn "If you do not do it, vlc will take a long time to load."
	fi
}
