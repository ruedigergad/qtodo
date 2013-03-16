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
    
    Q_INVOKABLE void addMessage(ulong accId, QString folder, QString subject);
    Q_INVOKABLE void createFolder(ulong accId, QString name);
    Q_INVOKABLE bool folderExists(ulong accId, QString path);
    Q_INVOKABLE QVariantList queryImapAccounts();
    Q_INVOKABLE QVariantList queryMessages(ulong accId, QString folder, QString subject);
    Q_INVOKABLE bool removeMessage(ulong msgId);

signals:
    void folderCreated();
    
public slots:

private slots:
    void accountContentsModified(const QMailAccountIdList &ids);
    void createFolderActivityChanged(QMailServiceAction::Activity);
    void foldersAdded(const QMailFolderIdList &ids);

private:
    enum CurrentAction {
        CreateFolderAction,
        AddMessageAction,
        NoAction
    };

    QMailStorageAction *createFolderAction;
    CurrentAction currentAction;

    QMailFolderIdList queryFolders(ulong accId, QString path);
};

#endif // IMAPSTORAGE_H
