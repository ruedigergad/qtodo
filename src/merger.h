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

#ifndef MERGER_H
#define MERGER_H

#include <QObject>
#include <QDomElement>
#include "todostorage.h"

class Merger : public QObject
{
    Q_OBJECT
public:
    explicit Merger(QObject *parent = 0);
    
    Q_INVOKABLE void mergeTodoStorage(QString incoming);

signals:
    
public slots:

private:
    QDomElement incomingRoot;
    ToDoStorage *incomingStorage;

    QDomElement ownRoot;
    ToDoStorage *ownStorage;

    QStringList deletedIds;
    int incomingMaxId;
    int ownMaxId;
    int minId;

    QDomElement copyElement(const QDomElement &from, QDomElement &to);
    void deepCopy(const QDomElement &from, QDomElement &to);
    void deleteOldNodes(QDomElement &element);
    QDomElement findByExample(const QDomElement &searched, const QDomElement &container);
    QDomElement findById(QString id, const QDomElement &container);
    void findMinId(const QDomElement &element);
    void mergeDeletions();
    void mergeElementData(const QDomElement &from, QDomElement &to);
    void mergeExistingElements(const QDomElement &from, const QDomElement &to);
    void mergeNewElements(const QDomElement &own, QDomElement &incoming);
    void removeDeletedIds(QDomElement &element);
};

#endif // MERGER_H
