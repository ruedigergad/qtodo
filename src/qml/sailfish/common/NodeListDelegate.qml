/*
 *  Copyright 2011 - 2013 Ruediger Gad
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
 *
 *  ###################
 *
 *  Note: The code of the TreeView is additionally released under the terms
 *  of the GNU Lesser General Public License (LGPL) as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  Files considered part of the TreeView are: TreeView.qml, NodeListView.qml,
 *  and nodelisthelper.js. These files are additionally licensed under the
 *  terms of the LGPL.
 *
 */

import QtQuick 1.1

import Sailfish.Silica 1.0

Item {
    id: nodeListDelegate
    width: tagName === "sketch" ? sketchContentDelegate.width : nodeListView.width

    property Item contextMenu: null
    property bool menuOpen: contextMenu != null && contextMenu.parent === nodeListDelegate
    property int tempHeight: tagName === "sketch" ? sketchContentDelegate.height : textContentDelegate.height

    height: menuOpen ? contextMenu.height + tempHeight : tempHeight

    /*
     * Begin of custom code to display the data. Here the Q To-Do to-do or
     * note elements are shown. Customize this to display your own stuff.
     */
    Item {
        id: sketchContentDelegate
        anchors.left: parent.left
        visible: tagName === "sketch"
        height: sketchImage.height
        width: sketchImage.width

        Image {
            id: sketchImage
            fillMode: Image.PreserveAspectFit
            cache: false
            source: tagName === "sketch" ? elementText : ""
            height: sourceSize.height * (width / sourceSize.width)
            width: nodeListView.width * 0.5
        }
    }

    Item {
        id: textContentDelegate
        anchors.left: parent.left
        width: nodeListView.width
        height: elementIcon.height

        visible: tagName !== "sketch"

        Image {
            id: elementIcon
            anchors.left: parent.left
            height: textDelegate.height
            fillMode: Image.PreserveAspectFit
            source: tagName === "to-do"
                    ? "../icons/to-do_" + (isDone ? "done_" : "") + elementColor + ".png"
                    : "../icons/note.png"
        }

        Item {
            id: textItem
            anchors.left: elementIcon.right
            anchors.right: nextButton.left
            height: textDelegate.height

            Rectangle {
                id: progressBar
                anchors.left: parent.left
                height: parent.height
                width: {
                    return (displayedProgress > 0) && (displayedProgress <= 1) ?
                                displayedProgress * parent.width :
                                0
                }
                color: "#00cc00"
                opacity: 0.6
            }

            Rectangle {
                id: workLeft
                anchors.left: progressBar.right
                anchors.right: parent.right
                height: parent.height
                color: getColor(itemColor)
                opacity: 0.2
            }

            Text {
                id: textDelegate
                anchors.left: parent.left
                anchors.leftMargin: 2
                width: parent.width

                text: elementText
                font.pixelSize: 28
                horizontalAlignment: Text.AlignHLeft
                wrapMode: Text.WordWrap
                color: theme.primaryColor
            }
        }

        Item {
            id: nextButton
            anchors.right: parent.right
            width: (! isExpandable) ? 0 : 40
            height: parent.height

            Rectangle{
                id: button
                anchors.centerIn: parent
                width: 30
                height: 30

                visible: isExpandable

                radius: 10
                color: nextMouseArea.pressed ? "gray" : "lightgray"

                Image {
                    id: nextIcon
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit

                    opacity: (isLeaf) ? 0.3 : 1
                    source: "../icons/next.png"
                }

                MouseArea {
                    id: nextMouseArea
                    anchors.fill: parent

                    onClicked: {
                        selectItem()
                        treeView.currentLevel++
                    }
                }
            }
        }
    }
    /*
     * End of custom code for displaying the data.
     */

    MouseArea {
        id: contentMouseArea
        anchors.fill: parent
        onClicked: selectItem()
        onDoubleClicked: {
            selectItem()
            treeView.doubleClicked()
        }
        onPressAndHold: {
            selectItem()
            if (!contextMenu)
                contextMenu = contextMenuComponent.createObject(nodeListView)
            contextMenu.show(nodeListDelegate)
        }
    }

    Rectangle {
        id: clickHighlight
        anchors.fill: parent
        color: "black"
        radius: 10
        opacity: contentMouseArea.pressed ? 0.3 : 0
    }

    Rectangle {
        id: highlight
        anchors.fill: parent
        color: "gray"
        opacity: nodeListView.currentIndex === index ? 0.5 : 0
    }

    Component {
        id: contextMenuComponent
        ContextMenu {
            id: menu
            MenuItem {
                text: treeView.currentItem.done ? "Mark ToDo" : "Mark Done"
                onClicked: treeView.toggleDone()
            }
            MenuItem {
                text: "Edit"
                onClicked: menu.parent.remove()
            }
            MenuItem {
                text: "New Entry"
                onClicked: {
                   editToDoDialog.color = "blue"
                   editToDoDialog.type = "to-do"
                   editToDoDialog.text = ""
                   editToDoDialog.edit = false
                   editToDoDialog.open()
               }
            }
            MenuItem {
                text: "New Sketch"
                onClicked: menu.parent.remove()
            }
            MenuItem {
                text: "Delete"
                onClicked: {
                    mainRectangle.confirmDeleteDialog.message = "Delete \"" + mainRectangle.treeView.currentItem.text + "\"?"
                    mainRectangle.confirmDeleteDialog.open()
                }
            }
        }
    }
}
