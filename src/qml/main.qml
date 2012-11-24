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
import qtodo 1.0

PageStackWindow {
    id: appWindow

    initialPage: mainPage

    function editSelectedItem(){
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

    Page {
        id: mainPage
        tools: commonTools

        orientationLock: PageOrientation.LockPortrait

        Rectangle{
            id: mainRectangle
            anchors.fill: parent
            color: "lightgoldenrodyellow"

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
                    if(currentItem === null) {
                        iconMarkDone.enabled = false
                    }else{
                        iconMarkDone.enabled = true

                        if(currentItem.type === "note"){
                            iconMarkDone.enabled = false
                        }else{
                            iconMarkDone.enabled = true
                        }
                    }
                }
                onDoubleClicked: editSelectedItem()
                onPressAndHold: contextMenu.open()
            }
        }
    }

    AboutDialog {
        id: aboutDialog
    }

    QueryDialog {
        id: confirmDeleteDialog

        titleText: "Delete?"

        acceptButtonText: "OK"
        rejectButtonText: "Cancel"

        onAccepted: treeView.currentModel.deleteElement(treeView.currentIndex)
    }

    EditToDoSheet { id: editToDoSheet }

    EditSketchSheet { id: editSketchSheet }

    ToolBarLayout {
        id: commonTools
        visible: true

        ToolIcon { id: iconAdd; platformIconId: "toolbar-add"
            opacity: enabled ? 1 : 0.5
            onClicked: {
                editToDoSheet.color = "blue"
                editToDoSheet.type = "to-do"
                editToDoSheet.text = ""
                editToDoSheet.edit = false
                editToDoSheet.open()
            }
        }
        ToolIcon { id: iconSketch; iconSource: "../icons/sketch.png"
            opacity: enabled ? 1 : 0.5
            onClicked: {
                editSketchSheet.edit = false
                editSketchSheet.sketchPath = storage.getPath() + "/sketches/" + (rootElementModel.getMaxId() + 1) + ".png"
                editSketchSheet.open()
            }
        }
        ToolIcon { id: iconMarkDone; platformIconId: "toolbar-done"
            enabled: treeView.currentItem.type === "to-do"
            opacity: enabled ? 1 : 0.5
            onClicked: {
                if(treeView.currentItem.done){
                    treeView.currentModel.setAttribute(treeView.currentIndex, "done", "false")
                }else{
                    treeView.currentModel.setAttribute(treeView.currentIndex, "done", "true")
                }
            }
        }
        ToolIcon { id: iconDelete; platformIconId: "toolbar-delete"
            enabled: treeView.currentIndex >= 0
            opacity: enabled ? 1 : 0.5
            onClicked: confirmDeleteDialog.open()
        }
        ToolIcon { id: iconBack; iconSource: "../icons/back.png"
            enabled: treeView.currentLevel > 0
            opacity: enabled ? 1 : 0.5
            onClicked: treeView.currentLevel--
        }
        ToolIcon { id: iconMenu; platformIconId: "toolbar-view-menu"
             anchors.right: parent===undefined ? undefined : parent.right
             onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
             opacity: enabled ? 1 : 0.5
        }
    }

    ContextMenu {
        id: contextMenu
        MenuLayout {
            MenuItem {
                text: "Edit"
                onClicked: {
                    editSelectedItem()
                }
            }
            MenuItem {
                text: "Delete"
                onClicked: {
                    confirmDeleteDialog.message = "Delete \"" + treeView.currentItem.text + "\"?"
                    confirmDeleteDialog.open()
                }
            }
        }
    }

    Menu {
        id: myMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem { 
                text: "About" 
                onClicked: aboutDialog.open()
            }
        }
    }

    NodeListModel{
        id: rootElementModel

        onChanged: storage.save()
    }

    ToDoStorage{
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
