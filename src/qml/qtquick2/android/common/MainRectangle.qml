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
import qtodo 1.0
//import SyncToImap 1.0
//import "../synctoimap"

Item {
    id: mainRectangle

    property alias aboutDialog: aboutDialog
    property alias color: treeView.color
    property alias confirmDeleteDialog: confirmDeleteDialog
    property alias confirmCleanDoneDialog: confirmCleanDoneDialog
    property alias confirmSyncToImapDialog: confirmSyncToImapDialog
    property alias confirmSyncSketchesToImapDialog: confirmSyncSketchesToImapDialog
    property alias treeView: treeView

//    property string _todoPath: fileHelper.home() + "/to-do-o"
    property string _todoPath: "to-do-o"
    property string _sketchPath: _todoPath + "/sketches"

    property bool isTodo

    function addItem() {
        editToDoItem.itemColor = "blue"
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
            editToDoItem.itemColor = currentItem.itemColor
            editToDoItem.type = currentItem.type
            editToDoItem.text = currentItem.text
            editToDoItem.edit = true
            editToDoItem.open()
        }
    }

    function moveCurrentItemToTop() {
        treeView.currentNodeListView.model.move(treeView.currentIndex, 0)
        storage.save()
    }

    function moveCurrentItemToBottom() {
        treeView.currentNodeListView.model.move(treeView.currentIndex, treeView.currentNodeListView.model.count)
        storage.save()
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

        parent: main

        onClosed: toolBar.enabled = true
        onOpened: toolBar.enabled = false
    }

    ConfirmationDialog {
        id: confirmDeleteDialog

        parent: main
        titleText: "Delete?"

        onClosed: toolBar.enabled = true
        onOpened: toolBar.enabled = false

        onAccepted: {
            var currentItem = treeView.currentItem
            console.log("Deleting item: " + currentItem)

            if (currentItem.type === "to-do") {
                console.log("Item is a to-do entry. Searching for nested sketches.")
                var nestedSketches = treeView.currentNodeListView.model.getSketchNamesForIndex(treeView.currentIndex)
                console.log("nestedSketches: " + nestedSketches)

                for (var i = 0; i < nestedSketches.length; i++) {
                    var fullFileName = _sketchPath + "/" + nestedSketches[i]
                    console.log("Deleting: " + fullFileName)
//                    fileHelper.rm(fullFileName)
                }
            } else if (currentItem.type === "sketch") {
                var fullFileName = _sketchPath + "/" + currentItem.text
                console.log("Item is a sketch. Removing file: " +  fullFileName)
//                fileHelper.rm(fullFileName)
            }

            treeView.currentNodeListView.model.deleteElement(treeView.currentIndex)
        }
    }

    ConfirmationDialog {
        id: confirmCleanDoneDialog

        message: "Delete all items marked as done?"
        parent: main
        titleText: "Clean Done?"

        onClosed: toolBar.enabled = true
        onOpened: toolBar.enabled = false

        onAccepted: {
            treeView.currentNodeListView.model.cleanDone()
        }
    }

    ConfirmationDialog {
        id: confirmSyncToImapDialog

        message: "This may take some time."
        parent: main
        titleText: "Sync to-do list?"

        onOpened: toolBar.enabled = false
        onRejected: toolBar.enabled = true

        onAccepted: {
//            syncFileToImap.syncFile(fileHelper.home() + "/to-do-o", "default.xml")
        }
    }

    ConfirmationDialog {
        id: confirmSyncSketchesToImapDialog

        message: "This may take some time."
        parent: main
        titleText: "Sync sketches?"

        onOpened: toolBar.enabled = false
        onRejected: toolBar.enabled = true

        onAccepted: {
            var mySketches = rootElementModel.getSketchNamesForIndex(-1)
//            syncDirToImap.syncDirFiltered(fileHelper.home() + "/to-do-o/sketches", "sketch:", (mySketches.length === 0) ? ["none"] : mySketches)
        }
    }

//    FileHelper { id: fileHelper }

//    Merger {
//        id: todoMerger

//        function mergeDir (dirName) {
//            console.log("Merging directory: " + dirName)
//        }

//        function mergeFile (syncFileName) {
//            console.log("Merging sync file: " + syncFileName)

//            if (rootElementModel.rowCount() === 0) {
//                console.log("Initial sync, reloading storage...")
//                fileHelper.rm(fileHelper.home() + "/to-do-o/default.xml")
//                console.log("Copying " + syncFileName + " to " + fileHelper.home() + "/to-do-o/default.xml")
//                fileHelper.cp(syncFileName, fileHelper.home() + "/to-do-o/default.xml")
//                fileHelper.rm(syncFileName)
//                storage.open()
//                return false
//            } else {
//                mergeTodoStorage(syncFileName)
//                fileHelper.rm(syncFileName)
//                storage.open()
//                return true
//            }
//        }
//    }

    MessageDialog {
        id: messageDialog
//        onClosed: syncToImapBase.messageDialogClosed()
    }

    NodeListModel {
        id: rootElementModel
    }

//    ProgressDialog {
//        id: progressDialog

//        title: "Syncing..."
//        message: "Sync is in progess."

//        maxValue: 6
//        currentValue: 0
//    }

//    SyncDirToImap {
//        id: syncDirToImap

//        imapFolderName: "qtodo"
//        merger: todoMerger
//        messageDialog: messageDialog
//        progressDialog: progressDialog
//        useDialogs: true

//        onSuccess: {
//            console.log("Sync succeeded. Cleaning remaining sketch files.")

//            var sketchFiles = fileHelper.ls(_sketchPath)
//            var usedSketches = rootElementModel.getSketchNamesForIndex(-1)

//            for (var i = 0; i < sketchFiles.length; i++) {
//                var sketch = sketchFiles[i]
//                var deleteSketch = true

//                for (var j = 0; j < usedSketches.length; j++) {
//                    if (usedSketches[j] === sketch) {
//                        deleteSketch = false
//                        break
//                    }
//                }

//                if (deleteSketch) {
//                    console.log("Cleaning " + sketch + ".")
//                    fileHelper.rm(_sketchPath + "/" + sketch)
//                }
//            }
//        }

//        onFinished: toolBar.enabled = true
//        onStarted: toolBar.enabled = false
//    }

//    SyncFileToImap {
//        id: syncFileToImap

//        imapFolderName: "qtodo"
//        merger: todoMerger
//        messageDialog: messageDialog
//        progressDialog: progressDialog
//        useDialogs: true

//        onFinished: toolBar.enabled = true
//        onStarted: toolBar.enabled = false
//    }

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
    }
}
