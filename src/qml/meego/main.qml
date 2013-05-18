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

    Page {
        id: mainPage
        tools: commonTools

        orientationLock: PageOrientation.LockPortrait

        Rectangle {
            anchors.fill: parent
            color: "lightgoldenrodyellow"

            Header {
                id: header
            }

            MainRectangle {
                anchors{left: parent.left; right: parent.right; top: header.bottom; bottom: parent.bottom}

                id: mainRectangle
            }
        }
    }

    EditToDoSheet { id: editToDoItem }

    EditSketchSheet { id: editSketchItem }

    QToDoToolBar {
        id: commonTools
    }

    ContextMenu {
        id: contextMenu

        onStatusChanged: {
            if (status === DialogStatus.Opening) {
                commonTools.enabled = false
            } else if (status === DialogStatus.Closed) {
                commonTools.enabled = true
            }
        }

        MenuLayout {
            MenuItem {
                text: "Move to Top"
                onClicked: mainRectangle.moveCurrentItemToTop()
            }
            MenuItem {
                text: "Move to Bottom"
                onClicked: mainRectangle.moveCurrentItemToBottom()
            }
            MenuItem {
                text: "Edit"
                onClicked: mainRectangle.editCurrentItem()
            }
            MenuItem {
                text: "Delete"
                onClicked: mainRectangle.deleteCurrentItem()
            }
        }
    }

    Menu {
        id: mainMenu

        visualParent: pageStack

        onStatusChanged: {
            if (status === DialogStatus.Opening) {
                commonTools.enabled = false
            } else if (status === DialogStatus.Closed) {
                commonTools.enabled = true
            }
        }

        MenuLayout {
            MenuItem {
                text: "Clean Done"
                onClicked: mainRectangle.confirmCleanDoneDialog.open()
            }
            MenuItem {
                text: "Sync To-Do List"
                onClicked: mainRectangle.confirmSyncToImapDialog.open()
            }
            MenuItem {
                text: "Sync Sketches"
                onClicked: mainRectangle.confirmSyncSketchesToImapDialog.open()
            }
            MenuItem {
                text: "Sync Account Settings"
                onClicked: imapAccountSettings.open()
            }
            MenuItem { 
                text: "About"
                onClicked: mainRectangle.aboutDialog.open()
            }
        }
    }

    ImapAccountSettingsSheet {
        id: imapAccountSettings
    }
}
