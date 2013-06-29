/*
 *  Copyright 2011 Ruediger Gad
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
import com.nokia.meego 1.0

Sheet{
    id: editToDoSheet
    anchors.fill: parent
    visualParent: mainPage

    property alias text: textInput.text

    property string color: "blue"
    property string type: "to-do"

    property bool edit: false

    onStatusChanged: {
        if (status === DialogStatus.Opening){
            commonTools.enabled = false

            toDoButton.checked = (type === "to-do")
            noteButton.checked = (type === "note")
            typeButtonRow.enabled = !(edit && type === "to-do")

            colorButtonRow.enabled = (type === "to-do")

            if(type === "note")
                color = "blue"
            blueButton.checked = (color === "blue")
            greenButton.checked = (color === "green")
            yellowButton.checked = (color === "yellow")
            redButton.checked = (color === "red")
        }else if (status === DialogStatus.Closed){
            commonTools.enabled = true
        }
    }

    Dialog{
        id: noTextGivenDialog
        anchors.fill: parent

        content: Text {
            anchors.centerIn: parent
            width: parent.width
            text: "Please enter a text."
            font.pointSize: 30
            color: "white"
            horizontalAlignment: Text.AlignHCenter; wrapMode: Text.Wrap
        }

        onRejected: {
            textInput.focus = true
        }
    }

    buttons: Item {
        anchors.fill: parent
        SheetButton{
            id: rejectButton
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            text: "Cancel"
            onClicked: editToDoSheet.reject();
        }

        SheetButton{
            id: acceptButton
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            platformStyle: SheetButtonAccentStyle { }
            text: "OK"
            onClicked: {
                if(textInput.text === ""){
                    noTextGivenDialog.open()
                }else{
                    editToDoSheet.accept()
                }
            }
        }
    }

    content: Flickable {
        anchors.fill: parent
        contentHeight: sheetContent.height

        Column {
            id: sheetContent
            spacing: 12

            anchors{top: parent.top; left: parent.left; right: parent.right; margins: 15}

            ButtonRow {
                id: typeButtonRow
                width: parent.width

                Button {
                    id: toDoButton
                    text: "To-Do"
                    onClicked: {
                        type = "to-do"
                        colorButtonRow.enabled = (type === "to-do")
                    }
                }
                Button {
                    id: noteButton
                    text: "Note"
                    onClicked: {
                        type = "note"
                        colorButtonRow.enabled = (type === "to-do")
                    }
                }
            }

            ButtonRow {
                id: colorButtonRow
                width: parent.width

                Button {
                    id: blueButton
                    iconSource: "../icons/to-do_blue.png"
                    onClicked: color = "blue"
                }
                Button {
                    id: greenButton
                    iconSource: "../icons/to-do_green.png"
                    onClicked: color = "green"
                }
                Button {
                    id: yellowButton
                    iconSource: "../icons/to-do_yellow.png"
                    onClicked: color = "yellow"
                }
                Button {
                    id: redButton
                    iconSource: "../icons/to-do_red.png"
                    onClicked: color = "red"
                }
            }

            TextArea{
                id: textInput
                width: parent.width
                textFormat: TextEdit.PlainText
                placeholderText: "Enter Text"
            }
        }
    }

    onAccepted: {
        if(edit){
            mainRectangle.treeView.currentModel.updateElement(mainRectangle.treeView.currentIndex, type, text, color)
        }else{
            mainRectangle.treeView.currentModel.addElement(type, text, color)
        }

        editToDoSheet.close();
    }

    onRejected: editToDoSheet.close();
}

