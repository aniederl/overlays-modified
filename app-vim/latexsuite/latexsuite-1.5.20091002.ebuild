# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit vim-plugin versionator

DESCRIPTION="vim plugin: a comprehensive set of tools to view, edit and compile LaTeX documents"
HOMEPAGE="http://vim-latex.sourceforge.net/"

LICENSE="vim"
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

MY_REV="1074"
MY_PN="vim-latex"
MY_P="${MY_PN}-$( replace_version_separator 2 - )-r${MY_REV}"
S="${WORKDIR}/${MY_P}"
SRC_URI="mirror://sourceforge/${MY_PN}/${MY_P}.tar.gz"

RDEPEND="virtual/latex-base"

VIM_PLUGIN_HELPFILES="latex-suite.txt latex-suite-quickstart.txt latexhelp.txt imaps.txt"

src_prepare() {
	# The makefiles do weird stuff, including running the svn command
	rm Makefile Makefile.in || die "rm Makefile Makefile.in failed"
}

src_install() {
	dohtml -r doc/

	# don't mess up vim's doc dir with random files
	mv doc mydoc || die
	mkdir doc || die
	mv mydoc/*.txt doc/ || die
	rm -rf mydoc || die

	into /usr
	dobin latextags ltags
	rm latextags ltags
	vim-plugin_src_install
}

pkg_postinst() {
	vim-plugin_pkg_postinst
	elog
	elog "To use the latexSuite plugin add:"
	elog "   filetype plugin on"
	elog '   set grepprg=grep\ -nH\ $*'
	elog "   let g:tex_flavor='latex'"
	elog "to your ~/.vimrc-file"
	elog
}
