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
#include <qmfclient/qmailstore.h>

ImapStorage::ImapStorage(QObject *parent) :
    QObject(parent)
{
}

QMailAccountIdList ImapStorage::queryImapAccounts() {
    QMailAccountIdList accountIds = QMailStore::instance()->queryAccounts();

    for (int i = 0; i < accountIds.count(); i++) {
        QMailAccount account(accountIds.at(i));

        if(account.messageSources().contains("imap4", Qt::CaseInsensitive)) {
            qDebug() << "Found IMAP account with id: " << account.id() << " and name: " << account.name();
        } else {
            qDebug() << "Account with id: " << account.id() << " and name: " << account.name() << " does not support IMAP.";
            accountIds.removeAt(i);
            i--;
        }
    }

    return accountIds;
}
