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

var views = new Array();

function createNextView(parentView) {
    console.log("Creating sub view.");

    var viewString = "import QtQuick 2.0; import qtodo 1.0; "
        + "NodeListView { "
        + "id: nodeListView" + treeView.listViewCount + "; "
        + "level: " + treeView.listViewCount + "; "
        + "width: treeView.width; "
        + "anchors.left: parent.right; "
        + "anchors.top: parent.top; "
        + "anchors.bottom: parent.bottom; "
        + "model: NodeListModel { id: elementListModel"+ treeView.listViewCount + " } "
        + "}"

    console.log("Creating new view from string: " + viewString);
    console.log("Parent view: " + parentView);

    var view = Qt.createQmlObject(viewString, parentView);

    if(view === null){
        console.log("Error creating new view!");
        return;
    }

    console.log("View successfully created: " + view);
    return view;
}
