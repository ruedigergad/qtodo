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
 *  ###################
 *
 *  Note: The code of the TreeView is additionally released under the terms
 *  of the GNU Lesser General Public License (LGPL) as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  Files considered part of the TreeView are: TreeView.qml, NodeListView.qml,
 *  and nodelisthelper.js. These files are additionally licensed under the
 *  terms of the LGPL.
 *
 */

import QtQuick 2.0

Item {
    id: nodeListDelegate

    property alias nextButtonBackgroundColor: nextButtonRectangle.color
    property alias nextButtonIcon: nextIcon.source
    property alias textColor: textDelegate.color

    signal clicked
    signal doubleClicked
    signal pressAndHold

    width: tagName === "sketch" ? sketchContentDelegate.width : _nodeListViewLV.width
    height: tagName === "sketch" ? sketchContentDelegate.height : textContentDelegate.height

    /*
     * Begin of custom code to display the data. Here the Q To-Do to-do or
     * note elements are shown. Customize this to display your own stuff.
     */
    Item {
        id: sketchContentDelegate
        anchors.left: parent.left
        visible: tagName === "sketch"
        height: imgExists ? sketchImage.height : width
        width: _nodeListViewLV.width * 0.5

        property string imgSource: tagName === "sketch" ? mainRectangle._sketchPath + "/" + elementText : ""
        property bool imgExists: fileHelper.exists(imgSource)

        Image {
            id: sketchImage
            fillMode: Image.PreserveAspectFit
            cache: false
            source: parent.imgSource
            height: sourceSize.height * (parent.width / sourceSize.width)
            width: parent.width
            visible: parent.imgExists
        }

        Item {
            id: noImageFoundText
            anchors.fill: parent
            visible: ! parent.imgExists

            Text {
                anchors.centerIn: parent
                width: parent.width
                text: "Image not synced yet."

                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font.pointSize: primaryFontSize
                color: "gray"
            }
        }

        MouseArea {
            anchors.fill: parent

            onClicked: {
                if (! isSelected()) {
                    selectItem()
                    nodeListDelegate.clicked()
                }
            }
            onDoubleClicked: {
                selectItem()
                nodeListDelegate.doubleClicked()
                treeView.doubleClicked()
            }
            onPressAndHold: {
                selectItem()
                nodeListDelegate.pressAndHold()
                treeView.pressAndHold()
            }
        }
    }

    Item {
        id: textContentDelegate
        anchors.left: parent.left
        anchors.right: nextButton.left
        height: textDelegate.height

        visible: tagName !== "sketch"

        Image {
            id: elementIcon
            height: textDelegate.font.pixelSize
            width: height
            fillMode: Image.PreserveAspectFit
            anchors.verticalCenter: parent.verticalCenter
            smooth: true
            source: tagName === "to-do"
                    ? "../icons/to-do_" + (isDone ? "done_" : "") + elementColor + ".png"
                    : "../icons/note.png"

            MouseArea {
                anchors.fill: parent
                preventStealing: true

                onClicked: {
                    selectItem()
                    treeView.toggleDone()
                }
            }
        }

        Item {
            id: textItem
            anchors.left: elementIcon.right
            anchors.right: parent.right
            height: textDelegate.height

            Rectangle {
                id: progressBar
                anchors.left: parent.left
                height: parent.height
                width: {
                    return (displayedProgress > 0) && (displayedProgress <= 1) ?
                                displayedProgress * parent.width :
                                0
                }
                color: "#00cc00"
                opacity: 0.6
            }

            Rectangle {
                id: workLeft
                anchors.left: progressBar.right
                anchors.right: parent.right
                height: parent.height
                color: getColor(itemColor)
                opacity: 0.2
            }

            Text {
                id: textDelegate
                anchors.left: parent.left
                anchors.leftMargin: 2
                anchors.right: parent.right

                text: elementText
                font.pointSize: primaryFontSize * 0.75
                horizontalAlignment: Text.AlignHLeft
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                color: "black"
            }

            MouseArea {
                id: textItemMouseArea
                anchors.fill: parent
                onClicked: {
                    if (! isSelected()) {
                        mouse.accepted = true
                        selectItem()
                        nodeListDelegate.clicked()
                    }
                }
                onDoubleClicked: {
                    mouse.accepted = true
                    selectItem()
                    nodeListDelegate.doubleClicked()
                    treeView.doubleClicked()
                }
                onPressAndHold: {
                    mouse.accepted = true
                    selectItem()
                    nodeListDelegate.pressAndHold()
                    treeView.pressAndHold()
                }
            }
        }
    }
    /*
     * End of custom code for displaying the data.
     */

    Item {
        id: nextButton
        anchors.right: parent.right
        width: (! isExpandable) ? 0 : nextButtonRectangle.width * 1.2
        height: parent.height

        Rectangle{
            id: nextButtonRectangle

            anchors.centerIn: parent
            color: "gray"
            height: textDelegate.font.pixelSize
            opacity: nextMouseArea.pressed ? 1 : 0.6
            width: height

            visible: isExpandable

//            radius: width / 3

            Image {
                id: nextIcon
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                smooth: true
                opacity: (isLeaf) ? 0.3 : 1
                source: "../icons/next.png"
            }

            MouseArea {
                id: nextMouseArea
                anchors.fill: parent

                onClicked: {
                    selectItem()
                    treeView.currentLevel++
                }
            }
        }
    }

    Rectangle {
        id: clickHighlight
        anchors.fill: parent
        color: "black"
//        radius: 10
        opacity: textItemMouseArea.pressed ? 0.3 : 0
    }

    Rectangle {
        id: highlight
        anchors.fill: parent
        color: "gray"
        opacity: _nodeListViewLV.currentIndex === index ? 0.5 : 0
    }
}
