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

#include "merger.h"
#include "todostorage.h"
#include <limits>
#include <QDebug>

Merger::Merger(QObject *parent) :
    QObject(parent)
{
    incomingStorage = new ToDoStorage();
    ownStorage = new ToDoStorage();
}

void Merger::deleteOldNodes(QDomElement parentElement) {
    QDomNodeList childNodes = parentElement.childNodes();
    for (int i = 0; i < childNodes.count(); i++) {
        QDomNode node = childNodes.at(i);

        if (! node.isText()) {
            QDomElement element = node.toElement();

            if (element.attribute("id", "-1").toInt() < minId) {
                parentElement.removeChild(element);
                i--;
            } else {
                if(element.hasChildNodes()) {
                    deleteOldNodes(element);
                }
            }
        }
    }
}

void Merger::findMinId(QDomElement parentElement) {
    QDomNodeList childNodes = parentElement.childNodes();

    for (int i = 0; i < childNodes.count(); i++) {
        QDomNode node = childNodes.at(i);

        if (! node.isText()) {
            QDomElement element = node.toElement();

            minId = qMin(minId, element.attribute("id", QString::number(std::numeric_limits<int>::max())).toInt());

            if(element.hasChildNodes()) {
                findMinId(element);
            }
        }
    }
}

void Merger::merge(QString incoming) {
    incomingStorage->open(incoming);
    incomingRoot = incomingStorage->getRootElement();

    ownStorage->open();
    ownRoot = ownStorage->getRootElement();

    mergeDeletions();

    incomingStorage->save(incoming);
}

void Merger::mergeDeletions() {
    minId = std::numeric_limits<int>::max();

    findMinId(ownRoot);
    qDebug() << "Found min id: " << minId;
    deleteOldNodes(incomingRoot);
}
