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
import "../common"

PageStackWindow {
    id: appWindow

    initialPage: mainPage

    property int primaryFontSize: 30
    property int primaryBorderSize: 20

    Page {
        id: mainPage
//        tools: commonTools

        orientationLock: PageOrientation.LockPortrait

        Rectangle {
            anchors.fill: parent
            color: "lightgoldenrodyellow"

            Header {
                id: header
            }

            MainRectangle {
                anchors{left: parent.left; right: parent.right; top: header.bottom; bottom: toolBarItem.top}

                id: mainRectangle
            }

            Rectangle {
                id: toolBarItem
                anchors {left: parent.left; right: parent.right; bottom: parent.bottom}
                height: commonTools.height * 1.25

                color: "white"
                radius: parent.radius

                QToDoToolBar {
                    id: commonTools
//                    width: parent.width

                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: - (height - parent.height) / 2
                }
            }

            EditToDoSheet {
                id: editToDoItem
                z: 64
                onClosed: {
                    mainRectangle.focus = true
                }
            }

            EditSketchSheet {
                id: editSketchItem
                z: 64
            }

            ImapAccountSettingsSheet {
                id: imapAccountSettings
                z: 64
            }
        }
    }

    QToDoMenu {
        id: mainMenu

        anchors.bottomMargin: toolBarItem.height

        onClosed: toolBarItem.enabled = true
        onOpened: toolBarItem.enabled = false

        CommonButton{
            id: cleanDone
            anchors.bottom: syncToImap.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Clean Done"
            onClicked: {
                mainRectangle.confirmCleanDoneDialog.open()
                mainMenu.close()
            }
        }

        CommonButton{
            id: syncToImap
            anchors.bottom: syncSketchesToImap.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Sync To-Do List"
            onClicked: {
                mainRectangle.confirmSyncToImapDialog.open()
                mainMenu.close()
            }
        }

        CommonButton{
            id: syncSketchesToImap
            anchors.bottom: syncAccountSettings.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Sync Sketches"
            onClicked: {
                mainRectangle.confirmSyncSketchesToImapDialog.open()
                mainMenu.close()
            }
        }

        CommonButton{
            id: syncAccountSettings
            anchors.bottom: about.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Sync Account Settings"
            onClicked: {
                imapAccountSettings.open()
                mainMenu.close()
            }
        }

        CommonButton{
            id: about
            anchors.bottom: parent.bottom
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "About"
            onClicked: {
                mainRectangle.aboutDialog.open()
                mainMenu.close()
            }
        }
    }

    QToDoMenu {
        id: contextMenu

        anchors.bottomMargin: toolBarItem.height

        onClosed: toolBarItem.enabled = true
        onOpened: toolBarItem.enabled = false

        CommonButton{
            id: moveToTopItem
            anchors.bottom: moveToBottomItem.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Move to Top"
            onClicked: {
                mainRectangle.moveCurrentItemToTop()
                contextMenu.close()
            }
        }

        CommonButton{
            id: moveToBottomItem
            anchors.bottom: editItem.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Move to Bottom"
            onClicked: {
                mainRectangle.moveCurrentItemToBottom()
                contextMenu.close()
            }
        }

        CommonButton{
            id: editItem
            anchors.bottom: deleteItem.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Edit"
            onClicked: {
                mainRectangle.editCurrentItem()
                contextMenu.close()
            }
        }

        CommonButton{
            id: deleteItem
            anchors.bottom: parent.bottom
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Delete"
            onClicked: {
                mainRectangle.deleteCurrentItem()
                contextMenu.close()
            }
        }
    }
}
