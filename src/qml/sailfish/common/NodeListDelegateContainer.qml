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
 */

import QtQuick 1.1
import Sailfish.Silica 1.0

Item {
    id: nodeListDelegateContainer
    width: nodeListDelegate.width

    property Item contextMenu: null
    property bool menuOpen: contextMenu != null && contextMenu.parent === nodeListDelegateContainer

    height: menuOpen ? contextMenu.height + nodeListDelegate.height : nodeListDelegate.height

    NodeListDelegate {
        id: nodeListDelegate

        textColor: theme.primaryColor

        onPressAndHold: {
            if (!contextMenu)
                contextMenu = contextMenuComponent.createObject(nodeListView)
            contextMenu.show(nodeListDelegateContainer)
        }
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
                onClicked: mainRectangle.editCurrentItem()
            }
            MenuItem {
                text: "New Entry"
                onClicked: mainRectangle.addItem()
            }
            MenuItem {
                text: "New Sketch"
                onClicked: menu.parent.remove()
            }
            MenuItem {
                text: "Delete"
                onClicked: mainRectangle.deleteCurrentItem()
            }
        }
    }
}
