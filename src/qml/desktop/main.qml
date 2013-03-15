import QtQuick 1.1
import "../common"

Rectangle {
    id: main

    anchors.fill: parent
    color: "white"

    MainRectangle {
        id: mainRectangle

        anchors {top: parent.top; left: parent.left; right: parent.right; bottom: toolBar.top}
    }

    QToDoToolBar {
        id: toolBar
    }
}
