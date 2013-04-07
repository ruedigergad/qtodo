#!/bin/sh

export QML_IMPORT_PATH=lib/imports
export QMF_PLUGINS=lib/qmf/plugins
export LD_LIBRARY_PATH=lib/qmf/lib

lib/qmf/bin/messageserver &
bin/qtodo
# TODO: Should only kill pid of above messageserver process here.
killall messageserver

