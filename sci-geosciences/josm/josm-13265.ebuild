# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## java-utils-2.eclass:
## java-pkg-2.eclass
EANT_GENTOO_CLASSPATH="
	commons-logging
	commons-compress
	commons-codec
	error-prone-annotations
	jmapviewer
	gettext-commons
	gettext-ant-tasks
	svgsalamander
	signpost
	ant-contrib
"
## java-ant-2.eclass:
JAVA_ANT_ENCODING=UTF-8

## EXPORT_FUNCTIONS: pkg_setup src_prepare src_compile pkg_preinst
inherit java-pkg-2
## EXPORT_FUNCTIONS: src_configure
inherit java-ant-2
## EXPORT_FUNCTIONS: src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg
## functions: make_desktop_entry, doicon, newicon
inherit desktop

DESCRIPTION="Java-based editor for the OpenStreetMap project"
HOMEPAGE="https://josm.openstreetmap.de/"
LICENSE="GPL-2"

SLOT="0"
MY_P="${PN}_0.0.svn${PV}"
# Upstream doesn't provide versioned tarballs
SRC_URI_A=(
	## josm 0.0.svn13170+dfsg-2~bpo9+1
	"http://snapshot.debian.org/archive/debian/20180101T053014Z/pool/main/j/josm/josm_0.0.svn13265%2Bdfsg.orig.tar.gz"
	"http://snapshot.debian.org/archive/debian/20180101T053014Z/pool/main/j/josm/josm_0.0.svn13265%2Bdfsg-1.debian.tar.xz"
)

KEYWORDS="~amd64"

CDEPEND_A=(
	"dev-java/commons-compress:0"
	"dev-java/commons-logging:0"
	"dev-java/error-prone-annotations:0"
	"dev-java/jmapviewer:0"
	"dev-java/gettext-commons:0"
	"dev-java/gettext-ant-tasks:0"
	"dev-java/svgsalamander:0"
	"dev-java/signpost:0"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jdk-1.8"
	"dev-java/javacc:0"
	"dev-java/ant-contrib:0"
	"app-text/xmlstarlet" # required for build files patching
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jre-1.8"
	"media-fonts/noto"
)

RESTRICT+=" mirror"

inherit arrays

S="${WORKDIR}/${MY_P//_/-}"
DEBIAN_DIR="${WORKDIR}/debian"

L10N_LOCALES=(
	af am ar ast az be bg bn br bs ca ca@valencia cs cy da de de_DE el en_AU en_CA en_GB eo es et
	eu fa fi fil fo fr ga gl he hi hr ht hu hy ia id is it ja ka km ko ku ky lb lo lt lv mk mr ms
	nb nds nl nn oc pa pl pt pt_BR rm ro ru sk sl sq sr sv ta te th tr ug uk ur vi wae zh_CN zh_TW
)
inherit l10n-r1

src_prepare-locales() {
	local l locales dir="i18n/po" pre="" post=".po"

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	l10n_get_locales locales app off
	for l in ${locales} ; do
		erm "${dir}/${pre}${l}${post}"
		sed -e "/languages\.put.*\"${l}\"/d" \
			-i -- src/org/openstreetmap/josm/tools/{I18n,LanguageInfo}.java || die
	done
}

