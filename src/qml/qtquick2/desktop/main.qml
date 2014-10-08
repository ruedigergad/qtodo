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

    height: 400
    width: 300

    color: "white"
    opacity: 1
//    radius: primaryFontSize * 0.5

    property int primaryFontSize: 20
    property int primaryBorderSize: 20
    property int secondaryFontSize: 14
    property int secondaryBorderSize: 16

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

//            radius: parent.radius
//            textColor: applicationWindow.windowFocus ? "white" : "black"
            textColor: "white"

            /*
             * Thanks to alexisdm
             * http://stackoverflow.com/questions/10203260/moving-the-window-on-holding-qml-mousearea
             * for the hint on how to move the application window via QML
             */
            MouseArea {
                anchors.fill: parent
                property variant previousPosition

                onPressed: {
                    previousPosition = Qt.point(mouseX, mouseY)
                }

                onPositionChanged: {
                    if (pressedButtons == Qt.LeftButton) {
                        var dx = mouseX - previousPosition.x
                        var dy = mouseY - previousPosition.y
//                        applicationWindow.pos = Qt.point(applicationWindow.pos.x + dx,
//                                                    applicationWindow.pos.y + dy)
                    }
                }
            }

//            Text {
//                anchors.right: closeText.left
//                anchors.rightMargin: primaryFontSize - (primaryFontSize / 2)
//                anchors.verticalCenter: parent.verticalCenter

//                text: "-"
//                font.pointSize: primaryFontSize * 1.5
//                color: "white"

//                MouseArea {
//                    anchors.fill: parent
//                    onClicked: {
//                        trayIcon.toggleViewHide()
//                    }
//                }
//            }

//            Text {
//                id: closeText

//                anchors.right: parent.right
//                anchors.rightMargin: primaryFontSize - (primaryFontSize / 2)
//                anchors.verticalCenter: parent.verticalCenter

//                text: "x"
//                font.pointSize: primaryFontSize * 0.75
//                color: "white"

//                MouseArea {
//                    anchors.fill: parent
//                    onClicked: {
//                        Qt.quit()
//                    }
//                }
//            }
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

//        property int minWidth: qtodoToolBar.minWidth + resizeItem.width + 40

        color: "white"
//        radius: parent.radius

        QToDoToolBar {
            id: qtodoToolBar
        }

//        Text {
//            id: resizeItem
//            anchors.right: parent.right
//            anchors.rightMargin: 10
//            anchors.verticalCenter: parent.verticalCenter

//            font.bold: true
//            font.pointSize: primaryFontSize * 0.75
//            text: "o"

//            MouseArea {
//                anchors.fill: parent
//                property variant previousPosition

//                onPressed: {
//                    previousPosition = Qt.point(mouseX, mouseY)
//                }

//                onPositionChanged: {
//                    if (pressedButtons == Qt.LeftButton) {
//                        var dx = mouseX - previousPosition.x
//                        var dy = mouseY - previousPosition.y

////                        var newWidth = applicationWindow.size.width + dx

////                        applicationWindow.size = Qt.size(newWidth < toolBar.minWidth ? toolBar.minWidth : newWidth,
////                                                    applicationWindow.size.height + dy)
//                    }
//                }
//            }
//        }
    }

    MainMenu {
        id: mainMenu

        menuBottomOffset: toolBar.height

        onClosed: toolBar.enabled = true
        onOpening: toolBar.enabled = false
    }

//    Menu {
//        id: contextMenu

//        anchors.bottomMargin: toolBar.height

//        onClosed: toolBar.enabled = true
//        onOpened: toolBar.enabled = false

//        CommonButton{
//            id: moveToTopItem
//            anchors.bottom: moveToBottomItem.top
//            anchors.bottomMargin: primaryFontSize / 3
//            anchors.horizontalCenter: parent.horizontalCenter
//            width: parent.width - primaryFontSize
//            text: "Move to Top"
//            onClicked: {
//                mainRectangle.moveCurrentItemToTop()
//                contextMenu.close()
//            }
//        }

//        CommonButton{
//            id: moveToBottomItem
//            anchors.bottom: editItem.top
//            anchors.bottomMargin: primaryFontSize / 3
//            anchors.horizontalCenter: parent.horizontalCenter
//            width: parent.width - primaryFontSize
//            text: "Move to Bottom"
//            onClicked: {
//                mainRectangle.moveCurrentItemToBottom()
//                contextMenu.close()
//            }
//        }

//        CommonButton{
//            id: editItem
//            anchors.bottom: deleteItem.top
//            anchors.bottomMargin: primaryFontSize / 3
//            anchors.horizontalCenter: parent.horizontalCenter
//            width: parent.width - primaryFontSize
//            text: "Edit"
//            onClicked: {
//                mainRectangle.editCurrentItem()
//                contextMenu.close()
//            }
//        }

//        CommonButton{
//            id: deleteItem
//            anchors.bottom: parent.bottom
//            anchors.bottomMargin: primaryFontSize / 3
//            anchors.horizontalCenter: parent.horizontalCenter
//            width: parent.width - primaryFontSize
//            text: "Delete"
//            onClicked: {
//                mainRectangle.deleteCurrentItem()
//                contextMenu.close()
//            }
//        }
//    }

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
