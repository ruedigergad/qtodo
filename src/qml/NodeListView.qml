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

import QtQuick 1.1

Item{
    id: nodeListItem

    property alias model: nodeListView.model
    property alias currentIndex: nodeListView.currentIndex
    property alias currentItem: nodeListView.currentItem

    signal countChanged(int count)
    signal expandTree()
    signal leafNodeSelected()

    function getColor(colorString){
        if(colorString === "blue")
            return "#2c81c8"
        if(colorString === "green")
            return "#008000"
        if(colorString === "yellow")
            return "#d6d600"
        if(colorString === "red")
            return "#c20000"

        return "#00ff00"
    }

    function updateLabels(){
        var listEmpty = (nodeListView.model.rowCount() <= 0)
        emptyListRectangle.visible = listEmpty
    }

    onExpandTree: {
        treeView.addView(nodeListItem)
        treeView.updateSubView(model, currentIndex)
    }

    onLeafNodeSelected: {
        treeView.clearSubLists()
    }

    Rectangle{
        id: emptyListRectangle
        anchors.fill: parent
        color: treeView.color

        Text {
            id: noContentLabel
            text: "No entries yet"
            font.pixelSize: 60; anchors.bottom: explanationLabel.top; anchors.bottomMargin: 50; anchors.horizontalCenter: parent.horizontalCenter
            color: "gray"
        }

        Text {
            id: explanationLabel
            text: "Use + to add entries."
            font.pixelSize: 40
            color: "gray"
            anchors.centerIn: parent
        }
    }

    PinchArea{
        id: dndArea
        anchors.fill: parent

        property real lastPosition: 0
        property real moveDelta: 40

        onPinchStarted: lastPosition = pinch.startPoint2.y

        onPinchUpdated: {
            var currentPosition = pinch.point2.y

            if(currentPosition === pinch.point1.y)
                return

            if(lastPosition - currentPosition > moveDelta){
                lastPosition = currentPosition
                moveItem(nodeListView.currentIndex - 1)
            }else if (lastPosition - currentPosition < -moveDelta){
                lastPosition = currentPosition
                moveItem(nodeListView.currentIndex + 1)
            }
        }

        onPinchFinished: storage.save()

        function moveItem(targetIndex){
            if(targetIndex >= 0 && targetIndex < nodeListView.count){
                nodeListView.model.move(nodeListView.currentIndex, targetIndex, 1)
                nodeListView.currentIndex = targetIndex
            }
        }
    }

    ListView{
        id: nodeListView
        anchors.fill: parent

        onCountChanged: {
            nodeListItem.countChanged(count)
            updateLabels()
        }

        onCurrentIndexChanged: {
            /*
             * Only update the TreeView current item and index if there had actually a
             * valid item been selected. An index of -1 is used to clear the selection
             * of the ListView from the TreeView. Hence, we do not want this change
             * to propagate back to the TreeView.
             */
            if(currentIndex >= 0){
                treeView.currentItem = currentItem
                treeView.currentIndex = currentIndex
                updateLabels()
            }
        }

        delegate: Item {
            id: delegateItem
            height: delegateRectangle.height
            width: parent.width
            
            /*
             * These properties are used to access the item properties/data of
             * the current item as returned via the ListView currentItem property.
             * Customize this as needed for your purpose.
             */
            property string text: elementText
            property string type: tagName
            property string itemColor: elementColor
            property bool done: isDone
            property double progress: elementProgress

            property double displayedProgress: getProgress()

            function selectItem() {
                currentIndex = index
                if(isExpandable){
                    expandTree()
                }else{
                    leafNodeSelected()
                }
            }

            function getProgress() {
                if (done)
                    return 1
                if(progress >= 0)
                    return progress

                var idx = treeView.currentLevel == 0 ? index : index + 1
                var nTodos = treeView.currentModel.countSubTodos(idx, false, true)
                var notDone = treeView.currentModel.countSubTodos(idx, true, true)

                if (nTodos <= 0)
                    return 0

                return (1 - (notDone / nTodos))
            }

            Item {
                id: delegateRectangle
                width: tagName === "sketch" ? sketchContentDelegate.width : parent.width
                height: tagName === "sketch" ? sketchContentDelegate.height : textContentDelegate.height 

                /*
                 * Begin of custom code to display the data. Here the Q To-Do to-do or
                 * note elements are shown. Customize this to display your own stuff.
                 */
                Item {
                    id: sketchContentDelegate
                    anchors.left: parent.left
                    visible: tagName === "sketch"
                    height: sketchImage.height
                    width: sketchImage.width

                    Image {
                        id: sketchImage
                        fillMode: Image.PreserveAspectFit
                        cache: false
                        source: tagName === "sketch" ? elementText : ""
                        height: sourceSize.height * 0.5
                        width: sourceSize.width * 0.5
                    }
                }

                Item {
                    id: textContentDelegate
                    anchors.left: parent.left
                    anchors.right: nextButton.left
                    height: elementIcon.height

                    visible: tagName !== "sketch"

                    Image {
                        id: elementIcon
                        height: textDelegate.height
                        fillMode: Image.PreserveAspectFit
                        source: tagName === "to-do"
                                ? "../icons/to-do_" + (isDone ? "done_" : "") + elementColor + ".png"
                                : "../icons/note.png"
                    }

                    Item {
                        id: textRectangle
                        anchors.left: elementIcon.right
                        anchors.right: parent.right
                        height: textDelegate.height

                        Rectangle {
                            id: progressBar
                            anchors.left: parent.left
                            height: parent.height
                            width: displayedProgress * parent.width
                            color: "#aaaaaa"
//                            opacity: 0.2
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
                            width: parent.width

                            text: elementText
                            font.pixelSize: 28
                            horizontalAlignment: Text.AlignHLeft
                            wrapMode: Text.WordWrap
                            color: "black"
                        }
                    }
                }
                /*
                 * End of custom code for displaying the data.
                 */

                MouseArea{
                    id: contentMouseArea
                    anchors.fill: parent
                    onClicked: selectItem()
                    onDoubleClicked: {
                        selectItem()
                        treeView.doubleClicked()
                    }
                    onPressAndHold: {
                        selectItem()
                        treeView.pressAndHold()
                    }
                }

                Item {
                    id: nextButton
                    anchors.right: parent.right
                    width: (! isExpandable) ? 0 : 40
                    height: parent.height

                    Rectangle{
                        id: button
                        anchors.centerIn: parent
                        width: 30
                        height: 30

                        visible: isExpandable

                        radius: 10
                        color: nextMouseArea.pressed ? "gray" : "lightgray"

                        Image {
                            id: nextIcon
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit

                            opacity: (isLeaf) ? 0.3 : 1
                            source: "../icons/next.png"
                        }

                        MouseArea{
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
                    radius: 10
                    opacity: contentMouseArea.pressed ? 0.3 : 0
                }
            }
        }

        highlightMoveDuration: 200
        highlightResizeDuration: highlightMoveDuration
        highlight: Rectangle {
            id: highlightRectangle
            color: "gray"
            width: parent.width
            /*
             * Set z to a seemingly insane high value. For some strange/unknown reason the
             * the highlight is not shown at all with z=0. For z=1 the highligh is shown but
             * disappears for parts that had been at least once out of the screen bounds
             * (i.e. had not been visible in the list). Hence, just in case set z=32.
             */
            z:32
            opacity: 0.4
        }
    }
}