src_prepare() {
	eapply "${DEBIAN_DIR}/patches"/00-build.patch
	eapply "${DEBIAN_DIR}/patches"/04-use_system_jmapviewer.patch
	eapply "${DEBIAN_DIR}/patches"/05-fix_version.patch
	eapply "${DEBIAN_DIR}/patches"/06-move_data_out_of_jar.patch
	eapply "${DEBIAN_DIR}/patches"/07-use_system_fonts.patch
	eapply "${DEBIAN_DIR}/patches"/08-use_noto_font.patch

	xdg_src_prepare

	src_prepare-locales

	## fix debian paths
	local xmlstarlet=(
		xmlstarlet ed --inplace
		-d "project/target[@name='init-properties']/path[@id='classpath']/fileset"
		build.xml
	)
	echo "${xmlstarlet[@]}"
	"${xmlstarlet[@]}" || die
	local p f
	for p in ${EANT_GENTOO_CLASSPATH} ; do
		for f in $(java-pkg_getjars "${p}" | tr ':' ' ') ; do
			local base_xpath="project/target[@name='init-properties']/path[@id='classpath']"
			local xmlstarlet=(
				xmlstarlet ed --inplace
				-s "${base_xpath}" -t elem -n "pathelement"
				-i "${base_xpath}/pathelement[last()]" -t attr -n location -v "${f}"
				build.xml
			)
			echo "${xmlstarlet[@]}"
			"${xmlstarlet[@]}" || die
		done
	done
	sed -e "s,/usr/share/java/ant-contrib.jar,$(java-pkg_getjars --build-only ant-contrib),g" \
		-i -- build.xml i18n/build.xml || die
	sed -e "s,/usr/share/java/gettext-ant-tasks.jar,$(java-pkg_getjars --build-only gettext-ant-tasks),g" \
		-i -- build.xml i18n/build.xml || die

	## print stats for EPSG compilation
	sed -e "s|printStats *= *false|printStats = true|" \
		-i -- scripts/BuildProjectionDefinitions.java || die

	## fix font path
	sed -e 's,/usr/share/fonts/truetype/noto,/usr/share/fonts/noto,g' \
		-i -- src/org/openstreetmap/josm/tools/FontsManager.java || die

	## change default look and feel to GTK
	sed -e 's|"javax.swing.plaf.metal.MetalLookAndFeel"|"com.sun.java.swing.plaf.gtk.GTKLookAndFeel"|' \
		-i -- src/org/openstreetmap/josm/tools/PlatformHookUnixoid.java || die

	## normalize user-agent
	sed -r -e 's|(String *result *= *"JOSM/1.5 \(").*|\1 + v + ")";|' \
		-i -- src/org/openstreetmap/josm/data/Version.java || die
	sed -e '/Main.platform.getOSDescription/d' -i -- src/org/openstreetmap/josm/data/Version.java || die
	sed -r -e 's|(getAgentString\(\)) *\+.*|\1;|' -i -- src/org/openstreetmap/josm/data/Version.java || die

	## do not display MOTD by default, as it requires calling home
	sed -e 's|getBoolean("help.displaymotd", true)|getBoolean("help.displaymotd", false)|' \
		-i -- src/org/openstreetmap/josm/gui/GettingStarted.java || die

	## fix `TMSCachedTileLoader.java:129: error: method does not override or implement a method from a supertype`
	## https://stackoverflow.com/a/7378912/2566213
	gawk -i inplace '
			!/hasOutstandingTasks/ {
				if (m)
					print buf
				buf=$0
				m=1
			}
			/hasOutstandingTasks/ {
				m=0
				print "//",buf
				print
			}
			ENDFILE {
				print buf
			}
		' \
		src/org/openstreetmap/josm/data/imagery/TMSCachedTileLoader.java || die

	# update `REVISION` entry
	xmlstarlet ed --inplace -u "project/target[@name='create-revision']/echo[@file='\${revision.dir}/REVISION']" \
		-v "$(cat <<-_EOF_
			# automatically generated by JOSM build.xml - do not edit
			Revision: \${version.entry.commit.revision}
			Is-Local-Build: true
			Build-Date: \${build.tstamp}
			Build-Name: rindeal-ebuild
			Ebuild-Version: ${PVR}
			_EOF_
		)" build.xml || die

	java-pkg-2_src_prepare

	java-ant_rewrite-classpath
	java-ant_rewrite-classpath i18n/build.xml
}

src_compile() {
	EANT_GENTOO_CLASSPATH_EXTRA="${S}/src"
	# `dist-optimized` requires non-free obfuscator
	EANT_BUILD_TARGET="dist"
	# removes dependency on OpenJFX/Oracle JFX, but audio player will cease to work
	EANT_EXTRA_ARGS="-DnoJavaFX=true"

	java-pkg-2_src_compile
}

src_install() {
	### Main
	java-pkg_newjar "dist/${PN}-custom.jar" "${PN}.jar"

	java-pkg_dolauncher "${PN}" --jar "${PN}.jar" --java_args "-Dawt.useSystemAAFontSettings=lcd"

	### Data
	insinto /usr/share/${PN}
	doins -r images styles data

	### Icons
	newicon "images/logo.png" "${PN}.png"
	doicon -s scalable "linux/tested/usr/share/icons/hicolor/scalable/apps/${PN}.svg"
	local s
	# unsupported sizes: 8 40 42 80
	for s in 16 22 24 32 36 48 64 72 96 128 192 256 512 ; do
		doicon -s ${s} "linux/tested/usr/share/icons/hicolor/${s}x${s}/apps/${PN}.png"
	done

	### Docs
	doman "linux/tested/usr/share/man/man1/${PN}.1"
	einstalldocs

	### Misc
	insinto /usr/share/appdata
	doins "linux/tested/usr/share/metainfo/${PN}.appdata.xml"

	local make_desktop_entry_args=(
		"${EPREFIX}/usr/bin/${PN} %F"	# exec
		"${PN^^}"	# name
		"${PN}"	# icon
		"Education;Science;Geoscience;Maps" # categories; https://standards.freedesktop.org/menu-spec/latest/apa.html
	)
	local make_desktop_entry_extras=(
		"StartupWMClass=org-openstreetmap-josm-Main"
		"MimeType=application/x-osm+xml;application/x-gpx+xml;x-scheme-handler/geo;"
		"GenericName=Java OpenStreetMap Editor"
	)
	make_desktop_entry "${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"
}
