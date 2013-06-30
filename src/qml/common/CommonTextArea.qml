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
    id: textArea

    height: textEdit.height + textEdit.font.pointSize

    border.width: primaryBorderSize / 8
    border.color: textEdit.focus ? "#00d000" : "#50e050"
//    radius: textEdit.font.pointSize * 0.75
    smooth: true

    property alias text: textEdit.text
    property int textFormat: TextEdit.PlainText

    signal enter()
    signal keyPressed(variant event)
    signal textChanged(string text)

    function forceActiveFocus() {
        textEdit.forceActiveFocus()
    }

    TextEdit {
        id: textEdit

        anchors.centerIn: parent
        width: parent.width - primaryBorderSize
        focus: parent.focus

        font.pointSize: primaryFontSize * 0.75
        color: "black"
        textFormat: textArea.textFormat
        wrapMode: TextEdit.WordWrap

        Keys.onPressed: {
            if (event.modifiers & Qt.AltModifier) {
                event.accepted = true
                keyPressed(event)
            }
        }

        Keys.onEnterPressed: {
            if (event.modifiers & Qt.ShiftModifier) {
                event.accepted = false
            } else {
                enter()
            }
        }
        Keys.onReturnPressed: {
            if (event.modifiers & Qt.ShiftModifier) {
                event.accepted = false
            } else {
                enter()
            }
        }

        onTextChanged: textArea.textChanged(text)

        onFocusChanged: {
            if (focus) {
                textEdit.openSoftwareInputPanel()
                textEdit.cursorPosition = textEdit.text.length
            } else {
                textEdit.closeSoftwareInputPanel()
            }
        }
    }
}
