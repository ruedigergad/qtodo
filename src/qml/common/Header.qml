/*
 *  Copyright 2013 Ruediger Gad
 *
 *  This file is part of Q To-Do.
 *
 *  Q To-Do is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Q To-Do is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Q To-Do.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 1.1

Rectangle {
    id: header
    height: 40
    color: "#00b000" //#0c61a8"
    anchors{left: parent.left; right: parent.right; top: parent.top}
    z: 48

    Text {
        id: headerText
        anchors{left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter}
        text: "My To-Dos"
        color: "#ffffff"
        font {pixelSize: header.height * 0.444; family: "Nokia Pure Text Light"}
    }

    ListView {
        id: levelIndicator
        anchors {
            left: headerText.right
            leftMargin:  header.height * 0.5
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        orientation: ListView.Horizontal
        spacing: header.height * 0.25

        model: ListModel {
            ListElement {}
        }

        delegate: Rectangle {
            id: levelIndicatorDelegate
            height: header.height * 0.18
            width: height
            anchors.verticalCenter: parent.verticalCenter

            radius: height * 0.5
            border.width: height * 0.2
            border.color: "white"
            color: ((index + 1) === levelIndicator.count || opacity < 1) ? "white" : header.color

            ListView.onAdd: SequentialAnimation {
                PropertyAction { target: levelIndicatorDelegate; property: "opacity"; value: 0 }
                NumberAnimation { target: levelIndicatorDelegate; property: "opacity"; to: opacity; duration: 250; easing.type: Easing.InOutQuad }
            }

            ListView.onRemove: SequentialAnimation {
                PropertyAction { target: levelIndicatorDelegate; property: "ListView.delayRemove"; value: true }
                NumberAnimation { target: levelIndicatorDelegate; property: "opacity"; to: 0; duration: 250; easing.type: Easing.InOutQuad }
                PropertyAction { target: levelIndicatorDelegate; property: "ListView.delayRemove"; value: false }
            }
        }

        Connections {
            target: mainRectangle.treeView
            onLevelIncrement: levelIndicator.model.append({})
            onLevelDecrement: levelIndicator.model.remove(levelIndicator.count - 1)
        }
    }
}
