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
        syncToImapProgressDialog.currentValue = 0
        syncToImapProgressDialog.open()
        _syncToImap()
    }

    function _syncToImap() {
        var accIds = imapStorage.queryImapAccounts()
        console.log("Found " + accIds.length + " IMAP account(s).")

        progress()

        if (accIds.length === 1) {
            console.log("Found a single IMAP account. Using this for syncing.")
            console.log("IMAP account id is: " + accIds[0])
            _imapAccountId = accIds[0]
            imapStorage.retrieveFolderList(_imapAccountId)
        } else if (accIds.length === 0) {
            syncToImapProgressDialog.close()
            messageDialog.title = "No IMAP Account"
            messageDialog.message = "Please set up an IMAP e-mail account for syncing."
            messageDialog.open()
        } else if (accIds.length > 1) {
            syncToImapProgressDialog.close()
            messageDialog.title = "Multiple IMAP Accounts"
            messageDialog.message = "Functionality for choosing from different IMAP accounts still needs to be implemented."
            messageDialog.open()
        } else {
            syncToImapProgressDialog.close()
            messageDialog.title = "Unexpected Error"
            messageDialog.message = "Querying for IMAP accounts returned an unexpected value."
            messageDialog.open()
        }
    }

    function _prepareImapFolder() {
        progress()

        if (! imapStorage.folderExists(_imapAccountId, imapFolderName)) {
            console.log("Creating folder...")
            imapStorage.createFolder(_imapAccountId, imapFolderName)
        } else {
            _processImapFolder()
        }
    }

    function _processImapFolder() {
        console.log("Processing content of IMAP folder...")
        progress()

        if (! imapStorage.folderExists(_imapAccountId, imapFolderName)) {
            console.log("Error: IMAP folder does not exist!")
            return
        }

        imapStorage.retrieveMessageList(_imapAccountId, imapFolderName)
    }

    function findAndRetrieveMessages() {
        console.log("Processing messages...")
        progress()

        var messageIds = imapStorage.queryMessages(_imapAccountId, imapFolderName, imapMessageSubject)
        if (messageIds.length === 0) {
            console.log("No message found. Performing initital upload.")
            imapStorage.addMessage(_imapAccountId, imapFolderName, imapMessageSubject, "to-do-o/default.xml")
            reportSuccess()
        } else if (messageIds.length === 1) {
            console.log("Message found.")
            _imapMessageId = messageIds[0]
            console.log("Message id is: " + _imapMessageId)
            imapStorage.retrieveMessage(_imapMessageId)
        } else {
            console.log("Error: Multiple messages found.")
        }
    }

    function processMessage() {
        console.log("Processing message...")
        progress()

        var attachmentLocations = imapStorage.getAttachmentLocations(_imapMessageId)
        console.log("Found the following attachment locations: " + attachmentLocations)

        _imapSyncFile = imapStorage.writeAttachmentTo(_imapMessageId, attachmentLocations[0], "to-do-o")
        console.log("Wrote attachment to: " + _imapSyncFile)

        if (merger.merge()) {
            console.log("Merger reported changes, updating attachment...")
            imapStorage.updateMessageAttachment(_imapMessageId, "to-do-o/default.xml")
        } else {
            reportSuccess()
        }
    }

    function reportSuccess() {
        succeeded()
        syncToImapProgressDialog.close()
        messageDialog.title = "Success"
        messageDialog.message = "Sync was successful."
        messageDialog.open()
    }

    ImapStorage {
        id: imapStorage

        onFolderCreated: _processImapFolder()
        onFolderListRetrieved: _prepareImapFolder()
        onMessageListRetrieved: findAndRetrieveMessages()
        onMessageRetrieved: processMessage()

        onMessageUpdated: {
            reportSuccess()
        }

        onError: {
            syncToImapProgressDialog.close()
            messageDialog.title = "Error"
            messageDialog.message = "Sync failed: \"" + errorString + "\" Code: " + errorCode + " Action: " + currentAction
            messageDialog.open()
        }
    }

    onProgress: {
        syncToImapProgressDialog.currentValue++
    }

    ProgressDialog {
        id: syncToImapProgressDialog
        parent: syncToImapItem.parent

        title: "Syncing..."
        message: "Sync to IMAP in progess"

        maxValue: 6
        currentValue: 0
    }

    MessageDialog {
        id: messageDialog
        parent: syncToImapItem.parent
    }
}
