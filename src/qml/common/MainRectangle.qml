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

Item {
    id: mainRectangle

    property alias aboutDialog: aboutDialog
    property alias color: treeView.color
    property alias confirmDeleteDialog: confirmDeleteDialog
    property alias confirmCleanDoneDialog: confirmCleanDoneDialog
    property alias confirmSyncToImapDialog: confirmSyncToImapDialog
    property alias treeView: treeView

    property bool isTodo

    function addItem() {
        editToDoItem.color = "blue"
        editToDoItem.type = "to-do"
        editToDoItem.text = ""
        editToDoItem.edit = false
        editToDoItem.open()
    }

    function addSketch() {
        editSketchItem.edit = false
        editSketchItem.sketchPath = storage.getPath() + "/sketches/" + (rootElementModel.getMaxId() + 1) + ".png"
        editSketchItem.open()
    }

    function deleteCurrentItem() {
        confirmDeleteDialog.message = "Delete \"" + treeView.currentItem.text + "\"?"
        confirmDeleteDialog.open()
    }

    function editCurrentItem() {
        var currentItem = treeView.currentItem
        if (currentItem.type === "sketch") {
            editSketchItem.sketchPath = currentItem.text
            editSketchItem.edit = true
            editSketchItem.open()
        } else {
            editToDoItem.color = currentItem.itemColor
            editToDoItem.type = currentItem.type
            editToDoItem.text = currentItem.text
            editToDoItem.edit = true
            editToDoItem.open()
        }
    }

    TreeView {
        id: treeView
        anchors.fill: parent
        model: rootElementModel

        onCurrentItemChanged: {
            console.log(currentItem.type)
            if(currentItem === null) {
                mainRectangle.isTodo = false
            }else{
                mainRectangle.isTodo = currentItem.type === "to-do"
            }
        }
        onDoubleClicked: editCurrentItem()
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

    ConfirmationDialog {
        id: confirmCleanDoneDialog

        titleText: "Clean Done?"
        message: "Delete all items marked as done?"

        onAccepted: {
            treeView.currentModel.cleanDone()
        }
    }

    ConfirmationDialog {
        id: confirmSyncToImapDialog

        titleText: "Sync to IMAP?"
        message: "This may take some time."

        onAccepted: {
            syncToImap.startSync()
        }
    }

    FileHelper { id: fileHelper }

    Merger {
        id: merger
    }

    NodeListModel {
        id: rootElementModel
    }

    SyncToImap {
        id: syncToImap

        imapFolderName: "qtodo"
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
    }
}


