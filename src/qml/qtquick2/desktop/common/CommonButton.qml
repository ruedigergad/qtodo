/*
 *  Copyright 2012, 2013 Ruediger Gad
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
    id: commonButton

    property alias font: textItem.font
    property alias iconSource: iconImage.source;
    property bool selected: false
    property alias text: textItem.text

    signal clicked

    color: mouseArea.pressed ? primaryColorSchemeColor : (selected ? tertiaryColorSchemeColor : secondaryColorSchemeColor)
    enabled: iconImage.status === Image.Ready || text !== ""
    height: textItem.height + (textItem.font.pointSize / 2)
    smooth: true
    width: text === "" ? height : textItem.width + primaryBorderSize

    Text {
        id: textItem

        color: "black"
        font.pointSize: secondaryFontSize
        x: parent.width/2 - width/2; y: parent.height/2 - height/2
    }

    Image {
        id: iconImage

        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        height: parent.height * 0.8
        smooth: true
        width: height
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        onClicked: commonButton.clicked()
    }

    states: [
        State {
            name: "pressed"; when: mouseArea.pressed && mouseArea.containsMouse
            PropertyChanges { target: textItem; x: textItem.x + 1; y: textItem.y + 1; explicit: true }
        },
        State {
            name: "disabled"; when: !commonButton.enabled
            PropertyChanges { target: commonButton; opacity: disabledStateOpacity }
        }
    ]
}

