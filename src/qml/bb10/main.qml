import QtQuick 1.1
import "../common"

Rectangle {
    anchors.fill: parent
    color: "lightgoldenrodyellow"

    Header {
        id: header
        height: 72
    }

    MainRectangle {
        anchors{left: parent.left; right: parent.right; top: header.bottom; bottom: parent.bottom}

        id: mainRectangle
    }
}


