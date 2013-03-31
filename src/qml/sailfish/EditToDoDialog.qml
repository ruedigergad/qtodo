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
import Sailfish.Silica 1.0
import "../common"

Dialog {
    id: editToDoDialog
    anchors.bottom: parent.bottom
    anchors.top: parent.bottom
    width: parent.width

    visible: false

    property bool edit: false
    property int index: -1

    property alias text: textInput.text

    property string color: "blue"
    property string type: "to-do"

    DialogHeader {
        id: dialogHeader
    }

    Item {
        id: inputItem

        anchors {top: dialogHeader.bottom; left: parent.left; right: parent.right; bottom: parent.bottom}

        Flickable {
            id: inputFlickable

            anchors.fill: parent
            contentHeight: sheetContent.height

            Column {
                id: sheetContent
                spacing: 12

                anchors{top: parent.top; left: parent.left; right: parent.right; margins: 15}

                ComboBox {
                    id: typeComboBox
                    width: parent.width
                    label: "Type: "

                    menu: ContextMenu {
                        MenuItem {
                            id: toDoItem
                            text: "ToDo"
                            onClicked: {
                                type = "to-do"
                                colorButtonRow.enabled = (type === "to-do")
                            }
                        }

                        MenuItem {
                            id: noteItem
                            text: "Note"
                            onClicked: {
                                type = "note"
                                colorButtonRow.enabled = (type === "to-do")
                            }
                        }
                    }
                }

                ComboBox {
                    id: importanceComboBox
                    width: parent.width
                    label: "Color: "

                    menu: ContextMenu {
                        MenuItem {
                            text: "Blue"
                            color: "blue"
                        }

                        MenuItem {
                            text: "Green"
                            color: "green"
                        }

                        MenuItem {
                            text: "Yellow"
                            color: "yellow"
                        }

                        MenuItem {
                            text: "Red"
                            color: "red"
                        }
                    }

                    onCurrentItemChanged: {
                        value = currentItem.text
                        valueColor = currentItem.color
                        editToDoDialog.color = value.toLowerCase()
                    }
                }

                CommonTextArea{
                    id: textInput
                    width: parent.width
                }
            }
        }
    }

    onAccepted: {
        if(edit){
            mainRectangle.treeView.currentModel.updateElement(mainRectangle.treeView.currentIndex, type, text, color)
        }else{
            mainRectangle.treeView.currentModel.addElement(type, text, color)
        }

        editToDoDialog.close();
    }
}
