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
 */

import Sailfish.Silica 1.0
import QtQuick 1.1

SilicaFlickable {
    id: commonFlickable

    clip: true

    PullDownMenu {
        spacing: theme.paddingLarge

        MenuItem {
            text: "New Item"
            onClicked: mainRectangle.addItem()
        }

        MenuItem {
            text: "New Sketch"
        }

        MenuItem {
            text: "Clean Done"
            onClicked: mainRectangle.confirmCleanDoneDialog.open()
        }

        MenuItem {
            text: "Sync to IMAP"
            onClicked: mainRectangle.confirmSyncToImapDialog.open()
        }

        MenuItem {
            text: "About"
            onClicked: mainRectangle.aboutDialog.open()
        }
    }

    PushUpMenu {
        spacing: theme.paddingLarge

        MenuItem {
            text: "New Item"
            onClicked: mainRectangle.addItem()
        }

        MenuItem {
            text: "New Sketch"
        }

        MenuItem {
            text: "Clean Done"
            onClicked: mainRectangle.confirmCleanDoneDialog.open()
        }

        MenuItem {
            text: "Sync to IMAP"
            onClicked: mainRectangle.confirmSyncToImapDialog.open()
        }

        MenuItem {
            text: "About"
            onClicked: mainRectangle.aboutDialog.open()
        }

        MenuItem {
            text: "Return to Top"
            onClicked: commonFlickable.scrollToTop()
        }
    }
}
