/*
 *  Copyright 2012 Ruediger Gad
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
import qmlcanvas 1.0
import "../common"

Sheet{
    id: editSketchSheet
    anchors.fill: parent
    visualParent: mainPage

    property bool edit: false
    property string sketchPath: ""

    onStatusChanged: {
        if (status === DialogStatus.Opening){
            commonTools.enabled = false

            if (edit) {
                drawing.load(sketchPath)
            } else {
                drawing.init()
            }

            blackButton.checked = true
            drawing.drawColor = "black"
        }else if (status === DialogStatus.Closed){
            commonTools.enabled = true
        }
    }

    acceptButtonText: "OK"
    rejectButtonText: "Cancel"

    content: Item {
        anchors.fill: parent

        ButtonRow {
            id: colorButtonRow
            anchors{top: parent.top; left: parent.left; right: parent.right}

            Button {
                id: blackButton
                iconSource: "../icons/sketch_black.png"
                onClicked: drawing.drawColor = "black"
            }
            Button {
                iconSource: "../icons/sketch_blue.png"
                onClicked: drawing.drawColor = "blue"
            }
            Button {
                iconSource: "../icons/sketch_green.png"
                onClicked: drawing.drawColor = "green"
            }
            Button {
                iconSource: "../icons/sketch_yellow.png"
                onClicked: drawing.drawColor = "yellow"
            }
            Button {
                iconSource: "../icons/sketch_red.png"
                onClicked: drawing.drawColor = "red"
            }
            Button {
                iconSource: "../icons/sketch_erase.png"
                onClicked: drawing.drawColor = drawing.backgroundColor
            }
        }

        Drawing {
            id: drawing
            anchors{top: colorButtonRow.bottom; left: parent.left; right: parent.right; bottom: parent.bottom}
            backgroundColor: mainRectangle.color
            lineWidth: (drawColor === backgroundColor) ? 35 : 3
        }
    }

    onAccepted: {
        console.log("Saving sketch to: " + sketchPath)

        drawing.save(sketchPath)

        if (edit) {
            mainRectangle.treeView.currentModel.updateElement(mainRectangle.treeView.currentIndex, "sketch", sketchPath, "na")
        } else {
            mainRectangle.treeView.currentModel.addElement("sketch", sketchPath, "na")
        }

        editSketchSheet.close();
    }

    onRejected: editSketchSheet.close();
}

