/*
 *  Copyright 2011, 2012, 2013 Ruediger Gad
 *
 *  This file is part of Q To-Do..
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
 *  along with Q To-Do. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 1.1

CommonDialog {
    id: aboutDialog

    content: Item {
        anchors.fill: parent

        Text {
            id: homepage
            text: "<a href=\"http://ruedigergad.github.com/qtodo\" style=\"text-decoration:none; color:#00b000\">Q To-Do<br /><img src=\"../icons/logo.png\" /></a>"
            textFormat: Text.RichText;
            onLinkActivated: { Qt.openUrlExternally(link); }
            font.pointSize: primaryFontSize * 0.75
            horizontalAlignment: Text.AlignHCenter;
            anchors {horizontalCenter: parent.horizontalCenter; bottom: version.top; bottomMargin: primaryFontSize / 4}
        }

        Text {
            id: version
            text: "Version 1.12.2"
            font.pointSize: primaryFontSize * 0.75
            horizontalAlignment: Text.AlignHCenter;
            anchors.centerIn: parent
            color: "lightgray"
        }

        Text {
            id: description
            text: "A Simple To-Do List Organizer"
            font.pointSize: primaryFontSize * 0.6
            font.bold: true;
            anchors {top: version.bottom; topMargin: primaryFontSize / 4; horizontalCenter: parent.horizontalCenter}
            color: "white"
        }

        Text {
            id: author;
            text: "Author: <br />"
                  + "Ruediger Gad - <a href=\"mailto:r.c.g@gmx.de\" style=\"text-decoration:none; color:#00b000\" >r.c.g@gmx.de</a><br />"
            textFormat: Text.RichText;
            onLinkActivated: { Qt.openUrlExternally(link); }
            anchors.horizontalCenter: parent.horizontalCenter; anchors.top: description.bottom; anchors.topMargin: primaryFontSize / 2
            font.pointSize: primaryFontSize * 0.5; color: "lightgray"; horizontalAlignment: Text.AlignHCenter
        }

        Text {
            id: license
            text: "Q To-Do is free software: you can redistribute it and/or modify "
                  + "it under the terms of the <a href=\"http://www.gnu.org/licenses\" style=\"text-decoration:none; color:#00b000\" >GNU General Public License</a> as published by "
                  + "the Free Software Foundation, either version 3 of the License, or "
                  + "(at your option) any later version.";
            textFormat: Text.RichText;
            onLinkActivated: { Qt.openUrlExternally(link); }
            font.pointSize: primaryFontSize * 0.5;
            anchors.horizontalCenter: parent.horizontalCenter;
            anchors.top: author.bottom;
            anchors.topMargin: primaryFontSize / 4;
            width: parent.width;
            color: "lightgray";
            horizontalAlignment: Text.AlignHCenter;
            wrapMode: Text.Wrap
        }
    }
}
