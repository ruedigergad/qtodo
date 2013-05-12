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

#include "imapaccountlistmodel.h"

ImapAccountListModel::ImapAccountListModel(QObject *parent) :
    QSortFilterProxyModel(parent)
{
    accountListModel = new QMailAccountListModel();
    accountListModel->setSynchronizeEnabled(true);
    setSourceModel(accountListModel);

    QHash<int, QByteArray> roles;
    roles[AccountNameRole] = "accountName";
    roles[AccountIdRole] = "accountId";
    setRoleNames(roles);
}

QVariant ImapAccountListModel::data(const QModelIndex &index, int role) const{
    if (index.row() < 0)
        return QVariant();

    QModelIndex sourceModelIndex = mapToSource(index);

    if(role == AccountNameRole)
        return accountListModel->data(sourceModelIndex, QMailAccountListModel::NameTextRole);
    else if (role == AccountIdRole)
        return accountListModel->idFromIndex(sourceModelIndex).toULongLong();

    return QVariant();
}

int ImapAccountListModel::rowCount(const QModelIndex &parent) const{
    return accountListModel->rowCount(parent);
}
