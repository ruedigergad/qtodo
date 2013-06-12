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
//import Qt.labs.gestures 1.0
import "nodelisthelper.js" as NodeListHelper

Item {
    id: treeView
    anchors.fill: parent

    signal doubleClicked
    signal pressAndHold

    signal levelDecrement
    signal levelIncrement

    property string color: "white"
    property alias model: rootListView.model
    property Item currentNodeListView

    /*
     * Total number of currently opened ListViews.
     */
    property int listViewCount: 0
    /*
     * Level of the tree that is currently displayed starteting with 0
     * for the root level. Setting this property displays the set level
     * of the tree. Note that the view must exist and currentLevel must
     * be < listViewCount and >= 0.
     */
    property int currentLevel: 0
    property int previousLevel: 0

    /*
     * The following properties are intended to access the data shown
     * in the TreeView.
     */
    property Item currentItem: null
    property int currentIndex: -1
    property QtObject currentModel: null

    function addView(parentView) {
        console.log("Entering addView...")
        if(NodeListHelper.views.length < (currentLevel + 2) ){
            console.log("Creating new sub view...")
            var view = NodeListHelper.createNextView(parentView)
            NodeListHelper.views.push(view)
            listViewCount++
        }
    }

    function clearSubLists() {
        console.log("Entering clearSublists...")
        /*
         * If a leaf node is selected all sub lists need to be cleared.
         */
        for (var i = currentLevel + 1; i < NodeListHelper.views.length; i++) {
            NodeListHelper.views[i].destroy()
        }
        listViewCount = currentLevel + 1
        NodeListHelper.views.length = listViewCount
    }

    function expandTree() {
        console.log("Expanding tree...")
        if (currentIndex >= 0 &&
                currentItem.expandable &&
                ! currentNodeListView.model.rowCount() <= 0) {
            addView(currentNodeListView)
            treeView.updateSubView(currentNodeListView.model, currentIndex)
        }
    }

    function updateSubView(model, index) {
        console.log("Updating sub view for level: " + currentLevel)
        if (NodeListHelper.views.length >= currentLevel + 2) {
            /*
             * If we moved to a higher level and the selection is changed
             * we need to destroy all views that are now out of scope to
             * avoid old data being shown.
             * Note: Smaller numbers represent higher levels. The root level is 0.
             */
            console.log("Destroying obsolete views...")
            for (var i = currentLevel + 2; i < NodeListHelper.views.length; i++) {
                NodeListHelper.views[i].destroy()
            }
            listViewCount = currentLevel + 2
            NodeListHelper.views.length = listViewCount
        }
        /*
         * Clear the ListView selection before filling the new list. Else
         * we would mess up the TreeView selection (currentItem and Index)
         * as well. Besides, this would yield in an incorrectly displayed
         * highlight.
         */
        NodeListHelper.views[currentLevel+1].currentIndex = -1
        NodeListHelper.views[currentLevel+1].model.setParentFromSelection(model, index)
    }

    function toggleDone() {
        if (currentItem == null || currentItem.type !== "to-do") {
            return
        }

        if (currentItem.done) {
            currentModel.setAttribute(currentIndex, "done", "false")
        } else {
            currentModel.setAttribute(currentIndex, "done", "true")
        }
    }

    Component.onCompleted: {
        NodeListHelper.views.push(rootListView)
        listViewCount++
        currentIndex = rootListView.currentIndex
        currentModel = model
        if (rootListView.currentIndex >= 0) {
            currentItem = rootListView.currentItem
        }
    }

    onCurrentLevelChanged: {
        console.log("CurrentLevelChanged: " + currentLevel)

        if(currentLevel >= 0 && currentLevel < listViewCount){
            flickable.contentX = currentLevel * treeView.width
        } else if (currentLevel >= listViewCount) {
            console.log("Tried to exceed number of available levels.")
            currentLevel--
        } else {
            console.log("Invalid current level given: " + currentLevel)
            console.log("List view count is: " + listViewCount)
            currentLevel = 0
        }

        currentNodeListView = NodeListHelper.views[currentLevel]
        currentModel = currentNodeListView.model

        /*
         * Hack to properly update the selection when switching between levels.
         * We force "reselection" of the currentIndex by setting it to an
         * invalid value and re-set it back to the initial value.
         */
        var tempIndex = currentNodeListView.currentIndex
        currentNodeListView.currentIndex = -1
        currentNodeListView.currentIndex = tempIndex

        if (currentNodeListView.currentIndex >= 0) {
            currentItem = currentNodeListView.currentItem
        }

        if (previousLevel < currentLevel) {
            levelIncrement()
        } else if (previousLevel > currentLevel) {
            levelDecrement()
        }
        previousLevel = currentLevel
    }

    onLevelDecrement: {
        console.log("Level decremented...")
    }

    onLevelIncrement: {
        console.log("Level incremented...")
        expandTree()
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: listsItem.width

        flickableDirection: Flickable.HorizontalFlick

        /*
         * Disable flicking for now. There is some anoying issue that
         * selections are not correctly handled for about 0.8 - 1 seconds
         * when flicking back from a sub element view.
         * Set this to true to enable flicking.
         * PR 1.2 seems to have fixed this. :)
         */
        interactive: true

        pressDelay: 0
        boundsBehavior: Flickable.StopAtBounds
        property bool animationIsRunning: false
        Behavior on contentX {
            SequentialAnimation {
                PropertyAnimation { duration: 140 }
                ScriptAction { script: flickable.animationIsRunning = false }
            }
        }

        Item {
            id: listsItem
            width: treeView.width * listViewCount
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            NodeListView {
                id: rootListView
                width: treeView.width
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                Component.onCompleted: {
                    currentNodeListView = rootListView
                }
            }
        }

        onFlickStarted: {
            animationIsRunning = true
            if(horizontalVelocity > 0) {
                currentLevel = Math.min(++currentLevel, listViewCount)
            } else {
                currentLevel = Math.max(--currentLevel, 0)
            }
        }

        /*
         * If no flick was triggered (no animation is running) the list which
         * currently fills most of the screen (> 50% = 0.5) is moved to the center.
         * This is done to avoid stopping "in between" to lists.
         */
        onMovementEnded: {
            if(! animationIsRunning) {
                var newLevel = Math.floor((contentX + 0.5 * treeView.width) / treeView.width)
                if(currentLevel === newLevel){
                    contentX = currentLevel * treeView.width
                } else {
                    currentLevel = newLevel
                }
            }
        }
    }
}
