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
#include <QDateTime>

Merger::Merger(QObject *parent) :
    QObject(parent)
{
    incomingStorage = new ToDoStorage();
    ownStorage = new ToDoStorage();
}

QDomElement Merger::copyElement(const QDomElement &from, QDomElement &to) {
//    if (from.tagName() == "sketch") {
//        qDebug("copyElement: Skipping sketch...");
//        return QDomElement();
//    }

    QDomElement newElement = incomingStorage->getDocument().createElement(from.tagName());
    newElement.appendChild(incomingStorage->getDocument().createTextNode(from.firstChild().toText().nodeValue()));

    int fromId = from.attribute("id", "-1").toInt();

    if (from.tagName() == "to-do") {
        newElement.setAttribute("color", from.attribute("color", "blue"));
        newElement.setAttribute("done", from.attribute("done", "false"));
    }

    if (fromId > ownMaxId) {
        newElement.setAttribute("id", fromId);
    } else {
        ownMaxId++;
        newElement.setAttribute("id", ownMaxId);
    }

    if (to.firstChild().isText()) {
        to.insertAfter(newElement, to.firstChild());
    } else if (! to.firstChild().isNull()){
        to.insertBefore(newElement, to.firstChild());
    } else {
        to.appendChild(newElement);
    }

    return newElement;
}

void Merger::deepCopy(const QDomElement &from, QDomElement &to) {
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

void Merger::deleteOldNodes(QDomElement &parentElement) {
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

QDomElement Merger::findByExample(const QDomElement &searched, const QDomElement &container) {
    if (! container.hasChildNodes()) {
        return QDomElement();
    }

    QDomNodeList childNodes = container.childNodes();
    for (int i = 0; i < childNodes.count(); i++) {
        QDomNode node = childNodes.at(i);

        if (! node.isText()) {
            QDomElement element = node.toElement();

            if(element.tagName() == searched.tagName() &&
                    element.attribute("id", "-1") == searched.attribute("id", "-1") &&
                    element.firstChild().toText().nodeValue() == searched.firstChild().toText().nodeValue()) {
                return element;
            }
        }
    }

    return QDomElement();
}

QDomElement Merger::findById(QString id, const QDomElement &container) {
    if (! container.hasChildNodes()) {
        return QDomElement();
    }

    QDomNodeList childNodes = container.childNodes();
    for (int i = 0; i < childNodes.count(); i++) {
        QDomNode node = childNodes.at(i);

        if (! node.isText()) {
            QDomElement element = node.toElement();

            if (element.attribute("id", "-1") == id) {
                return element;
            }

            if (element.hasChildNodes()) {
                QDomElement ret = findById(id, element);
                if (! ret.isNull()) {
                    return ret;
                }
            }
        }
    }

    return QDomElement();
}

void Merger::findMinId(const QDomElement &parentElement) {
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

void Merger::mergeTodoStorage(QString incoming) {
    incomingStorage->open(incoming);
    incomingRoot = incomingStorage->getRootElement();

    ownStorage->open();
    ownRoot = ownStorage->getRootElement();
    deletedIds = ownRoot.attribute("deleted_ids", "").split(",");
    deletedIds.append(incomingRoot.attribute("deleted_ids", "").split(","));
    deletedIds.removeDuplicates();
    qDebug() << "Deleted Ids: " << deletedIds;

    mergeDeletions();

    incomingMaxId = incomingRoot.attribute("max_id", "-1").toInt();
    ownMaxId = ownRoot.attribute("max_id", "-1").toInt();
    qDebug() << "ownMaxId: " << ownMaxId << " incomingMaxId: " << incomingMaxId;

    removeDeletedIds(incomingRoot);
    removeDeletedIds(ownRoot);

    mergeExistingElements(incomingRoot, ownRoot);
    mergeNewElements(incomingRoot, ownRoot);

    if (ownMaxId >= incomingMaxId) {
        ownRoot.setAttribute("max_id", ownMaxId);
    } else {
        ownRoot.setAttribute("max_id", incomingMaxId);
    }
    ownRoot.setAttribute("deleted_ids", deletedIds.join(","));

    ownStorage->save();
}

void Merger::mergeDeletions() {
    minId = std::numeric_limits<int>::max();

    findMinId(ownRoot);
    qDebug() << "Found minId: " << minId;
    deleteOldNodes(incomingRoot);
    deleteOldNodes(ownRoot);
}

void Merger::mergeElementData(const QDomElement &from, QDomElement &to) {
    qDebug() << "Merging element data for id: " << from.attribute("id", "-1");
    to.setTagName(from.tagName());
    to.firstChild().toText().setNodeValue(from.firstChild().toText().nodeValue());

    QDomNamedNodeMap fromAttributes = from.attributes();
    for (int i = 0; i < fromAttributes.count(); i++) {
        QDomNode attribute = fromAttributes.item(i);
        qDebug() << "Merging attribute: " << attribute.nodeName() << " : " << attribute.nodeValue();
        to.setAttribute(attribute.nodeName(), attribute.nodeValue());
    }
}

void Merger::mergeExistingElements(const QDomElement &from, const QDomElement &to) {
    if (! to.hasChildNodes()) {
        return;
    }

    QDomNodeList toChildNodes = to.childNodes();
    for (int i = 0; i < toChildNodes.count(); i++) {
        QDomNode toNode = toChildNodes.at(i);

        if (! toNode.isText()) {

            QDomElement toElement = toNode.toElement();

            QString id = toElement.attribute("id", "-1");
            if (id != "-1") {
                QDomElement fromElement = findById(id, from);

                if (! fromElement.isNull()) {
                    QDateTime fromTime = QDateTime::fromString(fromElement.attribute("mtime", "1970-01-01T00:00:00"), Qt::ISODate);
                    QDateTime toTime = QDateTime::fromString(toElement.attribute("mtime", "1970-01-01T00:00:00"), Qt::ISODate);

                    if (fromTime > toTime) {
                        mergeElementData(fromElement, toElement);
                    } else if (toTime > fromTime) {
                        mergeElementData(toElement, fromElement);
                    }
                }
            }

            if (toElement.hasChildNodes()) {
                mergeExistingElements(from, toElement);
            }
        }
    }
}

void Merger::mergeNewElements(const QDomElement &own, QDomElement &incoming) {
    if (! own.hasChildNodes()) {
        return;
    }

    QDomNodeList ownChildNodes = own.childNodes();
    for (int i = 0; i < ownChildNodes.count(); i++) {
        QDomNode ownNode = ownChildNodes.at(i);

        if (! ownNode.isText()) {
            QDomElement ownElement = ownNode.toElement();

            QDomElement foundElement = findByExample(ownElement, incoming);
            if (foundElement.isNull()) {
                QDomElement newElement = copyElement(ownElement, incoming);

                if (ownElement.hasChildNodes()) {
                    deepCopy(ownElement, newElement);
                }
            } else {
                mergeNewElements(ownElement, foundElement);
            }
        }
    }
}

void Merger::removeDeletedIds(QDomElement &parentElement) {
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
                i--;
            } else if (element.hasChildNodes()) {
                removeDeletedIds(element);
            }
        }
    }
}
