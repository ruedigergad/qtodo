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

Row {
    id: qtodoToolBar

    anchors {
        left: parent.left; leftMargin: primaryBorderSize * 0.25
        right: parent.right; rightMargin: primaryBorderSize * 0.25
        verticalCenter: parent.verticalCenter
    }
    height: iconAdd.height
    spacing: (qtodoToolBar.width - (6 * iconAdd.width)) / 5

    CommonToolIcon {
        id: iconAdd
        iconSource: "../icons/add.png"
        opacity: enabled ? 1 : 0.5
        onClicked: mainRectangle.addItem()
    }
    CommonToolIcon {
        id: iconSketch
        iconSource: "../icons/sketch.png"
        opacity: enabled ? 1 : 0.5
        onClicked: mainRectangle.addSketch()
    }
    CommonToolIcon {
        id: iconMarkDone
        iconSource: "../icons/to-do_done.png"
        enabled: mainRectangle.treeView.currentItem != null && mainRectangle.treeView.currentItem.type === "to-do"
        opacity: enabled ? 1 : 0.5
        onClicked: mainRectangle.treeView.toggleDone()
    }
    CommonToolIcon {
        id: iconDelete
        iconSource: "../icons/delete.png"
        enabled: mainRectangle.treeView.currentIndex >= 0
        opacity: enabled ? 1 : 0.5
        onClicked: mainRectangle.deleteCurrentItem()
    }
    CommonToolIcon {
        id: iconBack
        iconSource: "../icons/back.png"
        enabled: mainRectangle.treeView.currentLevel > 0
        opacity: enabled ? 1 : 0.5
        onClicked: mainRectangle.treeView.currentLevel--
    }
    CommonToolIcon {
        id: iconMenu
        iconSource: "../icons/menu.png"
        onClicked: ! mainMenu.isOpen ? mainMenu.open() : mainMenu.close()
        opacity: enabled ? 1 : 0.5
    }
}
