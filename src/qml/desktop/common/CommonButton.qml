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

import QtQuick 1.1

Rectangle {
    id: commonButton

    property alias text: textItem.text
    property alias font: textItem.font

    property string iconSource;

    signal clicked

    width: textItem.width + 40; height: textItem.height + 10
    border.width: 1
    radius: height/4
    smooth: true

    gradient: Gradient {
        GradientStop { id: topGrad; position: 0.0; color: "#9acfff" }
        GradientStop { id: bottomGrad; position: 1.0; color: "#79aeee" }
    }

    Text {
        id: textItem
        x: parent.width/2 - width/2; y: parent.height/2 - height/2
        font.pixelSize: 30
        color: "black"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: commonButton.clicked()
    }

    states: [
        State {
            name: "pressed"; when: mouseArea.pressed && mouseArea.containsMouse
            PropertyChanges { target: topGrad; color: "#569ffd" }
            PropertyChanges { target: bottomGrad; color: "#456aa2" }
            PropertyChanges { target: textItem; x: textItem.x + 1; y: textItem.y + 1; explicit: true }
        },
        State {
            name: "disabled"; when: !commonButton.enabled
            PropertyChanges { target: topGrad; color: "white" }
            PropertyChanges { target: bottomGrad; color: "lightgray" }
        }
    ]
}
