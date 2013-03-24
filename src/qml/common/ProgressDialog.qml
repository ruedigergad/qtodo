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

CommonDialog {
    property double maxValue
    property double currentValue

    property alias title: titleText.text
    property alias message: message.text

    Item {
      anchors.fill: parent
        Text {
            id: titleText
            anchors.bottom: progressIndicatorBackground.top
            anchors.margins: 20
            width: parent.width
            color: "white"
            font.pointSize: 40
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        Rectangle {
            id: progressIndicatorBackground
            anchors.centerIn: parent

            width: parent.width * 0.8
            height: 80

            color: "white"

            Rectangle {
                id: progressIndicator

                color: "steelblue"

                anchors {left: parent.left; top: parent.top; bottom: parent.bottom}
                width: parent.width * (currentValue === 0 ? 0 : (currentValue/maxValue))
            }
        }

        Text {
            id:message

            anchors.top: progressIndicatorBackground.bottom
            anchors.margins: 20

            width: parent.width
            color: "white"
            font.pointSize: 25
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }
    }
}
