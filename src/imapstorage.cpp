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

#include "imapstorage.h"
#include <QDebug>
#include <QDir>
#include <qmfclient/qmaildisconnected.h>
#include <qmfclient/qmailstore.h>
#include <qmfclient/qmailfolderkey.h>

ImapStorage::ImapStorage(QObject *parent) :
    QObject(parent)
{
    createFolderAction = new QMailStorageAction();
    retrievalAction = new QMailRetrievalAction();
    searchAction = new QMailSearchAction();

    connect(createFolderAction, SIGNAL(activityChanged(QMailServiceAction::Activity)),
            this, SLOT(createFolderActivityChanged(QMailServiceAction::Activity)));
    connect(QMailStore::instance(), SIGNAL(foldersAdded(QMailFolderIdList)),
            this, SLOT(foldersAdded(QMailFolderIdList)));
    connect(QMailStore::instance(), SIGNAL(foldersUpdated(QMailFolderIdList)),
            this, SLOT(foldersAdded(QMailFolderIdList)));
    connect(QMailStore::instance(), SIGNAL(accountContentsModified(QMailAccountIdList)),
            this, SLOT(accountContentsModified(QMailAccountIdList)));

    connect(retrievalAction, SIGNAL(activityChanged(QMailServiceAction::Activity)),
            this, SLOT(retrieveActivityChanged(QMailServiceAction::Activity)));
    connect(searchAction, SIGNAL(activityChanged(QMailServiceAction::Activity)),
            this, SLOT(searchMessageActivityChanged(QMailServiceAction::Activity)));

    currentAction = NoAction;
}

/*
 * FIXME: For now we are checking if the account got modified in order to determine
 * if our folder got created. For some reason activityChanged(QMailServiceAction::Activity)
 * always reports a failure, even though the folder was created successfully. Also the
 * foldersAdded and foldersUpdated signals of QMailStore are not triggered when we add
 * our storage folder. Could it be that this is due to the fact that we are creating a
 * folder at the root level?
 */
void ImapStorage::accountContentsModified(const QMailAccountIdList &ids) {
    Q_UNUSED(ids);
    qDebug() << "accountContentsModified";

    switch (currentAction) {
        case CreateFolderAction:
            currentAction = NoAction;
            emit folderCreated();
            break;
        case AddMessageAction:
        case NoAction:
        default:
            break;
    }
}

void ImapStorage::addMessage(ulong accId, QString folder, QString subject, QString attachment) {
    QMailFolderIdList folderIds = queryFolders(accId, folder);
    if (folderIds.count() != 1) {
        qDebug("Error retrieving folder for new message!");
        return;
    }
    QMailFolderId folderId = folderIds.at(0);

    QMailMessage msg;
    msg.setParentAccountId(QMailAccountId(accId));
    msg.setParentFolderId(folderId);
    msg.setSubject(subject);
    msg.setMessageType(QMailMessageMetaDataFwd::Email);
    msg.setDate(QMailTimeStamp(QDateTime::currentDateTime()));
    msg.setStatus(QMailMessage::LocalOnly, true);
    if (attachment != "") {
        msg.setAttachments(QStringList() << QDir::homePath() + "/" + attachment);
    }

    QMailStore::instance()->addMessage(&msg);

    QMailDisconnected::moveToFolder(QMailMessageIdList() << msg.id(), folderId);
    currentAction = AddMessageAction;
    QMailRetrievalAction retrievalAction;
    retrievalAction.exportUpdates(QMailAccountId(accId));
}

void ImapStorage::createFolder(ulong accId, QString name) {
    currentAction = CreateFolderAction;
    createFolderAction->createFolder(name, QMailAccountId(accId), QMailFolderId());
}

/*
 * FIXME: This is not working properly right now. As a workaround we use the
 * accountContentsModified(QMailAccountIdList) signal of QMailStore (see above).
 */
void ImapStorage::createFolderActivityChanged(QMailServiceAction::Activity activity) {
    qDebug() << "createFolderAction activity changed: " << activity;
    if (activity == QMailServiceAction::Successful) {
        qDebug() << "Succeeded in creating folder.";
        //emit folderCreated();
    }
}

/*
 * Used for debugging. For some reason the activityChanged signal of createFolderAction
 * is not emitted upon success even though the folder is actually created successfully.
 */
void ImapStorage::foldersAdded(QMailFolderIdList ids) {
    qDebug() << "Folders added: " << ids << " number of new folders: " << ids.count();
}

bool ImapStorage::folderExists(ulong accId, QString path) {
    return (queryFolders(accId, path).count() == 1);
}

QMailFolderIdList ImapStorage::queryFolders(ulong accId, QString path) {
    QMailFolderKey accountKey(QMailFolderKey::parentAccountId(QMailAccountId(accId)));
    QMailFolderKey pathKey(QMailFolderKey::path(path));

    QMailFolderIdList folderIds = QMailStore::instance()->queryFolders(accountKey & pathKey);
    return folderIds;
}

