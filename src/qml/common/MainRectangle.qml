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
    property alias confirmSyncSketchesToImapDialog: confirmSyncSketchesToImapDialog
    property alias treeView: treeView

    property string _todoPath: fileHelper.home() + "/to-do-o"
    property string _sketchPath: _todoPath + "/sketches"

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
        editSketchItem.sketchFileName = (rootElementModel.getMaxId() + 1) + ".png"
        editSketchItem.open()
    }

    function deleteCurrentItem() {
        confirmDeleteDialog.message = "Delete \"" + treeView.currentItem.text + "\"?"
        confirmDeleteDialog.open()
    }

    function editCurrentItem() {
        var currentItem = treeView.currentItem
        if (currentItem.type === "sketch") {
            editSketchItem.sketchFileName = currentItem.text
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
            console.log("Deleting item: " + currentItem)
            if (currentItem.type === "sketch") {
                var fullFileName = _sketchPath + "/" + currentItem.text
                console.log("Item is a sketch. Removing file: " +  fullFileName)
                fileHelper.rm(fullFileName)
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
            syncFileToImap.syncFile(fileHelper.home() + "/to-do-o", "default.xml")
        }
    }

    ConfirmationDialog {
        id: confirmSyncSketchesToImapDialog

        titleText: "Sync sketches to IMAP?"
        message: "This may take some time."

        onAccepted: {
            syncDirToImap.syncDir(fileHelper.home() + "/to-do-o/sketches", "sketch:")
        }
    }

    FileHelper { id: fileHelper }

    Merger {
        id: todoMerger

        function mergeDir (dirName) {
            console.log("Merging directory: " + dirName)
        }

        function mergeFile (syncFileName) {
            console.log("Merging sync file: " + syncFileName)

            if (rootElementModel.rowCount() === 0) {
                console.log("Initial sync, reloading storage...")
                fileHelper.rm(fileHelper.home() + "/to-do-o/default.xml")
                console.log("Copying " + syncFileName + " to " + fileHelper.home() + "/to-do-o/default.xml")
                fileHelper.cp(syncFileName, fileHelper.home() + "/to-do-o/default.xml")
                fileHelper.rm(syncFileName)
                storage.open()
                return false
            } else {
                mergeTodoStorage(syncFileName)
                fileHelper.rm(syncFileName)
                storage.open()
                return true
            }
        }
    }

    NodeListModel {
        id: rootElementModel
    }


    SyncDirToImap {
        id: syncDirToImap

        imapFolderName: "qtodo"
        merger: todoMerger
    }

    SyncFileToImap {
        id: syncFileToImap

        imapFolderName: "qtodo"
        merger: todoMerger
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

        if (rootElementModel.rowCount() === 0) {
            storage.save()
        }

//        storage.open("/opt/qtodo/sample.xml")
    }
}


