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
import "common"

Rectangle {
    id: main

    color: "white"
    opacity: 1

    property int primaryFontSize: 30
    property int primaryBorderSize: 30
    property int secondaryFontSize: 20
    property int secondaryBorderSize: 20

    property string primaryFontColor: "black"
    property string secondaryFontColor: "black"

    property string primaryBackgroundColor: "white"
    property double primaryBackgroundOpacity: 1
    property string secondaryBackgroundColor: "lightgray"
    property double secondaryBackgroundOpacity: 1

    property string primaryColorSchemeColor: "#00b000"
    property double primaryColorSchemeOpacity: 1
    property string secondaryColorSchemeColor: "#00f000"
    property double secondaryColorSchemeOpacity: 1
    property string tertiaryColorSchemeColor: "#00c000"
    property double tertiaryColorSchemeOpacity: 1

    property int primaryAnimationDuration: 250
    property int secondaryAnimationDuration: 120

    property double disabledStateOpacity: 0.3

    Rectangle {
        anchors {top: parent.top; left: parent.left; right: parent.right; bottom: toolBar.top}
        color: "lightgoldenrodyellow"

        radius: parent.radius

        Header {
            id: header

            textColor: "white"
        }

        MainRectangle {
            id: mainRectangle
            anchors{left: parent.left; right: parent.right; top: header.bottom; bottom: parent.bottom}
            focus: true

            Timer {
                id: deferredExpandTreeTimer

                interval: 50
                onTriggered: mainRectangle.treeView.expandTree()
            }

            Keys.onDownPressed:{
                if (mainRectangle.treeView.currentNodeListView.currentIndex < (mainRectangle.treeView.currentNodeListView.model.count - 1)) {
                    mainRectangle.treeView.currentNodeListView.currentIndex++
                    if (! event.isAutoRepeat) {
                        mainRectangle.treeView.expandTree()
                    } else {
                        deferredExpandTreeTimer.restart()
                    }
                }
            }
            Keys.onUpPressed: {
                if (mainRectangle.treeView.currentNodeListView.currentIndex > 0) {
                    mainRectangle.treeView.currentNodeListView.currentIndex--
                    if (! event.isAutoRepeat) {
                        mainRectangle.treeView.expandTree()
                    } else {
                        deferredExpandTreeTimer.restart()
                    }
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
        height: qtodoToolBar.height + secondaryBorderSize * 0.5

        color: "white"

        QToDoToolBar {
            id: qtodoToolBar
        }
    }

    MainMenu {
        id: mainMenu

        menuBottomOffset: toolBar.height

        onClosed: toolBar.enabled = true
        onOpening: toolBar.enabled = false
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

//    ImapAccountSettingsSheet {
//        id: imapAccountSettings
//    }
}
