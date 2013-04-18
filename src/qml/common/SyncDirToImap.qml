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

SyncToImapBase {

    property variant _dirSyncFiles
    property int _dirSyncIndex

    function syncDir(dirName, messageSubjectPrefix) {
        console.log("Syncing dir " + dirName + ". Using prefix " + messageSubjectPrefix + ".")

        if (dirName === "") {
            console.log("Error: dirName is not set. Stopping sync.")
            return
        }
        if (messageSubjectPrefix === "") {
            console.log("Error: messageSubjectPrefix is not set. Stopping sync.")
            return
        }

        _baseDir = dirName
        _imapMessageSubject = ""
        _imapMessageSubjectPrefix = messageSubjectPrefix
        _localFileName = ""

        _syncToImap()
    }

    function _addFiles() {
        if (_dirSyncIndex < _dirSyncFiles.length) {
            var file = _dirSyncFiles[_dirSyncIndex]
            console.log("Uploading: " + _baseDir + "/" + file)
            console.log("Subject: " + _imapMessageSubjectPrefix + file)
            _dirSyncIndex++
            _imapStorage.addMessage(_imapAccountId, imapFolderName, _imapMessageSubjectPrefix + file, _baseDir + "/" + file)
        } else {
            console.log("Processed all messages.")
            _reportSuccess()
        }
    }

    function _retrieveMessages() {
        if (_dirSyncIndex < _messageIds.length) {
            var msgId = _messageIds[_dirSyncIndex]
            console.log("Retrieving: " + msgId)
            _dirSyncIndex++
            _imapStorage.retrieveMessage(msgId)
        } else {
            console.log("Retrieved all messages.")
            _dirSyncIndex = 0
            _processMessages()
        }
    }

    function _processMessages() {
        console.log("Processing messages: " + _messageIds)

        for (var i = _dirSyncIndex; i < _messageIds.length; i++) {
            var msgId = _messageIds[i]
            var attachmentLocation = _getFirstAttachmenLocation(msgId)

            if (attachmentLocation === "") {
                console.log("Invalid attachment location.")
                continue
            }

            var attachmentIdentifier = _imapStorage.getAttachmentIdentifier(msgId, attachmentLocation)
            console.log("Processing attachment: " + attachmentIdentifier)

            if (fileHelper.exists(_baseDir + "/" + attachmentIdentifier)) {
                console.log("File " + _baseDir + "/" + attachmentIdentifier + " exits. Merging...")
            } else {
                console.log("File " + _baseDir + "/" + attachmentIdentifier + " not found. Extracting attachment in-place...")
                _imapStorage.writeAttachmentTo(msgId, attachmentLocation, _baseDir)
            }
        }

        _reportSuccess()
    }

    onMessageAdded: _addFiles()
    onMessageIdsQueried: {
        console.log("Performing dir sync.")

        if (_messageIds.length === 0) {
            console.log("No message(s) found. Performing initital upload.")

            _dirSyncFiles = _fileHelper.ls(_baseDir)
            console.log("Uploading: " + _dirSyncFiles)
            _dirSyncIndex = 0

            if (useBuiltInDialogs) {
                _syncToImapProgressDialog.maxValue = _dirSyncFiles.length
                _syncToImapProgressDialog.currentValue = 0
            }

            _addFiles()
        } else {
            console.log("Message(s) found: Retrieving " + _messageIds)
            _dirSyncIndex = 0
            _retrieveMessages()
        }
    }
    onMessageRetrieved: _retrieveMessages()
}
