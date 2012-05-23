/*
 *  Copyright 2011 Ruediger Gad
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

#ifndef NODELISTMODEL_H
#define NODELISTMODEL_H

#include <QAbstractListModel>
#include <QDomElement>
#include <QDomNodeList>
#include <QObject>

#include "todostorage.h"

class NodeListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount)
public:
    enum EntryRoles {
        TagNameRole = Qt::UserRole + 1,
        TextRole,
        IsExpandableRole,
        IsLeafRole,

        ColorRole,
        DateRole,
        IsDoneRole,
        ProgressRole
    };

    explicit NodeListModel(QObject *parent = 0);

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    Q_INVOKABLE int rowCount(const QModelIndex &parent = QModelIndex()) const;
    Qt::ItemFlags flags(const QModelIndex &/*index*/) const { return Qt::ItemIsSelectable | Qt::ItemIsEnabled | Qt::ItemIsEditable; }

    QDomElement getElementAt(int index) { return childNodes.item(index).toElement(); }

    Q_INVOKABLE void addElement(QString type, QString text, QString color);
    Q_INVOKABLE void deleteElement(int index);
    Q_INVOKABLE void updateElement(int index, QString type, QString text, QString color);
    Q_INVOKABLE void setAttribute(int index, QString name, QString value);
    Q_INVOKABLE void move(int from, int to, int n);

    Q_INVOKABLE int countSubTodos(int index, bool todoOnly = false, bool recursive = false );

signals:
    void changed();

public slots:
    void setParentFromSelection(NodeListModel *model, int selectionIndex);
    void setRoot(ToDoStorage *storage);

private:
    QDomDocument document;
    QDomElement root;

    QDomElement parentElement;
    QDomNodeList childNodes;

    int countSubNodeTodos(QDomNodeList subNodes, bool todoOnly, bool recursive);

};

#endif // NODELISTMODEL_H
