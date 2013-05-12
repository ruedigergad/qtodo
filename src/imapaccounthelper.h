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

#ifndef IMAPACCOUNTHELPER_H
#define IMAPACCOUNTHELPER_H

#include <QObject>
#include <qmfclient/qmailaccountconfiguration.h>

class ImapAccountHelper : public QObject
{
    Q_OBJECT
public:
    explicit ImapAccountHelper(QObject *parent = 0);

    Q_INVOKABLE QString imapPassword(ulong accId);
    Q_INVOKABLE QString imapPort(ulong accId);
    Q_INVOKABLE QString imapServer(ulong accId);
    Q_INVOKABLE QString imapUserName(ulong accId);
    
signals:
    
public slots:
    
private:
    QMailAccountConfiguration::ServiceConfiguration imapConfig(ulong accId);
};

#endif // IMAPACCOUNTHELPER_H
