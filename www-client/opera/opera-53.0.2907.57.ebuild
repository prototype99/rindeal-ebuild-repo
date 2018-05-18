# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## chromium-2.eclass:
CHROMIUM_LANGS="
	be bg bn ca cs da de el en-GB en-US es-419 es fil fi fr-CA fr
	hi hr hu id it ja ko lt lv ms nb nl pl pt-BR pt-PT ro ru
	sk sr sv sw ta te th tr uk vi zh-CN zh-TW
"

## functions: chromium_remove_language_paks
inherit chromium-2
## functions: pax-mark
inherit pax-utils
## functions: get_version_component_range
inherit versionator
## EXPORT_FUNCTIONS: src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg
## functions: unpack
inherit unpacker

DESCRIPTION="Proprietary cross-platform web browser by Opera Software ASA"
HOMEPAGE="https://www.opera.com/"
LICENSE="OPERA-2014"

SLOT="$(get_version_component_range 1)"
PN_SLOTTED="${PN}${SLOT}"
SRC_URI_A=(
	"amd64? ("
		"https://get.geo.opera.com/pub/${PN}/desktop/${PV}/linux/${PN}-stable_${PV}_amd64.deb"
	")"
)

KEYWORDS="-* ~amd64"
IUSE_A=( autoupdate +ffmpeg-extra )

RDEPEND_A=(
	"dev-libs/expat"
	"dev-libs/glib:2"
	"dev-libs/nspr"
	"dev-libs/nss"
	"dev-libs/openssl:0"
	"gnome-base/gconf:2"
	"media-libs/alsa-lib"
	"media-libs/fontconfig"
	"media-libs/freetype"
	"net-misc/curl"
	"net-print/cups"
	"sys-apps/dbus"
	"sys-libs/libcap"
	"x11-libs/cairo"
	"x11-libs/gdk-pixbuf"
	"x11-libs/gtk+:2"
	"x11-libs/libX11"
	"x11-libs/libXScrnSaver"
	"x11-libs/libXcomposite"
	"x11-libs/libXcursor"
	"x11-libs/libXdamage"
	"x11-libs/libXext"
	"x11-libs/libXfixes"
	"x11-libs/libXi"
	"x11-libs/libXrandr"
	"x11-libs/libXrender"
	"x11-libs/libXtst"
	"x11-libs/libnotify"
	"x11-libs/pango[X]"
	# TODO: remember to update subslot
	"ffmpeg-extra? ( www-plugins/chromium-codecs-ffmpeg-extra:0/66 )"
)

inherit arrays

S="${WORKDIR}"

OPERA_HOME="/opt/${PN}/${PN_SLOTTED}"

src_unpack() {
	unpack_deb ${A}
}

src_prepare() {
	xdg_src_prepare

	emkdir "${OPERA_HOME#/}"

	# delete broken symlink, proper one will be created in src_install()
	erm "usr/bin/${PN}"

	## fix libdir
	emv -T "usr/lib/x86_64-linux-gnu/${PN}" "${OPERA_HOME#/}"
	# delete the rest
	erm -r "usr/lib"

	### BEGIN - /usr/share mods
	epushd "usr/share"

	# delete debian-specific files
	erm -r {lintian,menu}

	# unbundle licence
	erm "doc/opera-stable/copyright"
	# fix doc path
	emv "doc"/{opera-stable,${PF}}

	## fix icon paths
	local s
	for s in 16 32 48 128 256 ; do
		emv "icons/hicolor/${s}x${s}/apps"/{${PN},${PN_SLOTTED}}.png
	done
	emv "pixmaps"/{${PN},${PN_SLOTTED}}.xpm

	# fix mime package path
	emv "mime/packages"/{${PN}-stable,${PN_SLOTTED}}.xml

	local sedargs=(
		# delete invalid and "unity shell"-specific lines
		-e '/^TargetEnvironment=/d'
		# fix paths in *Exec lines
		-e "/Exec=${PN}/ s@${PN}( |$)@${EPREFIX}${OPERA_HOME}/${PN}\1@"
		# add slot to Name
		-e "s|^Name=${PN}.*|& ${SLOT}|I"
		-e "/^Icon=/ s|.*|Icon=${PN_SLOTTED}|"
	)
	esed -r "${sedargs[@]}" \
		-i -- "applications/${PN}.desktop"
	# fix menu entry path
	emv "applications"/{${PN},${PN_SLOTTED}}.desktop

	epopd
	### END - /usr/share mods

	# optionally delete autoupdater
	use autoupdate || erm "${OPERA_HOME#/}/opera_autoupdate"

	## locales
	epushd "${OPERA_HOME#/}/localization"
	chromium_remove_language_paks
	epopd
}

src_install() {
	insinto /
	doins -r *

	dosym "${OPERA_HOME}/${PN}" "/usr/bin/${PN_SLOTTED}"

	# fix permissions and pax-mark binaries
	fperms a+x "${OPERA_HOME}/${PN}"
	fperms 4711 "${OPERA_HOME}/opera_sandbox"
	use autoupdate && fperms a+x "${OPERA_HOME}/opera_autoupdate"
	pax-mark -m "${ED}/${OPERA_HOME}"/{opera,opera_sandbox}
}

QA_PREBUILT="*"
