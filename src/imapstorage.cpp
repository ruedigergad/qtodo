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
#include <qmfclient/qmaildisconnected.h>
#include <qmfclient/qmailstore.h>
#include <qmfclient/qmailfolderkey.h>

ImapStorage::ImapStorage(QObject *parent) :
    QObject(parent)
{
    createFolderAction = new QMailStorageAction();
    connect(createFolderAction, SIGNAL(activityChanged(QMailServiceAction::Activity)),
            this, SLOT(createFolderActivityChanged(QMailServiceAction::Activity)));
    connect(QMailStore::instance(), SIGNAL(foldersAdded(QMailFolderIdList)),
            this, SLOT(foldersAdded(QMailFolderIdList&)));
    connect(QMailStore::instance(), SIGNAL(foldersUpdated(QMailFolderIdList)),
            this, SLOT(foldersAdded(QMailFolderIdList&)));
    connect(QMailStore::instance(), SIGNAL(accountContentsModified(QMailAccountIdList)),
            this, SLOT(accountContentsModified(QMailAccountIdList)));
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
            emit folderCreated();
            break;
        case AddMessageAction:
        case NoAction:
        default:
            break;
    }

    currentAction = NoAction;
}

void ImapStorage::addMessage(ulong accId, QString folder, QString subject) {
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
void ImapStorage::foldersAdded(const QMailFolderIdList &ids) {
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
        ret.append(messageIds.at(i));
    }
    return ret;
}

bool ImapStorage::removeMessage(ulong msgId) {
    return QMailStore::instance()->removeMessage(QMailMessageId(msgId));
}
