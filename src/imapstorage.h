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

#ifndef IMAPSTORAGE_H
#define IMAPSTORAGE_H

#include <QObject>
#include <qmfclient/qmailaccount.h>
#include <qmfclient/qmailserviceaction.h>

class ImapStorage : public QObject
{
    Q_OBJECT
public:
    explicit ImapStorage(QObject *parent = 0);
    
    Q_INVOKABLE void addMessage(ulong accId, QString folder, QString subject, QString attachment = "");
    Q_INVOKABLE void createFolder(ulong accId, QString name);
    Q_INVOKABLE void deleteMessage(ulong msgId);
    Q_INVOKABLE bool folderExists(ulong accId, QString path);
    Q_INVOKABLE QStringList getAttachmentLocations(ulong msgId);
    Q_INVOKABLE QString getAttachmentIdentifier(ulong msgId, QString attachmentLocation);
    Q_INVOKABLE void moveMessageToTrash(ulong msgId);
    Q_INVOKABLE QVariantList queryImapAccounts();
    Q_INVOKABLE QVariantList queryMessages(ulong accId, QString folder, QString subject);
    Q_INVOKABLE bool removeMessage(ulong msgId);
    Q_INVOKABLE void retrieveFolderList(ulong accId);
    Q_INVOKABLE void retrieveMessage(ulong msgId);
    Q_INVOKABLE void retrieveMessageList(ulong accId, QString folder);
    Q_INVOKABLE void searchMessage(ulong accId, QString folder, QString subject);
    Q_INVOKABLE void updateMessageAttachment(ulong msgId, QString attachment);
    Q_INVOKABLE QString writeAttachmentTo(ulong msgId, QString attachmentLocation, QString path);

signals:
    void error(QString errorString, int errorCode, int currentAction);
    void folderCreated();
    void folderListRetrieved();
    void messageDeleted();
    void messageListRetrieved();
    void messageRetrieved();
    void messageUpdated();
    void searchFinished(QVariantList msgIds);
    
public slots:

private slots:
    void accountContentsModified(const QMailAccountIdList &ids);
    void foldersAdded(QMailFolderIdList ids);
    void retrieveActivityChanged(QMailServiceAction::Activity);
    void searchMessageActivityChanged(QMailServiceAction::Activity);
    void storageActivityChanged(QMailServiceAction::Activity);

private:
    enum CurrentAction {
        NoAction,
        CreateFolderAction,
        AddMessageAction,
        SearchAction,
        RetrieveFolderListAction,
        RetrieveMessageListAction,
        RetrieveMessageAction,
        UpdateMessageAction,
        DeleteMessageAction,
        MoveToTrashAction
    };

    CurrentAction currentAction;
    QMailRetrievalAction *retrievalAction;
    QMailSearchAction *searchAction;
    QMailStorageAction *storageAction;

    QMailFolderIdList queryFolders(ulong accId, QString path);
};

#endif // IMAPSTORAGE_H
