# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/groff/groff-1.21.ebuild,v 1.8 2011/05/07 18:02:54 armin76 Exp $

EAPI="3"

inherit autotools eutils toolchain-funcs

DESCRIPTION="Text formatter used for man pages"
HOMEPAGE="http://www.gnu.org/software/groff/groff.html"
SRC_URI="mirror://gnu/groff/${P}.tar.gz
	linguas_ja? ( mirror://gentoo/${P}-japanese.patch.bz2 )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="examples X linguas_ja"

DEPEND=">=sys-apps/texinfo-4.7-r1
	X? (
		x11-libs/libX11
		x11-libs/libXt
		x11-libs/libXmu
		x11-libs/libXaw
		x11-libs/libSM
		x11-libs/libICE
	)"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.19.2-man-unicode-dashes.patch #16108 #17580 #121502

	# Make sure we can cross-compile this puppy
	if tc-is-cross-compiler ; then
		sed -i \
			-e '/^GROFFBIN=/s:=.*:=/usr/bin/groff:' \
			-e '/^TROFFBIN=/s:=.*:=/usr/bin/troff:' \
			-e '/^GROFF_BIN_PATH=/s:=.*:=:' \
			-e '/^GROFF_BIN_DIR=/s:=.*:=:' \
			contrib/*/Makefile.sub \
			doc/Makefile.in \
			doc/Makefile.sub || die "cross-compile sed failed"
	fi

	cat <<-EOF >> tmac/mdoc.local
	.ds volume-operating-system Gentoo
	.ds operating-system Gentoo/${KERNEL}
	.ds default-operating-system Gentoo/${KERNEL}
	EOF

	if use linguas_ja ; then
		epatch "${WORKDIR}"/${P}-japanese.patch #255292 #350534
		eautoconf
		eautoheader
	fi

	# call configure for subproject to fix cross compiling (#363647)
	sed -i -e 's:AC_OUTPUT:AC_CONFIG_SUBDIRS([src/libs/gnulib])\n&:' "${S}"/configure.ac
	#echo 'AC_CONFIG_SUBDIRS([src/libs/gnulib])' >> "${S}"/configure.ac
	eautoconf
	eautoheader
}

src_configure() {
	econf \
		--with-appresdir=/usr/share/X11/app-defaults \
		--docdir=/usr/share/doc/${PF} \
		$(use_with X x) \
		$(use linguas_ja && echo --enable-japanese)
}

src_install() {
	emake install DESTDIR="${D}" || die

	# The following links are required for man #123674
	dosym eqn /usr/bin/geqn
	dosym tbl /usr/bin/gtbl

	dodoc BUG-REPORT ChangeLog MORE.STUFF NEWS \
		PROBLEMS PROJECTS README REVISION TODO VERSION

	use examples || rm -rf "${D}"/usr/share/doc/${PF}/examples
}
