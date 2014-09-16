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

Item {
    id: menu

    property int menuBottomOffset: menu.height
    /*
     * The following is a quite ugly hack to animate the menu.
     * This should be done via States rather than this hack.
     * Though, due to the limited time, for now this hack is used.
     */
    property bool isOpen: false
    property bool isOpening: false

    signal closed
    signal closing
    signal opened
    signal opening

    function close() {
        closing()
        isOpening = false
        menuBorder.height = 0
    }

    function open() {
        opening()
        isOpening = true
        enabled = true
        menuBorder.height = menuArea.height
    }

    onClosing: {background.opacity = 0}
    onOpening: {background.opacity = 0.75}

    anchors.fill: parent
    enabled: false
    visible: enabled
    z: 16

    Rectangle {
        id: background

        anchors.fill: parent
        color: "black"
        opacity: 0

        Behavior on opacity {
            SequentialAnimation {
                PropertyAnimation { duration: secondaryAnimationDuration }
            }
        }
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            close();
        }
    }

    Flickable {
        id: menuBorder

        anchors.bottom: parent.bottom
        anchors.bottomMargin: menu.menuBottomOffset

        clip: true
        contentHeight: menuArea.height
        opacity: secondaryBackgroundOpacity

        height: 0
        width: parent.width
        z: parent.z + 1

        Behavior on height {
            SequentialAnimation {
                PropertyAnimation { duration: secondaryAnimationDuration }
                ScriptAction {
                    script: {
                        if (menu.isOpening) {
                            menu.isOpen = true
                            menu.opened()
                        } else {
                            menu.isOpen = false
                            menu.enabled = false
                            menu.closed()
                        }
                    }
                }
            }
        }

        Item {
            id: menuArea

            anchors.centerIn: parent
            height: about.height * 5 + primaryFontSize / 3 * 6
            width: parent.width
            y: parent.y


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
    }
}
