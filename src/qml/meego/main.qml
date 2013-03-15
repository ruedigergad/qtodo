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

    Page {
        id: mainPage
        tools: commonTools

        orientationLock: PageOrientation.LockPortrait

        MainRectangle {
            id: mainRectangle
        }
    }

    EditToDoSheet { id: editToDoSheet }

    EditSketchSheet { id: editSketchSheet }

    QToDoToolBar {
        id: commonTools
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
}
