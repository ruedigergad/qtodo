#!/bin/sh

find . -name .svn -exec rm -rf {} \;
mv qtc_packaging/debian_harmattan debian
mv debian/sb_rules debian/rules
rm -rf qtc_packaging/
fakeroot dpkg-buildpackage -sa
