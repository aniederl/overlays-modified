# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/wirble/wirble-0.1.3-r1.ebuild,v 1.4 2011/03/27 19:04:40 ranger Exp $

EAPI="3"
USE_RUBY="ruby18 ruby19"

inherit ruby-ng

DESCRIPTION="Wirble is a set of enhancements for Irb."
HOMEPAGE="http://pablotron.org/software/wirble/"
SRC_URI="http://pablotron.org/files/${P}.tar.gz"
RESTRICT="mirror"

LICENSE="Ruby"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE=""

each_ruby_configure() {
	"${RUBY}" ./setup.rb config || die "./setup.rb config failed"
	"${RUBY}" ./setup.rb setup  || die "./setup.rb setup failed"
}

each_ruby_install() {
	"${RUBY}" ./setup.rb install --prefix="${D}" || die "./setup.rb install failed"
}

pkg_postinst() {
	elog "The quick way to use wirble is to make your ~/.irbrc look like this:"
	elog "  # load libraries"
	elog "  require 'wirble'"
	elog "  "
	elog "  # start wirble (with color)"
	elog "  Wirble.init"
	elog "  Wirble.colorize"
}
