# Copyright 1999-2018 Gentoo Foundation
# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## ruby*.eclass:
USE_RUBY="ruby23 ruby24 ruby25"

inherit ruby-single

DESCRIPTION="XSL Stylesheets for Docbook"
HOMEPAGE="https://github.com/docbook/wiki/wiki"
LICENSE="BSD"

DOCBOOKDIR="/usr/share/sgml/${PN/-//}"
MY_PN="${PN%-stylesheets}"
MY_P="${MY_PN}-${PV}"

SLOT="0"
SRC_URI="https://github.com/docbook/xslt10-stylesheets/releases/download/release/${PV}/${MY_P}.tar.bz2"

KEYWORDS="amd64 arm arm64"
IUSE_A=(
	ruby
	slides params webhelp images fo
)

RDEPEND_A=(
	">=app-text/build-docbook-catalog-1.1"
	"ruby? ( ${RUBY_DEPS} )"
)

S="${WORKDIR}/${MY_P}"

# Makefile is broken since 1.76.0
RESTRICT=test

inherit arrays

src_prepare() {
	eapply_user

	# Delete the unnecessary Java-related stuff and other tools as they
	# bloat the stage3 tarballs massively. See bug #575818.
	erm -r extensions/ tools/
	find \( -name build.xml -o -name build.properties \) \
		 -printf "removed %p\n" -delete || die

	if ! use ruby ; then
	   erm -r epub/
	fi
}

# The makefile runs tests, not builds.
src_compile() { : ; }

src_test() {
	emake check
}

src_install() {
	# The changelog is now zipped, and copied as the RELEASE-NOTES, so we
	# don't need to install it
	dodoc AUTHORS BUGS NEWS README RELEASE-NOTES.txt TODO

	insinto ${DOCBOOKDIR}
	doins VERSION VERSION.xsl

	local i
	for i in */ ; do
		i=${i%/}

		cd "${S}"/${i}
		for doc in ChangeLog README; do
			if [[ -e "${doc}" ]]; then
				emv ${doc} ${doc}.${i}
				dodoc ${doc}.${i}
				erm ${doc}.${i}
			fi
		done

		doins -r "${S}"/${i}
	done

	if use ruby ; then
		local cmd="dbtoepubstylesheets"

		# we can't use a symlink or it'll look for the library in the
		# wrong path.
		dodir /usr/bin
		cat - > "${D}"/usr/bin/${cmd} <<EOF
#!/usr/bin/env ruby

load "${DOCBOOKDIR}/epub/bin/dbtoepub"
EOF
		fperms 0755 /usr/bin/${cmd}
	fi

	local u
	for u in slides params webhelp images fo ; do
		if ! use $u ; then
			NO_V=1 erm -r "${ED}"/usr/share/sgml/docbook/xsl-stylesheets/${u}
		fi
	done
}

pkg_postinst() {
	build-docbook-catalog
}

pkg_postrm() {
	build-docbook-catalog
}
