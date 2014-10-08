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
    id: editToDoSheet
    anchors.bottom: parent.bottom
    anchors.top: parent.bottom
    color: primaryBackgroundColor
    width: parent.width

    visible: false
    z: 1

    property alias acceptText: acceptButton.text
    property alias cancelText: rejectButton.text
    property string itemColor: "blue"
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
        console.log("EditToDoSheet: finished()")
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

    function save() {
        if(edit){
            mainRectangle.treeView.currentNodeListView.model.updateElement(mainRectangle.treeView.currentIndex, type, text, itemColor)
        }else{
            mainRectangle.treeView.currentNodeListView.model.addElement(type, text, itemColor)
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
        if (state === "open") {
            textInput.forceActiveFocus()
        }
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
            AnchorAnimation { duration: primaryAnimationDuration; easing.type: Easing.OutCubic }
            ScriptAction { script: editToDoSheet.finished() }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: focus = true
    }

    Rectangle {
        id: topBar
        anchors.top: parent.top
        height: rejectButton.height + secondaryBorderSize * 0.25
        width: parent.width
        z: 4

        color: secondaryBackgroundColor
        opacity: secondaryBackgroundOpacity

        Text {
            id: entryLabel

            anchors.centerIn: parent
            color: primaryFontColor
            font { pointSize: primaryFontSize; capitalization: Font.SmallCaps; bold: true }
            text: (edit ? "Edit" : "Add") + " Entry"
        }
    }

    Row {
        id: colorButtonRow

        anchors {top: topBar.bottom; left: parent.left; right: parent.right; margins: secondaryBorderSize * 0.25}
        height: blueButton.height + secondaryBorderSize * 0.25
        spacing: secondaryBorderSize * 0.25

        CommonButton {
            id: blueButton


            iconSource: "../icons/to-do_blue.png"
            selected: editToDoSheet.itemColor === "blue"
            width: (parent.width - parent.spacing * 3) / 4

            onClicked: editToDoSheet.itemColor = "blue"
        }
        CommonButton {
            id: greenButton

            iconSource: "../icons/to-do_green.png"
            selected: editToDoSheet.itemColor === "green"
            width: blueButton.width

            onClicked: editToDoSheet.itemColor = "green"
        }
        CommonButton {
            id: yellowButton

            iconSource: "../icons/to-do_yellow.png"
            selected: editToDoSheet.itemColor === "yellow"
            width: blueButton.width

            onClicked: editToDoSheet.itemColor = "yellow"
        }
        CommonButton {
            id: redButton

            iconSource: "../icons/to-do_red.png"
            selected: editToDoSheet.itemColor === "red"
            width: blueButton.width

            onClicked: editToDoSheet.itemColor = "red"
        }
    }

    Rectangle {
        id: inputRectangle

        anchors {top: colorButtonRow.bottom; left: parent.left; right: parent.right; bottom: parent.bottom}
        color: primaryBackgroundColor
        opacity: primaryBackgroundOpacity

        Flickable {
            id: inputFlickable

            anchors {top: parent.top; left: parent.left; right: parent.right}
            clip: true
            contentHeight: sheetContent.height + secondaryBorderSize * 0.25
            height: Math.min(contentHeight, parent.height - bottomBar.height) + bottomBar.anchors.topMargin

            Column {
                id: sheetContent
                spacing: secondaryBorderSize

                anchors{top: parent.top; left: parent.left; right: parent.right; margins: secondaryBorderSize * 0.25}

                CommonTextArea {
                    id: textInput

                    textFormat: TextEdit.PlainText
                    width: parent.width

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
            }
        }

        Rectangle {
            id: bottomBar
            anchors.top: inputFlickable.bottom
            anchors.topMargin: secondaryBorderSize * 0.25
            height: rejectButton.height + secondaryBorderSize * 0.5
            width: parent.width
            z: 4

            color: primaryBackgroundColor
            opacity: primaryBackgroundOpacity

            CommonButton{
                id: rejectButton

                anchors.left: parent.left
                anchors.leftMargin: secondaryBorderSize * 0.25
                text: "Cancel"
                width: (parent.width - 3 * secondaryBorderSize * 0.25) / 2

                onClicked: editToDoSheet.close();
            }

            CommonButton {
                id: acceptButton

                anchors.right: parent.right
                anchors.rightMargin: secondaryBorderSize * 0.25
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
    }
}
