# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/nodejs/nodejs-0.7.8.ebuild,v 1.3 2012/05/30 03:57:23 patrick Exp $

EAPI=3

PYTHON_DEPEND="2"

inherit python eutils pax-utils

# omgwtf
RESTRICT="test"

DESCRIPTION="Evented IO for V8 Javascript"
HOMEPAGE="http://nodejs.org/"
SRC_URI="http://nodejs.org/dist/v${PV}/node-v${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x64-macos"
IUSE="-shared-v8"

DEPEND="dev-libs/openssl
	shared-v8? ( >=dev-lang/v8-3.9.24.7 <dev-lang/v8-3.10 )"
RDEPEND="${DEPEND}"

S=${WORKDIR}/node-v${PV}

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

src_prepare() {
	# fix compilation on Darwin
	# http://code.google.com/p/gyp/issues/detail?id=260
	sed -i -e "/append('-arch/d" tools/gyp/pylib/gyp/xcode_emulation.py || die
}

src_configure() {
	# this is an autotools lookalike confuserator
	local myconf=" \
		--prefix=${EPREFIX}/usr \
		--openssl-use-sys \
		--shared-zlib"

	use shared-v8 && myconf="${myconf} \
		--shared-v8 \
		--shared-v8-includes=${EPREFIX}/usr/include"

	./configure ${myconf} || die
}

src_compile() {
	emake || die
}

src_install() {
	# there are no words to describe the epic idiocy of ...
	# NOT using make but a JavaScript thingy to try to install things ... to the wrong place
	# WHY U NO MAEK SENSE?!
	#emake DESTDIR="${D}" install || die

	mkdir -p "${ED}"/usr/include/node
	mkdir -p "${ED}"/usr/include/node/uv-private
	mkdir -p "${ED}"/usr/bin
	mkdir -p "${ED}"/lib/node_modules/npm
	cp 'src/node.h' 'src/node_buffer.h' 'src/node_object_wrap.h' 'src/node_version.h' "${ED}"/usr/include/node || die "Failed to copy stuff"
	cp 'deps/uv/include/uv.h' 'deps/uv/include/ares.h' 'deps/uv/include/ares_version.h' "${ED}"/usr/include/node || die "Failed to copy stuff"
	cp 'deps/uv/include/uv-private/eio.h' \
		'deps/uv/include/uv-private/ev.h' \
		'deps/uv/include/uv-private/ngx-queue.h' \
		'deps/uv/include/uv-private/tree.h' \
		'deps/uv/include/uv-private/uv-unix.h' \
		'deps/uv/include/uv-private/uv-win.h' \
		"${ED}"/usr/include/node || die "Failed to copy stuff"

	if use shared-v8 ; then
		cp 'deps/v8/include/v8-debug.h' \
			'deps/v8/include/v8-preparser.h' \
			'deps/v8/include/v8-profiler.h' \
			'deps/v8/include/v8-testing.h' \
			'deps/v8/include/v8.h' \
			'deps/v8/include/v8stdint.h' \
		"${ED}"/usr/include/node || die "Failed to copy stuff"
	fi

	cp 'out/Release/node' "${ED}"/usr/bin/node || die "Failed to copy stuff"
	cp -R deps/npm/* "${ED}"/lib/node_modules/npm || die "Failed to copy stuff"

	# now add some extra stupid just because we can
	# needs to be a symlink because of hardcoded paths ... no es bueno!
	dosym /lib/node_modules/npm/bin/npm-cli.js /bin/npm
	pax-mark -m "${ED}"/usr/bin/node

	# install node-waf
	local pylibdir="$(python_get_libdir)"
	local pynodedir="${ED}/${pylibdir}/node"
	local pywafdir="${pynodedir}/wafadmin"

	mkdir -p "${pynodedir}"
	cp -R tools/wafadmin "${pywafdir}"

	cat > "${ED}"/usr/bin/node-waf << __EOF__
#!/usr/bin/python

import os

# Scripting module needs 'hardcoded' paths ...
wafdir = '${EPREFIX}/${pylibdir}/node'
t = '${EPREFIX}/${pylibdir}/node/wafadmin/Tools'

import Scripting
VERSION="1.5.16"
Scripting.prepare(t, os.getcwd(), VERSION, wafdir)
sys.exit(0)
__EOF__
	chmod 755 "${ED}"/usr/bin/node-waf
}

src_test() {
	emake test || die
}
