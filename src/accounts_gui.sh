#!/bin/sh

QTODO_DIR=/opt/qtodo
export QML_IMPORT_PATH="${QTODO_DIR}/lib/imports"
export QMF_PLUGINS="${QTODO_DIR}/lib/qmf/plugins"
export LD_LIBRARY_PATH="${QTODO_DIR}/lib/qmf/lib"

RUN_MESSAGESERVER=$(ps -el | grep messageserver &> /dev/null ; echo $?)
if [ $RUN_MESSAGESERVER -eq 1 ] ;
then
    echo "Starting messageserver..."
    eval "${QTODO_DIR}/lib/qmf/bin/messageserver &" ;
    MESSAGESERVER_PID=$!
fi

${QTODO_DIR}/lib/qmf/bin/messagingaccounts

if [ $RUN_MESSAGESERVER -eq 1 ];
then
    kill $MESSAGESERVER_PID
fi
