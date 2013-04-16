/*
 *  Copyright 2013 Ruediger Gad
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
import qtodo 1.0

Item {
    id: syncToImapItem

    property string imapFolderName: ""
    property string imapMessageSubject: "[QTODO] SimpleSync"
    property QtObject merger
    property bool useBuiltInDialogs: true

    property int _imapAccountId: -1
    property int _imapMessageId: -1
    property string _imapSyncFile: ""

    signal succeeded
    signal progress

    function startSync() {
        if (imapFolderName === "") {
            console.log("Error: imapFolderName not set. Stopping sync.")
            return
        }
        //TODO: Add check if merger was set.

        _imapAccountId = -1
        _imapMessageId = -1
        _imapSyncFile = ""

        if (useBuiltInDialogs) {
            _syncToImapProgressDialog.currentValue = 0
            _syncToImapProgressDialog.open()
        }

        _syncToImap()
    }

    function _syncToImap() {
        var accIds = _imapStorage.queryImapAccounts()
        console.log("Found " + accIds.length + " IMAP account(s).")

        progress()

        if (accIds.length === 1) {
            console.log("Found a single IMAP account. Using this for syncing.")
            console.log("IMAP account id is: " + accIds[0])
            _imapAccountId = accIds[0]
            _imapStorage.retrieveFolderList(_imapAccountId)
        } else if (accIds.length === 0) {
            _syncToImapProgressDialog.close()
            _messageDialog.title = "No IMAP Account"
            _messageDialog.message = "Please set up an IMAP e-mail account for syncing."
            _messageDialog.open()
        } else if (accIds.length > 1) {
            _syncToImapProgressDialog.close()
            _messageDialog.title = "Multiple IMAP Accounts"
            _messageDialog.message = "Functionality for choosing from different IMAP accounts still needs to be implemented."
            _messageDialog.open()
        } else {
            _syncToImapProgressDialog.close()
            _messageDialog.title = "Unexpected Error"
            _messageDialog.message = "Querying for IMAP accounts returned an unexpected value."
            _messageDialog.open()
        }
    }

    function _prepareImapFolder() {
        progress()

        if (! _imapStorage.folderExists(_imapAccountId, imapFolderName)) {
            console.log("Creating folder...")
            _imapStorage.createFolder(_imapAccountId, imapFolderName)
        } else {
            _processImapFolder()
        }
    }

    function _processImapFolder() {
        console.log("Processing content of IMAP folder...")
        progress()

        if (! _imapStorage.folderExists(_imapAccountId, imapFolderName)) {
            console.log("Error: IMAP folder does not exist!")
            return
        }

        _imapStorage.retrieveMessageList(_imapAccountId, imapFolderName)
    }

    function _findAndRetrieveMessages() {
        console.log("Processing messages...")
        progress()

        var messageIds = _imapStorage.queryMessages(_imapAccountId, imapFolderName, imapMessageSubject)
        if (messageIds.length === 0) {
            console.log("No message found. Performing initital upload.")
            _imapStorage.addMessage(_imapAccountId, imapFolderName, imapMessageSubject, "to-do-o/default.xml")
            _reportSuccess()
        } else if (messageIds.length === 1) {
            console.log("Message found.")
            _imapMessageId = messageIds[0]
            console.log("Message id is: " + _imapMessageId)
            _imapStorage.retrieveMessage(_imapMessageId)
        } else {
            console.log("Error: Multiple messages found.")
        }
    }

    function _processMessage() {
        console.log("Processing message...")
        progress()

        var attachmentLocations = _imapStorage.getAttachmentLocations(_imapMessageId)
        console.log("Found the following attachment locations: " + attachmentLocations)

        _imapSyncFile = _imapStorage.writeAttachmentTo(_imapMessageId, attachmentLocations[0], "to-do-o")
        console.log("Wrote attachment to: " + _imapSyncFile)

        if (merger.merge()) {
            console.log("Merger reported changes, updating attachment...")
            _imapStorage.updateMessageAttachment(_imapMessageId, "to-do-o/default.xml")
        } else {
            _reportSuccess()
        }
    }

    function _reportSuccess() {
        succeeded()

        if (useBuiltInDialogs) {
            _syncToImapProgressDialog.close()
            _messageDialog.title = "Success"
            _messageDialog.message = "Sync was successful."
            _messageDialog.open()
        }
    }


    onProgress: {
        if (useBuiltInDialogs) {
            _syncToImapProgressDialog.currentValue++
        }
    }

    ImapStorage {
        id: _imapStorage

        onFolderCreated: _processImapFolder()
        onFolderListRetrieved: _prepareImapFolder()
        onMessageListRetrieved: _findAndRetrieveMessages()
        onMessageRetrieved: _processMessage()

        onMessageUpdated: {
            _reportSuccess()
        }

        onError: {
            _syncToImapProgressDialog.close()
            _messageDialog.title = "Error"
            _messageDialog.message = "Sync failed: \"" + errorString + "\" Code: " + errorCode + " Action: " + currentAction
            _messageDialog.open()
        }
    }

    ProgressDialog {
        id: _syncToImapProgressDialog
        parent: syncToImapItem.parent

        title: "Syncing..."
        message: "Sync to IMAP in progess"

        maxValue: 6
        currentValue: 0
    }

    MessageDialog {
        id: _messageDialog
        parent: syncToImapItem.parent
    }
}
