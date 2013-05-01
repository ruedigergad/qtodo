#/bin/sh

find qml/ -exec sed -i 's/\.\.\/icons/qrc:\/icons/g' {} \;
find qml/ -exec sed -i '/^import.*common.*/d' {} \;
tar czf ../windows_source.tar.gz ../src
git reset --hard


