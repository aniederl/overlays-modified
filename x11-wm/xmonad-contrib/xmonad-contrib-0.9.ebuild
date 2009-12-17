# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-wm/xmonad-contrib/xmonad-contrib-0.7.ebuild,v 1.1 2008/04/11 15:29:23 kolmodin Exp $

CABAL_FEATURES="lib profile haddock"

inherit haskell-cabal

DESCRIPTION="Third party extentions for xmonad"
HOMEPAGE="http://www.xmonad.org/"
SRC_URI="http://hackage.haskell.org/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~sparc ~x86"
IUSE="unicode xft"

RDEPEND=">=dev-lang/ghc-6.6.1
	dev-haskell/mtl
	>=dev-haskell/x11-1.4.3
	unicode? ( dev-haskell/utf8-string )
	xft? (  dev-haskell/utf8-string
			dev-haskell/x11-xft )
	doc? ( >=dev-haskell/haddock-2.4.1 )
	~x11-wm/xmonad-${PV}"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.2.1"


use_flags() {
	if [ -z "${2}" ] ; then
		echo "!!! use_flags() called without parameters." >&2
		echo "!!! use_flags() <USEFLAG> <flagname>" >&2
		return 1
	fi

	if useq "${1}" ; then
		echo "--flags=${2}"
	else
		echo "--flags=-${2}"
	fi
	return 0
}

pkg_setup() {
	if use xft && ! use unicode ; then
		eerror "Xft support requires unicode support."
		eerror "Please emerge with USE=\"unicode\""
	fi
}

src_compile() {
	CABAL_CONFIGURE_FLAGS="$(use_flags xft use_xft) $(use_flags unicode with_utf8)"
	cabal_src_compile
}
