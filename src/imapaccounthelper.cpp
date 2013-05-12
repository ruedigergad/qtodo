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

#include "imapaccounthelper.h"
#include <QDebug>
#include <qmfclient/qmailaccount.h>

ImapAccountHelper::ImapAccountHelper(QObject *parent) :
    QObject(parent)
{
}

QMailAccountConfiguration::ServiceConfiguration ImapAccountHelper::imapConfig(ulong accId) {
    QMailAccountConfiguration *accountConfig = new QMailAccountConfiguration(QMailAccountId(accId));
    QMailAccountConfiguration::ServiceConfiguration serviceConfig = accountConfig->serviceConfiguration("imap4");
    qDebug() << serviceConfig.values();
    return serviceConfig;
}

QString ImapAccountHelper::imapPassword(ulong accId) {
    return QString(QByteArray::fromBase64(imapConfig(accId).value("password").toAscii()));
}

QString ImapAccountHelper::imapPort(ulong accId) {
    return imapConfig(accId).value("port");
}

QString ImapAccountHelper::imapServer(ulong accId) {
    return imapConfig(accId).value("server");
}

QString ImapAccountHelper::imapUserName(ulong accId) {
    return imapConfig(accId).value("username");
}
