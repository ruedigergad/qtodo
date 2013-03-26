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

import QtQuick 1.1
import "../common"

Rectangle {
    id: main

    anchors.fill: parent
    color: "white"

    Rectangle {
        anchors {top: parent.top; left: parent.left; right: parent.right; bottom: toolBarItem.top}
        color: "lightgoldenrodyellow"

        Rectangle {
            id: header
            height: 72
            color: "#00b000" //#0c61a8"
            anchors{left: parent.left; right: parent.right; top: parent.top}
            z: 48

            Text {
                text: "My To-Dos"
                color: "#ffffff"
                font{pixelSize: 32; family: "Nokia Pure Text Light"}
                anchors{left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter}
            }
        }

        MainRectangle {
            anchors{left: parent.left; right: parent.right; top: header.bottom; bottom: parent.bottom}

            id: mainRectangle
        }
    }

    Rectangle {
        id: toolBarItem
        anchors {left: parent.left; right: parent.right; bottom: parent.bottom}
        height: toolBar.height

        QToDoToolBar {
            id: toolBar
        }
    }

    Menu {
        id: myMenu
    }

    EditToDoSheet {
        id: editToDoSheet
    }
}
