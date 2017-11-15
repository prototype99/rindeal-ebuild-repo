# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# upstream guide https://github.com/econsysqtcam/qtcam/blob/master/INSTALL

EAPI=6
inherit rindeal

GH_RN="github:econsysqtcam"

inherit git-hosting
inherit qmake-utils
inherit eutils

DESCRIPTION='Webcamera software based on Qt, with many features'
HOMEPAGE="${GH_HOMEPAGE} http://www.e-consystems.com/opensource-linux-webcam-software-application.asp"
LICENSE='GPL-3'

SLOT='0'

KEYWORDS='~amd64'

# libv4l-dev qt5-default libudev-dev libavcodec-extra-54 qtdeclarative5-dev libusb-1.0-0-dev libjpeg-turbo8-dev qtdeclarative5-window-plugin qtdeclarative5-dialogs-plugin qtdeclarative5-controls-plugin qtdeclarative5-qtquick2-plugin
CDEPEND_A=(
	'virtual/ffmpeg:0'
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

S_ORIG="${S}"
S="${S}/src"

src_prepare() {
	### patches should be relative to the top level dir
	cd "${S_ORIG}" || die

	eapply_user

	###
	cd "${S}" || die

	local sed_args=(
		-e '\|/usr/include|d'
		-e '/^LIBS/,/^ *$/d'
	)
	sed -r "${sed_args[@]}" -i -- 'qtcam.pro' || die

	# make sure there is at least one empty line at the end before adding anything
	echo >> 'qtcam.pro'

	## add corrected dependencies back
	local deps=( )
	local libs=( "${deps[@]}"
		'lib'{avcodec,avformat,avutil,swresample,swscale}
	)
	local includes=( "${deps[@]}" 'libusb-1.0' )

	"$(tc-getPKG_CONFIG)" --libs "${libs[@]}" | \
		awk '{print "LIBS += ",$0}' >> 'qtcam.pro'
	assert
	"$(tc-getPKG_CONFIG)" --cflags-only-I "${includes[@]}" | \
		sed -r 's| *-I([^ ]*) *|INCLUDEPATH += "\1"\n|g' >> 'qtcam.pro'
	assert
}

src_configure() {
	eqmake5 'qtcam.pro'
}

src_install() {
	emake DESTDIR="${D}" install

	domenu 'Qtcam.desktop'
}
