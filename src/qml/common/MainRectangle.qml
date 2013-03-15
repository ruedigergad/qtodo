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
import qtodo 1.0

Rectangle{
    id: mainRectangle

    anchors.fill: parent
    color: "lightgoldenrodyellow"

    property alias treeView: treeView
    property alias confirmDeleteDialog: confirmDeleteDialog
    property alias aboutDialog: aboutDialog

    property bool isTodo;

    function editSelectedItem() {
        var currentItem = treeView.currentItem
        if (currentItem.type === "sketch") {
            editSketchSheet.sketchPath = currentItem.text
            editSketchSheet.edit = true
            editSketchSheet.open()
        } else {
            editToDoSheet.color = currentItem.itemColor
            editToDoSheet.type = currentItem.type
            editToDoSheet.text = currentItem.text
            editToDoSheet.edit = true
            editToDoSheet.open()
        }
    }

    Rectangle {
        id: header
        height: 72
        color: "#0c61a8"
        anchors{left: parent.left; right: parent.right; top: parent.top}
        z: 48

        Text {
            text: "My To-Dos"
            color: "white"
            font{pixelSize: 32; family: "Nokia Pure Text Light"}
            anchors{left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter}
        }
    }

    TreeView {
        id: treeView
        anchors{left: parent.left; right: parent.right; bottom: parent.bottom; top: header.bottom}
        model: rootElementModel
        color: parent.color

        onCurrentItemChanged: {
            console.log(currentItem.type)
            if(currentItem === null) {
                mainRectangle.isTodo = false
            }else{
                mainRectangle.isTodo = currentItem.type === "to-do"
            }
        }
        onDoubleClicked: editSelectedItem()
        onPressAndHold: contextMenu.open()
    }

    AboutDialog {
        id: aboutDialog
    }

    ConfirmationDialog {
        id: confirmDeleteDialog

        titleText: "Delete?"

        onAccepted: {
            var currentItem = treeView.currentItem
            if (currentItem.type === "sketch") {
                fileHelper.rm(currentItem.text)
            }
            treeView.currentModel.deleteElement(treeView.currentIndex)
        }
    }

    FileHelper { id: fileHelper }

    NodeListModel {
        id: rootElementModel
    }

    ToDoStorage {
        id: storage

        onDocumentOpened: {
            console.log("Document opened.")
            rootElementModel.setRoot(storage);
        }
    }

    Component.onCompleted: {
        storage.open()
//        storage.open("/opt/qtodo/sample.xml")

        iconMarkDone.enabled = false
    }
}


