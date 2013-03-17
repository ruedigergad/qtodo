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

QDomElement Merger::existsInElement(QDomElement searched, QDomElement container) {
    if (! container.hasChildNodes()) {
        return QDomElement();
    }

    QDomNodeList childNodes = container.childNodes();
    for (int i = 0; i < childNodes.count(); i++) {
        QDomNode node = childNodes.at(i);

        if (! node.isText()) {
            QDomElement element = node.toElement();

            if(element.tagName() == searched.tagName() &&
                    element.attribute("id", "-1").toInt() == searched.attribute("id", "-1").toInt() &&
                    element.firstChild().toText().nodeValue() == searched.firstChild().toText().nodeValue()) {
                return element;
            }
        }
    }

    return QDomElement();
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

    maxId = incomingRoot.attribute("max_id", "-1").toInt();
    qDebug() << "maxId: " << maxId;

    mergeElements(ownRoot, incomingRoot);
    incomingRoot.setAttribute("max_id", maxId);

    incomingStorage->save();
}

void Merger::mergeDeletions() {
    minId = std::numeric_limits<int>::max();

    findMinId(ownRoot);
    qDebug() << "Found minId: " << minId;
    deleteOldNodes(incomingRoot);
}

void Merger::mergeElements(QDomElement own, QDomElement incoming) {
    if (! own.hasChildNodes()) {
        return;
    }

    QDomNodeList ownChildNodes = own.childNodes();
    for (int i = 0; i < ownChildNodes.count(); i++) {
        QDomNode ownNode = ownChildNodes.at(i);

        if (! ownNode.isText()) {
            QDomElement ownElement = ownNode.toElement();

            QDomElement foundElement = existsInElement(ownElement, incoming);
            if (foundElement.isNull()) {
                QDomElement newElement = incomingStorage->getDocument().createElement(ownElement.tagName());
                newElement.appendChild(incomingStorage->getDocument().createTextNode(ownElement.firstChild().toText().nodeValue()));

                if(ownElement.tagName() == "to-do"){
                    newElement.setAttribute("color", ownElement.attribute("color", "blue"));
                    newElement.setAttribute("done", ownElement.attribute("done", "false"));
                }

                maxId++;;
                newElement.setAttribute("id", maxId);

                incoming.appendChild(newElement);
            } else {
                mergeElements(ownElement, foundElement);
            }
        }
    }
}
