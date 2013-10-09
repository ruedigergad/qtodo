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
import Sailfish.Silica 1.0
import "common"

ApplicationWindow {
    id: mainWindow

    property int primaryFontSize: Theme.fontSizeMedium
    property int primaryBorderSize: 25

    property string primaryBackgroundColor: "gray"
    property double primaryBackgroundOpacity: 0.7
    property string secondaryBackgroundColor: "gray"
    property double secondaryBackgroundOpacity: 0.7

    initialPage: Page {
        id: mainPage

        Item {
            id: main

            anchors.fill: parent

        //    radius: primaryFontSize * 0.5

            Item {
                anchors {top: parent.top; left: parent.left; right: parent.right; bottom: toolBar.top}

                Header {
                    id: header

                    color: "transparent"
                    textColor: Theme.primaryColor
                }

                MainRectangle {
                    id: mainRectangle
                    anchors{left: parent.left; right: parent.right; top: header.bottom; bottom: parent.bottom}
                    focus: true

                    Keys.onDownPressed:{
                        if (mainRectangle.treeView.currentNodeListView.currentIndex < (mainRectangle.treeView.currentNodeListView.model.count - 1)) {
                            mainRectangle.treeView.currentNodeListView.currentIndex++
                            mainRectangle.treeView.expandTree()
                        }
                    }
                    Keys.onUpPressed: {
                        if (mainRectangle.treeView.currentNodeListView.currentIndex > 0) {
                            mainRectangle.treeView.currentNodeListView.currentIndex--
                            mainRectangle.treeView.expandTree()
                        }
                    }
                    Keys.onLeftPressed: mainRectangle.treeView.currentLevel--
                    Keys.onRightPressed: {
                        mainRectangle.treeView.currentLevel++
                        mainRectangle.treeView.expandTree()
                    }
                    Keys.onSpacePressed: {
                        mainRectangle.treeView.toggleDone()
                    }
                    Keys.onEnterPressed: mainRectangle.editCurrentItem()
                    Keys.onReturnPressed: mainRectangle.editCurrentItem()
                    Keys.onPressed: {
                        switch (event.key) {
                        case Qt.Key_C:
                            if (event.modifiers & Qt.ControlModifier) {
                                mainRectangle.confirmCleanDoneDialog.open()
                            }
                            break
                        case Qt.Key_D:
                            mainRectangle.confirmDeleteDialog.open()
                            break
                        case Qt.Key_H:
                            mainRectangle.treeView.currentLevel--
                            break
                        case Qt.Key_J:
                            if (mainRectangle.treeView.currentNodeListView.currentIndex < (mainRectangle.treeView.currentNodeListView.model.count - 1)) {
                                mainRectangle.treeView.currentNodeListView.currentIndex++
                                mainRectangle.treeView.expandTree()
                            }
                            break
                        case Qt.Key_K:
                            if (mainRectangle.treeView.currentNodeListView.currentIndex > 0) {
                                mainRectangle.treeView.currentNodeListView.currentIndex--
                                mainRectangle.treeView.expandTree()
                            }
                            break
                        case Qt.Key_L:
                            mainRectangle.treeView.currentLevel++
                            mainRectangle.treeView.expandTree()
                            break
                        case Qt.Key_S:
                            if (event.modifiers & Qt.ControlModifier) {
                                if (event.modifiers & Qt.ShiftModifier) {
                                    mainRectangle.confirmSyncSketchesToImapDialog.open()
                                } else {
                                    mainRectangle.confirmSyncToImapDialog.open()
                                }
                            }
                            break
                        case Qt.Key_Plus:
                        case Qt.Key_I:
                            mainRectangle.addItem()
                            break
                        }
                    }
                }
            }

            Rectangle {
                id: toolBar
                anchors {left: parent.left; right: parent.right; bottom: parent.bottom}
                height: qtodoToolBar.height * 1.2

                property int minWidth: qtodoToolBar.minWidth + resizeItem.width + 40

                color: "transparent"
        //        radius: parent.radius

                QToDoToolBar {
                    id: qtodoToolBar
                }
            }

            MainMenu {
                id: mainMenu

                anchors.bottomMargin: toolBar.height

                onClosed: toolBar.enabled = true
                onOpened: toolBar.enabled = false
            }

            EditToDoSheet {
                id: editToDoItem

                onClosed: {
                    mainRectangle.focus = true
                }
            }

        //    EditSketchSheet {
        //        id: editSketchItem
        //    }

            ImapAccountSettingsSheet {
                id: imapAccountSettings
            }
        }
    }
}
