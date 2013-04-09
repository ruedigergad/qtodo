#!/bin/sh

QTODO_DIR=/opt/qtodo
export QML_IMPORT_PATH="${QTODO_DIR}/lib/imports"
export QMF_PLUGINS="${QTODO_DIR}/lib/qmf/plugins"
export LD_LIBRARY_PATH="${QTODO_DIR}/lib/qmf/lib"

lib/qmf/bin/messageserver &
bin/qtodo
# TODO: Should only kill pid of above messageserver process here.
killall messageserver
