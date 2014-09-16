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

Item {
    id: editToDoSheet
    anchors.bottom: parent.bottom
    anchors.top: parent.bottom
    width: parent.width

    visible: false
    z: 1

    property alias acceptText: acceptButton.text
    property alias cancelText: rejectButton.text
    property string color: "blue"
    property bool edit: false
    property int index: -1
    property alias text: textInput.text
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
            textInput.focus = true
        }
    }

    function close(){
        inputFlickable.contentY = 0

        closing()
        state = "closed"
    }

    function save() {
        if(edit){
            mainRectangle.treeView.currentNodeListView.model.updateElement(mainRectangle.treeView.currentIndex, type, text, color)
        }else{
            mainRectangle.treeView.currentNodeListView.model.addElement(type, text, color)
        }
    }

    function open(){
        console.log("open")

        visible = true
        inputFlickable.contentY = 0

        opening()
        state = "open"
    }

    onAccepted: {
        save()
        editToDoSheet.close()
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

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: focus = true
    }

    Rectangle {
        id: buttonBar
        anchors.top: parent.top
        height: rejectButton.height + 6
        width: parent.width
        z: 4

        color: secondaryBackgroundColor
        opacity: secondaryBackgroundOpacity

        CommonButton{
            id: rejectButton

            anchors.left: parent.left
            anchors.leftMargin: secondaryBorderSize
            anchors.verticalCenter: parent.verticalCenter
            text: "Cancel"

            onClicked: editToDoSheet.close();
        }

        Text {
            id: entryLabel

            anchors.centerIn: parent
            color: primaryFontColor
            font { pointSize: primaryFontSize; capitalization: Font.SmallCaps; bold: true }
            text: "Entry"
        }

        CommonButton {
            id: acceptButton

            anchors.right: parent.right
            anchors.rightMargin: secondaryBorderSize
            anchors.verticalCenter: parent.verticalCenter
            text: "OK"
            width: rejectButton.width

            onClicked: {
                editToDoSheet.focus = true
                if(textInput.text === "") {
                    noTextGivenDialog.open()
                } else {
                    editToDoSheet.accepted()
                }
            }
        }
    }

    Rectangle {
        id: inputRectangle

        anchors {top: buttonBar.bottom; left: parent.left; right: parent.right; bottom: parent.bottom}
        color: primaryBackgroundColor
        opacity: primaryBackgroundOpacity

        Flickable {
            id: inputFlickable

            anchors.fill: parent
            clip: true
            contentHeight: sheetContent.height

            Column {
                id: sheetContent
                spacing: secondaryBorderSize

                anchors{top: parent.top; left: parent.left; right: parent.right; margins: secondaryBorderSize}

                Row {
                    id: typeButtonRow

                    height: toDoButton.height
                    width: parent.width

                    CommonButton {
                        id: toDoButton

                        selected: editToDoSheet.type === "to-do"
                        text: "To-Do"
                        width: parent.width / 2

                        onClicked: {
                            type = "to-do"
                            colorButtonRow.enabled = (type === "to-do")
                        }
                    }
                    CommonButton {
                        id: noteButton

                        selected: editToDoSheet.type === "note"
                        text: "Note"
                        width: parent.width / 2

                        onClicked: {
                            type = "note"
                            colorButtonRow.enabled = (type === "to-do")
                        }
                    }
                }

                Row {
                    id: colorButtonRow

                    height: blueButton.height
                    width: parent.width

                    CommonButton {
                        id: blueButton


                        iconSource: "../icons/to-do_blue.png"
                        selected: editToDoSheet.color === "blue"
                        width: parent.width / 4

                        onClicked: editToDoSheet.color = "blue"
                    }
                    CommonButton {
                        id: greenButton

                        iconSource: "../icons/to-do_green.png"
                        selected: editToDoSheet.color === "green"
                        width: parent.width / 4

                        onClicked: editToDoSheet.color = "green"
                    }
                    CommonButton {
                        id: yellowButton

                        iconSource: "../icons/to-do_yellow.png"
                        selected: editToDoSheet.color === "yellow"
                        width: parent.width / 4

                        onClicked: editToDoSheet.color = "yellow"
                    }
                    CommonButton {
                        id: redButton

                        iconSource: "../icons/to-do_red.png"
                        selected: editToDoSheet.color === "red"
                        width: parent.width / 4

                        onClicked: editToDoSheet.color = "red"
                    }
                }

                CommonTextArea{
                    id: textInput
                    width: parent.width
                    textFormat: TextEdit.PlainText

                    onKeyPressed: {
                        if (event.modifiers & Qt.AltModifier) {
                            switch (event.key) {
                            case Qt.Key_1:
                                blueButton.clicked()
                                break
                            case Qt.Key_2:
                                greenButton.clicked()
                                break
                            case Qt.Key_3:
                                yellowButton.clicked()
                                break
                            case Qt.Key_4:
                                redButton.clicked()
                                break
                            }
                        }
                    }

                    Keys.onEscapePressed: editToDoSheet.close()
                    onEnter: accepted()
                }

                MouseArea {
                    anchors.fill: parent
                    z: -1
                    onClicked: focus = true
                }
            }

            MouseArea {
                anchors.fill: parent
                z: -1
                onClicked: focus = true
            }
        }
    }
}
