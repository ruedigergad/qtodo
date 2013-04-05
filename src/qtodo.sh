#!/bin/sh

export QML_IMPORT_PATH=lib/imports:$QML_IMPORT_PATH
export QMF_PLUGINS=lib/qmf:$QMF_PLUGINS
export LD_LIBRARY_PATH=lib/qmf/lib:$LD_LIBRARY_PATH

lib/qmf/bin/messageserver &
bin/qtodo
# TODO: Should only kill pid of above messageserver process here.
killall messageserver

