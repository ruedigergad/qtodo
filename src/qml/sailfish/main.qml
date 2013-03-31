/*
 *  Copyright 2013 Ruediger Gad
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
import qtodo 1.0
import "../common"


ApplicationWindow {
    id: appWindow

    initialPage: mainPage

    Page {
        id: mainPage

//        PageHeader {
//            id: pageHeader
//            title: "My ToDos"
//        }

        MainRectangle {
            id: mainRectangle
            anchors.fill: parent
//            anchors {left: parent.left; right: parent.right; top: pageHeader.bottom; bottom: parent.bottom}
        }
    }

    EditToDoDialog {
        id: editToDoItem
    }

//    Connections {
//        target: mainRectangle.treeView

//        onCurrentLevelChanged: {
//            pageStack.depth = mainRectangle.treeView.currentLevel + 2
//        }
//    }

//    Component.onCompleted: {
//        pageStack.depth = 2
//    }
}
