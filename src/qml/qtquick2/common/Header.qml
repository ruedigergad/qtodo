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

import QtQuick 2.0

Rectangle {
    id: header
    height: headerText.height * 1.5
    color: primaryColorSchemeColor
    anchors{left: parent.left; right: parent.right; top: parent.top}
    z: 48

    property alias textColor: headerText.color

    Text {
        id: headerText
        anchors{left: parent.left; leftMargin: secondaryBorderSize; verticalCenter: parent.verticalCenter}
        text: "My To-Dos"
        color: primaryBackgroundColor
        font {pointSize: secondaryFontSize}
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
            ListElement {level: 0}
        }

        delegate: Rectangle {
            id: levelIndicatorDelegate

            property bool animationRunning: false
            visible: true

            height: header.height * 0.2
            width: height
            anchors.verticalCenter: parent.verticalCenter

            border.width: height * 0.2
            border.color: headerText.color
            color: ((level + 1) === levelIndicator.count || animationRunning ) ? headerText.color : "transparent"
        }

        Connections {
            target: mainRectangle.treeView
            onLevelIncrement: levelIndicator.model.append({level: levelIndicator.count})
            onLevelDecrement: levelIndicator.model.remove(levelIndicator.count - 1)
        }
    }
}
