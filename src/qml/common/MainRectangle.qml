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

    function moveCurrentItemToTop() {
        treeView.currentModel.move(treeView.currentIndex, 0)
        storage.save()
    }

    function moveCurrentItemToBottom() {
        treeView.currentModel.move(treeView.currentIndex, treeView.currentModel.count)
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

        onClosed: commonTools.enabled = true
        onOpened: commonTools.enabled = false
    }

    ConfirmationDialog {
        id: confirmDeleteDialog

        titleText: "Delete?"

        onClosed: commonTools.enabled = true
        onOpened: commonTools.enabled = false

        onAccepted: {
            var currentItem = treeView.currentItem
            console.log("Deleting item: " + currentItem)

            if (currentItem.type === "to-do") {
                console.log("Item is a to-do entry. Searching for nested sketches.")
                var nestedSketches = treeView.currentModel.getSketchNamesForIndex(treeView.currentIndex)
                console.log("nestedSketches: " + nestedSketches)

                for (var i = 0; i < nestedSketches.length; i++) {
                    var fullFileName = _sketchPath + "/" + nestedSketches[i]
                    console.log("Deleting: " + fullFileName)
                    fileHelper.rm(fullFileName)
                }
            } else if (currentItem.type === "sketch") {
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

        onClosed: commonTools.enabled = true
        onOpened: commonTools.enabled = false

        onAccepted: {
            treeView.currentModel.cleanDone()
        }
    }

    ConfirmationDialog {
        id: confirmSyncToImapDialog

        titleText: "Sync to-do list?"
        message: "This may take some time."

        onOpened: commonTools.enabled = false
        onRejected: commonTools.enabled = true

        onAccepted: {
            syncFileToImap.syncFile(fileHelper.home() + "/to-do-o", "default.xml")
        }
    }

    ConfirmationDialog {
        id: confirmSyncSketchesToImapDialog

        titleText: "Sync sketches?"
        message: "This may take some time."

        onOpened: commonTools.enabled = false
        onRejected: commonTools.enabled = true

        onAccepted: {
            var mySketches = rootElementModel.getSketchNamesForIndex(-1)
            syncDirToImap.syncDirFiltered(fileHelper.home() + "/to-do-o/sketches", "sketch:", (mySketches.length === 0) ? ["none"] : mySketches)
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

        onSuccess: {
            console.log("Sync succeeded. Cleaning remaining sketch files.")

            var sketchFiles = fileHelper.ls(_sketchPath)
            var usedSketches = rootElementModel.getSketchNamesForIndex(-1)

            for (var i = 0; i < sketchFiles.length; i++) {
                var sketch = sketchFiles[i]
                var deleteSketch = true

                for (var j = 0; j < usedSketches.length; j++) {
                    if (usedSketches[j] === sketch) {
                        deleteSketch = false
                        break
                    }
                }

                if (deleteSketch) {
                    console.log("Cleaning " + sketch + ".")
                    fileHelper.rm(_sketchPath + "/" + sketch)
                }
            }
        }

        onFinished: commonTools.enabled = true
        onStarted: commonTools.enabled = false
    }

    SyncFileToImap {
        id: syncFileToImap

        imapFolderName: "qtodo"
        merger: todoMerger

        onFinished: commonTools.enabled = true
        onStarted: commonTools.enabled = false
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
    }
}


