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
#include <qmfclient/qmailstore.h>

ImapAccountHelper::ImapAccountHelper(QObject *parent) :
    QObject(parent)
{
}

int ImapAccountHelper::encryptionSetting(ulong accId) {
    return imapConfig(accId).value("encryption").toInt();
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

void ImapAccountHelper::addAccount(QString accountName, QString userName, QString password, QString server, QString port, int encryptionSetting) {
    qDebug() << "Adding new account: " << accountName << " " << userName << " " << server << " " << port << " " << encryptionSetting;
    QMailAccount *account = new QMailAccount();

    account->setName(accountName);
    account->setStatus(QMailAccount::UserEditable, true);
    account->setStatus(QMailAccount::UserRemovable, true);
    account->setMessageType(QMailMessage::Email);
    account->setStatus(QMailAccount::Enabled, true);

    QMailAccountConfiguration *accountConfig = new QMailAccountConfiguration();
    accountConfig->addServiceConfiguration("imap4");
    QMailAccountConfiguration::ServiceConfiguration serviceConfig = accountConfig->serviceConfiguration("imap4");

    serviceConfig.setValue("username", userName);
    serviceConfig.setValue("password", QString(password.toAscii().toBase64()));
    serviceConfig.setValue("server", server);
    serviceConfig.setValue("port", port);
    serviceConfig.setValue("encryption", QString::number(encryptionSetting));
    serviceConfig.setValue("canDelete", "1");
    serviceConfig.setValue("servicetype", "source");
//    serviceConfig.setValue("capabilities", "IMAP4rev1 CHILDREN ENABLE ID IDLE LIST-EXTENDED LIST-STATUS LITERAL+ MOVE NAMESPACE SASL-IR SORT THREAD=ORDEREDSUBJECT UIDPLUS UNSELECT WITHIN AUTH=LOGIN AUTH=PLAIN");
    serviceConfig.setValue("authentication", "2");
    serviceConfig.setValue("autoDownload", "0");
    serviceConfig.setValue("baseFolder", "");

    QMailStore::instance()->addAccount(account, accountConfig);
}

void ImapAccountHelper::updateAccount(ulong accId, QString userName, QString password, QString server, QString port, int encryptionSetting) {
    qDebug() << "Updating account: " << accId << " " << userName << " " << server << " " << port << " " << encryptionSetting;
    QMailAccount *account = new QMailAccount(QMailAccountId(accId));

    QMailAccountConfiguration *accountConfig = new QMailAccountConfiguration(QMailAccountId(accId));
    QMailAccountConfiguration::ServiceConfiguration serviceConfig = accountConfig->serviceConfiguration("imap4");

    serviceConfig.setValue("username", userName);
    serviceConfig.setValue("password", QString(password.toAscii().toBase64()));
    serviceConfig.setValue("server", server);
    serviceConfig.setValue("port", port);
    serviceConfig.setValue("encryption", QString::number(encryptionSetting));

    QMailStore::instance()->updateAccount(account, accountConfig);
}
