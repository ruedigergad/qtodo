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
import qmlcanvas 1.0

Item {
    id: editSketchSheet
    anchors.bottom: parent.bottom
    anchors.top: parent.bottom
    width: parent.width

    visible: false
    z: 1

    property bool edit: false
    property string sketchPath: ""

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
        closing()
        state = "closed"
    }

    function open(){
        console.log("open")

        visible = true

        opening()
        state = "open"
    }

    onOpened: {
        if (edit) {
            drawing.load(sketchPath)
        } else {
            drawing.init()
        }

        drawing.drawColor = "black"
    }

    onStateChanged: {
        console.log("Edit entry dialog state changed: " + state)
    }

    states: [
        State {
            name: "open"
            AnchorChanges { target: editSketchSheet; anchors.top: parent.top }
        },
        State {
            name: "closed"
            AnchorChanges { target: editSketchSheet; anchors.top: parent.bottom }
        }
    ]

    transitions: Transition {
        SequentialAnimation {
            AnchorAnimation { duration: 250; easing.type: Easing.OutCubic }
            ScriptAction { script: editSketchSheet.finished() }
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
            onClicked: editSketchSheet.close();
        }

        Text {id: entryLabel; text: "Entry"; font.pixelSize: 30; font.capitalization: Font.SmallCaps; font.bold: true; anchors.centerIn: parent}

        CommonButton{
            id: acceptButton
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            text: "OK"
            onClicked: {
                editSketchSheet.accepted()
            }
        }
    }

    Rectangle {
        id: inputRectangle

        anchors {top: buttonBar.bottom; left: parent.left; right: parent.right; bottom: parent.bottom}
        color: "white"

        Item {
        anchors.fill: parent

            Row {
                id: colorButtonRow
                anchors{top: parent.top; left: parent.left; right: parent.right}

                CommonButton {
                    id: blackButton
                    iconSource: "../icons/sketch_black.png"
                    onClicked: drawing.drawColor = "black"
                }
                CommonButton {
                    iconSource: "../icons/sketch_blue.png"
                    onClicked: drawing.drawColor = "blue"
                }
                CommonButton {
                    iconSource: "../icons/sketch_green.png"
                    onClicked: drawing.drawColor = "green"
                }
                CommonButton {
                    iconSource: "../icons/sketch_yellow.png"
                    onClicked: drawing.drawColor = "yellow"
                }
                CommonButton {
                    iconSource: "../icons/sketch_red.png"
                    onClicked: drawing.drawColor = "red"
                }
                CommonButton {
                    iconSource: "../icons/sketch_erase.png"
                    onClicked: drawing.drawColor = drawing.backgroundColor
                }
            }

            Drawing {
                id: drawing
                anchors{top: colorButtonRow.bottom; left: parent.left; right: parent.right; bottom: parent.bottom}
                backgroundColor: mainRectangle.color
                lineWidth: (drawColor === backgroundColor) ? 35 : 3
            }
        }
    }

    onAccepted: {
        console.log("Saving sketch to: " + sketchPath)

        drawing.save(sketchPath)

        if (edit) {
            mainRectangle.treeView.currentModel.updateElement(mainRectangle.treeView.currentIndex, "sketch", sketchPath, "na")
        } else {
            mainRectangle.treeView.currentModel.addElement("sketch", sketchPath, "na")
        }

        editSketchSheet.close();
    }
}
