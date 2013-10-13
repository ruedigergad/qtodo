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

import QtQuick 2.0
import SyncToImap 1.0

Item {
    id: syncToImapBase

    property string imapFolderName: ""
    property QtObject merger
    property QtObject messageDialog
    property QtObject progressDialog
    property bool useDialogs: false

    signal error
    signal finished
    signal messageAdded
    signal messageDeleted
    signal messageDialogClosed
    signal messageIdsQueried
    signal messageRetrieved
    signal messageUpdated
    signal progress
    signal started
    signal success

    property string _baseDir: ""
    property int _imapAccountId: -1
    property int _imapMessageId: -1
    property string _imapMessageSubject: ""
    property string _imapMessageSubjectPrefix: ""
    property string _imapSyncFile: ""
    property string _localFileName
    property variant _messageIds

    property alias _fileHelper: _fileHelper
    property alias _imapStorage: _imapStorage

    function _syncToImap() {
        started()
        if (imapFolderName === "") {
            console.log("Error: imapFolderName not set. Stopping sync.")
            return
        }

        //TODO: Add check if merger was set.

        if (useDialogs) {
            progressDialog.currentValue = 0
            progressDialog.open()
        }

        _imapAccountId = imapAccountHelper.getSyncAccount()
        console.log("Found sync account id: " + _imapAccountId)
        _imapMessageId = -1
        _imapSyncFile = ""

        if (_imapAccountId < 0) {
            var accIds = _imapStorage.queryImapAccounts()
            console.log("Found " + accIds.length + " IMAP account(s).")
        }

        progress()

        if (_imapAccountId < 0) {
            if (accIds.length === 1) {
                console.log("Found a single IMAP account. Using this for syncing.")
                console.log("IMAP account id is: " + accIds[0])
                _imapAccountId = accIds[0]
            } else if (accIds.length === 0) {
                _reportError("No IMAP Account", "Please set up an IMAP e-mail account for syncing.")
            } else if (accIds.length > 1) {
                _reportError("Multiple IMAP Accounts", "Functionality for choosing from different IMAP accounts still needs to be implemented.")
            } else {
                _reportError("Unexpected Error", "Querying for IMAP accounts returned an unexpected value.")
            }
        }

        if (_imapAccountId >= 0) {
            _imapStorage.retrieveFolderList(_imapAccountId)
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

    function _queryMessages() {
        console.log("Processing messages...")
        progress()

        _messageIds = _imapStorage.queryMessages(_imapAccountId, imapFolderName, _imapMessageSubjectPrefix)

        messageIdsQueried()
    }

    function _filesAreEqual(fileNameA, fileNameB) {
        if (fileNameA === "" || fileNameB === "") {
            return false;
        }

        var md5A = _fileHelper.md5sum(fileNameA)
        var sha1A = _fileHelper.sha1sum(fileNameA)

        var md5B = _fileHelper.md5sum(fileNameB)
        var sha1B = _fileHelper.sha1sum(fileNameB)

        console.log("md5sum " + fileNameA + " " + md5A)
        console.log("md5sum " + fileNameB + " " + md5B)
        console.log("sha1sum " + fileNameA + " " + sha1A)
        console.log("sha1sum " + fileNameB + " " + sha1B)
        return md5A === md5B && sha1A === sha1B
    }

    function _getFirstAttachmenLocation(msgId) {
        var attachmentLocations = _imapStorage.getAttachmentLocations(msgId)

        if (! attachmentLocations.length >= 1) {
            console.log("Error getting attachment locations: " + attachmentLocations)
            return ""
        }

        return attachmentLocations[0]
    }

    function _reportError(title, message) {
        if (useDialogs) {
            progressDialog.close()
            messageDialog.title = title
            messageDialog.message = message
            messageDialog.open()
        }
    }

    function _reportSuccess() {
        finished()
        success()

        if (useDialogs) {
            progressDialog.close()
            messageDialog.title = "Success"
            messageDialog.message = "Sync was successful."
            messageDialog.open()
        }
    }

    onProgress: {
        if (useDialogs) {
            progressDialog.currentValue++
        }
    }

    ImapStorage {
        id: _imapStorage

        onFolderCreated: _processImapFolder()
        onFolderListRetrieved: _prepareImapFolder()
        onMessageAdded: syncToImapBase.messageAdded()
        onMessageDeleted: syncToImapBase.messageDeleted()
        onMessageListRetrieved: _queryMessages()
        onMessageRetrieved: syncToImapBase.messageRetrieved()
        onMessageUpdated: syncToImapBase.messageUpdated()

        onError: {
            finished()
            syncToImapBase.error(errorString, errorCode, currentAction)

            if (useDialogs) {
                progressDialog.close()
                messageDialog.title = "Error"
                messageDialog.message = "Sync failed: \"" + errorString + "\" Code: " + errorCode + " Action: " + currentAction
                messageDialog.open()
            }
        }
    }

    FileHelper { id: _fileHelper }

    ImapAccountHelper {
        id: imapAccountHelper
    }
}
