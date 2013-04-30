#!/bin/sh

find . -name .svn -exec rm -rf {} \;
mv qtc_packaging/debian_harmattan debian
mv debian/sb_rules debian/rules
rm -rf qtc_packaging/

mv lib/build .
rm -rf lib
mkdir lib
mv build lib

fakeroot dpkg-buildpackage -sa
