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

QDomElement Merger::copyElement(QDomElement from, QDomElement to) {
    QDomElement newElement = incomingStorage->getDocument().createElement(from.tagName());
    newElement.appendChild(incomingStorage->getDocument().createTextNode(from.firstChild().toText().nodeValue()));

    if(from.tagName() == "to-do"){
        newElement.setAttribute("color", from.attribute("color", "blue"));
        newElement.setAttribute("done", from.attribute("done", "false"));
    }

    maxId++;;
    newElement.setAttribute("id", maxId);

    to.appendChild(newElement);
    return newElement;
}

void Merger::deepCopy(QDomElement from, QDomElement to) {
    if (! from.hasChildNodes()) {
        return;
    }

    QDomNodeList childNodes = from.childNodes();
    for (int i = 0; i < childNodes.count(); i++) {
        QDomNode node = childNodes.at(i);

        if (! node.isText()) {
            QDomElement element = node.toElement();

            QDomElement newElement = copyElement(element, to);
            if (element.hasChildNodes()) {
                deepCopy(element, newElement);
            }
        }
    }
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
    deletedIds = ownRoot.attribute("deleted_ids", "").split(",");
    deletedIds.append(incomingRoot.attribute("deleted_ids", "").split(","));
    deletedIds.removeDuplicates();

    mergeDeletions();

    maxId = incomingRoot.attribute("max_id", "-1").toInt();
    qDebug() << "maxId: " << maxId;

    removeDeletedIds(incomingRoot);
    removeDeletedIds(ownRoot);

    mergeElements(ownRoot, incomingRoot);
    incomingRoot.setAttribute("max_id", maxId);
    incomingRoot.setAttribute("deleted_ids", deletedIds.join(","));

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
                QDomElement newElement = copyElement(ownElement, incoming);

                if (ownElement.hasChildNodes()) {
                    deepCopy(ownElement, newElement);
                }
            } else {
                mergeElements(ownElement, foundElement);
            }
        }
    }
}

void Merger::removeDeletedIds(QDomElement parentElement) {
    if (! parentElement.hasChildNodes()) {
        return;
    }

    QDomNodeList childNodes = parentElement.childNodes();
    for (int i = 0; i < childNodes.count(); i++) {
        QDomNode node = childNodes.at(i);

        if (! node.isText()) {
            QDomElement element = node.toElement();
            QString id = element.attribute("id", "-1");

            if (deletedIds.contains(id)) {
                parentElement.removeChild(element);
            } else if (element.hasChildNodes()) {
                removeDeletedIds(element);
            }
        }
    }
}
