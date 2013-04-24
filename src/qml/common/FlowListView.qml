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
 *
 *  ###################
 *
 *  Note: The code of the FlowListView is additionally released under the terms
 *  of the GNU Lesser General Public License (LGPL) as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  File considered part of the FlowListView is this file, FlowListView.qml.
 *  This file is additionally licensed under the terms of the LGPL.
 *
 */

import QtQuick 1.1

CommonFlickable {
    id: flowListView
    anchors.fill: parent

    contentWidth: parent.width;
    contentHeight: flow.childrenRect.height

    clip: true

    property alias count: repeater.count
    property int currentIndex: -1
    property variant currentItem;
    property alias delegate: repeater.delegate
    property alias flow: flow.flow
    property alias model: repeater.model

    onCurrentIndexChanged: {
        // Note: in the "normal" FlowListView we do:
        // currentItem = model.get(currentIndex)
        // However, with our current model we need to do it as follows.
        // Note that we are "re-exposing" the model properties via properties
        // of our delegate.
        currentItem = repeater.itemAt(currentIndex)
    }

    Flow {
        id: flow
        width: parent.width

        Repeater {
            id: repeater

            onCountChanged: {
                if (flowListView.currentIndex === -1 && count > 0) {
                    flowListView.currentIndex = 0
                }
                if (flowListView.currentIndex >= count) {
                    flowListView.currentIndex = count - 1
                }
            }
        }
    }
}
