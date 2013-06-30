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
    height: headerText.height * 1.5
    color: "#00b000" //#0c61a8"
    anchors{left: parent.left; right: parent.right; top: parent.top}
    z: 48

    property alias textColor: headerText.color

    Text {
        id: headerText
        anchors{left: parent.left; leftMargin: primaryFontSize * 0.75; verticalCenter: parent.verticalCenter}
        text: "My To-Dos"
        color: "white"
        font {pointSize: primaryFontSize * 0.7}
    }

    ListView {
        id: levelIndicator
        anchors {
            left: headerText.right
            leftMargin:  header.height * 0.5
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        height: header.height

        orientation: ListView.Horizontal
        interactive: false
        spacing: header.height * 0.25

        model: ListModel {
            ListElement {}
        }

        delegate: Rectangle {
            id: levelIndicatorDelegate

            property bool animationRunning: false
            // Hack to avoid item blinking up at target position at first.
            visible: false

            height: header.height * 0.2
            width: height
            anchors.verticalCenter: parent.verticalCenter

//            radius: height * 0.5
            border.width: height * 0.2
            border.color: headerText.color
            color: ((index + 1) === levelIndicator.count || animationRunning ) ? headerText.color : "transparent"

            ListView.onAdd: SequentialAnimation {
                PropertyAction { target: levelIndicatorDelegate; property: "animationRunning"; value: true }
                // Hack to avoid item blinking up at target position at first.
                // Setting x via PropertyAction causes the item to shortly show up at the target position.
                NumberAnimation { target: levelIndicatorDelegate; property: "x"; to: header.width + width; duration: 1; easing.type: Easing.InOutQuad }
                PropertyAction { target: levelIndicatorDelegate; property: "visible"; value: true }
                NumberAnimation { target: levelIndicatorDelegate; property: "x"; to: x; duration: 250; easing.type: Easing.InOutQuad }
                PropertyAction { target: levelIndicatorDelegate; property: "animationRunning"; value: false }
            }

            ListView.onRemove: SequentialAnimation {
                PropertyAction { target: levelIndicatorDelegate; property: "animationRunning"; value: true }
                PropertyAction { target: levelIndicatorDelegate; property: "ListView.delayRemove"; value: true }
                NumberAnimation { target: levelIndicatorDelegate; property: "x"; to: header.width + width; duration: 250; easing.type: Easing.InOutQuad }
                PropertyAction { target: levelIndicatorDelegate; property: "ListView.delayRemove"; value: false }
                PropertyAction { target: levelIndicatorDelegate; property: "animationRunning"; value: false }
            }

            // Hack to avoid item blinking up at target position at first.
            // We explicitly set the first item to visible as it is never animated
            // and hence would not be set to visible otherwise.
            Component.onCompleted: {
                if (index === 0) {
                    visible = true
                }
            }
        }

        Connections {
            target: mainRectangle.treeView
            onLevelIncrement: levelIndicator.model.append({})
            onLevelDecrement: levelIndicator.model.remove(levelIndicator.count - 1)
        }
    }
}
