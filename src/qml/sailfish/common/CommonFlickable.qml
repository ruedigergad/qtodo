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

import Sailfish.Silica 1.0
import QtQuick 1.1

SilicaFlickable {
    id: commonFlickable

    PullDownMenu {
        spacing: theme.paddingLarge

        MenuItem {
            text: "Sync to IMAP"
        }

        MenuItem {
            text: "Add"
        }
    }

    PushUpMenu {
        spacing: theme.paddingLarge

        MenuItem {
            text: "Add"
        }

        MenuItem {
            text: "Sync to IMAP"
        }

        MenuItem {
            text: "Return to Top"
            onClicked: commonFlickable.scrollToTop()
        }
    }
}
