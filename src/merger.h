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
    
    Q_INVOKABLE void merge(QString incoming);

signals:
    
public slots:

private:
    QDomElement incomingRoot;
    ToDoStorage *incomingStorage;

    QDomElement ownRoot;
    ToDoStorage *ownStorage;

    int maxId;
    int minId;

    QDomElement copyElement(QDomElement from, QDomElement to);
    void deepCopy(QDomElement from, QDomElement to);
    void deleteOldNodes(QDomElement element);
    QDomElement existsInElement(QDomElement searched, QDomElement container);
    void findMinId(QDomElement element);
    void mergeDeletions();
    void mergeElements(QDomElement own, QDomElement incoming);
};

#endif // MERGER_H
