#!/bin/sh

QTODO_DIR=/opt/qtodo
export QML_IMPORT_PATH="$QML_IMPORT_PATH:${QTODO_DIR}/lib/imports"

invoker --single-instance --splash ${QTODO_DIR}/splash.png --type=e ${QTODO_DIR}/bin/qtodo
