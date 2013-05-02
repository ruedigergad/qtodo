#!/bin/sh

QTODO_DIR=/opt/qtodo
export QML_IMPORT_PATH="${QTODO_DIR}/lib/imports"
export QMF_PLUGINS="${QTODO_DIR}/lib/qmf/plugins"
export LD_LIBRARY_PATH="${QTODO_DIR}/lib:${QTODO_DIR}/lib/qmf/lib"

#eval "${QTODO_DIR}/lib/qmf/bin/messageserver &"
#MESSAGESERVER_PID=$!
${QTODO_DIR}/bin/qtodo
#kill $MESSAGESERVER_PID
