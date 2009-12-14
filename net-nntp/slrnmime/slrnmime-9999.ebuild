# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit mercurial distutils

EHG_REPO_URI="http://www.blacktrash.org/hg/slrnmime/"

DESCRIPTION="Enhancements for handling MIME with slrn"
HOMEPAGE="http://www.blacktrash.org/hg/slrnmime/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=net-nntp/slrn-0.9.9_p1[mime]"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"
src_unpack() {
	mercurial_src_unpack
	cd "${S}"
}

src_prepare() {
	distutils_src_prepare

	sed -i '/^sl\.slrnrc\.createslrnrc/ d' setup.py
	sed -i "/'sl'/ d" setup.py
	sed -i 's@\(slanglib =\) slangpath()@\1 '"'${D}/usr/share/${PN}/'"'@' sl/slrnrc.py
}

src_compile() {
	distutils_src_compile
}

src_install() {
	distutils_src_install

	# generate slrn configuration
	dodir /usr/share/${PN}
	PYTHONPATH="." "${python}" slrnconf.py
	sed -i "s@${D}@@" "${D}"/usr/share/${PN}/mime.slrnrc

	insinto /usr/share/${PN}
	doins sl/*.sl


	dodoc slrnconf.py
	insinto /usr/share/doc/${PF}/examples
	doins *.slrnrc
	newins example-plainmsgrc plainmsgrc
}

pkg_postinst() {
	einfo "Put the following into your .slrnrc to make use of this module:"
	einfo "  include /usr/share/${PN}/mime.slrnrc"
}
