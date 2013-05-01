#/bin/sh

find qml/ -exec sed -i 's/\.\.\/icons/qrc:/g' {} \;
tar czf ../windows_source.tar.gz ../src
git reset --hard