QVariantList ImapStorage::queryImapAccounts() {
    QMailAccountIdList accountIds = QMailStore::instance()->queryAccounts();
    QVariantList ret;

    for (int i = 0; i < accountIds.count(); i++) {
        QMailAccount account(accountIds.at(i));

        if(account.messageSources().contains("imap4", Qt::CaseInsensitive)) {
            qDebug() << "Found IMAP account with id: " << account.id() << " and name: " << account.name();
            ret.append(account.id().toULongLong());
        } else {
            qDebug() << "Account with id: " << account.id() << " and name: " << account.name() << " does not support IMAP.";
            accountIds.removeAt(i);
            i--;
        }
    }

    return ret;
}

QVariantList ImapStorage::queryMessages(ulong accId, QString folder, QString subject) {
    QMailMessageKey accountKey(QMailMessageKey::parentAccountId(QMailAccountId(accId)));

    QMailFolderIdList folders = queryFolders(accId, folder);
    if (folders.count() != 1) {
        qDebug("Error retrieving folder for query!");
        return QVariantList();
    }

    QMailMessageKey folderKey(QMailMessageKey::parentFolderId(folders.at(0)));
    QMailMessageKey subjectKey(QMailMessageKey::subject(subject));

    QMailMessageIdList messageIds = QMailStore::instance()->queryMessages(accountKey & folderKey & subjectKey);

    QVariantList ret;
    for (int i = 0; i < messageIds.count(); i++) {
        ret.append(messageIds.at(i).toULongLong());
    }
    return ret;
}

bool ImapStorage::removeMessage(ulong msgId) {
    return QMailStore::instance()->removeMessage(QMailMessageId(msgId));
}

void ImapStorage::retrieveActivityChanged(QMailServiceAction::Activity activity) {
    qDebug() << "retrieveActivityChanged: " << activity;

    switch (activity) {
    case QMailServiceAction::Successful:
        switch (currentAction) {
        case RetrieveFolderListAction:
            currentAction = NoAction;
            emit folderListRetrieved();
            break;
        case RetrieveMessageAction:
            currentAction = NoAction;
            emit messageRetrieved();
            break;
        case RetrieveMessageListAction:
            currentAction = NoAction;
            emit messageListRetrieved();
            break;
        default:
            break;
        }
        break;
    default:
        break;
    }
}

void ImapStorage::retrieveFolderList(ulong accId) {
    qDebug() << "Retrieving folder list for account id: " << accId;
    currentAction = RetrieveFolderListAction;
    retrievalAction->retrieveFolderList(QMailAccountId(accId), QMailFolderId());
}

void ImapStorage::retrieveMessage(ulong msgId) {
    qDebug() << "Retrieving message with id: " << msgId;
    currentAction = RetrieveMessageAction;
    retrievalAction->retrieveMessages(QMailMessageIdList() << QMailMessageId(msgId), QMailRetrievalAction::Content);
}

void ImapStorage::retrieveMessageList(ulong accId, QString folder) {
    qDebug() << "Retrieving message list for account id: " << accId << " from folder: " << folder;

    QMailFolderIdList folders = queryFolders(accId, folder);
    if (folders.count() != 1) {
        qDebug("Error retrieving folder for search!");
        return;
    }

    currentAction = RetrieveMessageListAction;
    retrievalAction->retrieveMessageList(QMailAccountId(accId), folders.at(0));
}

void ImapStorage::searchMessage(ulong accId, QString folder, QString subject) {
    QMailMessageKey accountKey(QMailMessageKey::parentAccountId(QMailAccountId(accId)));

    QMailFolderIdList folders = queryFolders(accId, folder);
    if (folders.count() != 1) {
        qDebug("Error retrieving folder for search!");
        return;
    }

    QMailMessageKey folderKey(QMailMessageKey::parentFolderId(folders.at(0)));
    QMailMessageKey subjectKey(QMailMessageKey::subject(subject));

    searchAction->searchMessages(accountKey & folderKey & subjectKey, QString(), QMailSearchAction::Remote);
}

void ImapStorage::searchMessageActivityChanged(QMailServiceAction::Activity activity) {
    qDebug() << "searchActivityChanged: " << activity;

    QVariantList ret;
    QMailMessageIdList msgIds;

    switch (activity) {
        case QMailServiceAction::Successful:
            msgIds = searchAction->matchingMessageIds();

            qDebug() << "Search succeeded. Found " << msgIds.count() << " matches";

            for (int i = 0; i < msgIds.count(); i++) {
                ret.append(msgIds.at(i));
            }
            emit searchFinished(ret);
            break;
        case QMailServiceAction::Failed:
            emit searchFinished(ret);
            break;
        default:
            break;
    }
}
