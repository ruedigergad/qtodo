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
import "../common"

Item {
    id: editToDoSheet
    anchors.bottom: parent.bottom
    anchors.top: parent.bottom
    width: parent.width

    visible: false
    z: 1

    property bool edit: false
    property int index: -1

    property alias text: textInput.text

    property string color: "blue"
    property string type: "to-do"

    signal closed()
    signal closing()
    signal opened()
    signal opening()
    signal accepted()

    function finished(){
        console.log("finished")
        if(state === "closed"){
            visible = false
            closed()
        }else{
            opened()
        }
    }

    function close(){
        inputFlickable.contentY = 0

        closing()
        state = "closed"
    }

    function open(){
        console.log("open")

        visible = true
        inputFlickable.contentY = 0

        opening()
        state = "open"

        textInput.focus = true
    }

    onStateChanged: {
        console.log("Edit entry dialog state changed: " + state)
    }

    states: [
        State {
            name: "open"
            AnchorChanges { target: editToDoSheet; anchors.top: parent.top }
        },
        State {
            name: "closed"
            AnchorChanges { target: editToDoSheet; anchors.top: parent.bottom }
        }
    ]

    transitions: Transition {
        SequentialAnimation {
            AnchorAnimation { duration: 250; easing.type: Easing.OutCubic }
            ScriptAction { script: editToDoSheet.finished() }
        }
    }

    Rectangle {
        id: buttonBar
        anchors.top: parent.top
        height: rejectButton.height + 6
        width: parent.width
        z: 4

        color: "lightgray"

        CommonButton{
            id: rejectButton
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            text: "Cancel"
            onClicked: editToDoSheet.close();
        }

        Text {id: entryLabel; text: "Entry"; font.pixelSize: 30; font.capitalization: Font.SmallCaps; font.bold: true; anchors.centerIn: parent}

        CommonButton{
            id: acceptButton
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            text: "OK"
            onClicked: {
                if(textInput.text === ""){
                    noTextGivenDialog.open()
                }else{
                    editToDoSheet.accepted()
                }
            }
        }
    }

    Rectangle {
        id: inputRectangle

        anchors {top: buttonBar.bottom; left: parent.left; right: parent.right; bottom: parent.bottom}
        color: "white"

        Flickable {
            id: inputFlickable

            anchors.fill: parent
            contentHeight: sheetContent.height

            Column {
                id: sheetContent
                spacing: 12

                anchors{top: parent.top; left: parent.left; right: parent.right; margins: 15}

                Row {
                    id: typeButtonRow
                    width: parent.width

                    CommonButton {
                        id: toDoButton
                        text: "To-Do"
                        onClicked: {
                            type = "to-do"
                            colorButtonRow.enabled = (type === "to-do")
                        }
                    }
                    CommonButton {
                        id: noteButton
                        text: "Note"
                        onClicked: {
                            type = "note"
                            colorButtonRow.enabled = (type === "to-do")
                        }
                    }
                }

                Row {
                    id: colorButtonRow
                    width: parent.width

                    CommonButton {
                        id: blueButton
                        iconSource: "../icons/to-do_blue.png"
                        onClicked: editToDoSheet.color = "blue"
                    }
                    CommonButton {
                        id: greenButton
                        iconSource: "../icons/to-do_green.png"
                        onClicked: editToDoSheet.color = "green"
                    }
                    CommonButton {
                        id: yellowButton
                        iconSource: "../icons/to-do_yellow.png"
                        onClicked: editToDoSheet.color = "yellow"
                    }
                    CommonButton {
                        id: redButton
                        iconSource: "../icons/to-do_red.png"
                        onClicked: editToDoSheet.color = "red"
                    }
                }

                CommonTextArea{
                    id: textInput
                    width: parent.width
                    textFormat: TextEdit.PlainText

                    Keys.onEscapePressed: editToDoSheet.close()
                    onEnter: accepted()
                }
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
}
