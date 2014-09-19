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

#include "nodelistmodel.h"
#include <QDateTime>
#include <QDebug>
#include <QModelIndex>

NodeListModel::NodeListModel(QObject *parent) :
    QAbstractListModel(parent),
    parentModel(NULL)
{
    m_roles[TagNameRole] = "tagName";
    m_roles[TextRole] = "elementText";
    m_roles[IsExpandableRole] = "isExpandable";
    m_roles[IsLeafRole] = "isLeaf";

    m_roles[ColorRole] = "elementColor";
    m_roles[DateRole] = "elementDate";
    m_roles[IsDoneRole] = "isDone";
    m_roles[ProgressRole] = "elementProgress";
    m_roles[IdRole] = "elementId";
}

QVariant NodeListModel::data(const QModelIndex &idx, int role) const{
    QModelIndex index;
    if (childNodes.at(0).isText())
        index = createIndex(idx.row() + 1, 0);
    else
        index = idx;

    if (index.row() < 0 || index.row() > childNodes.count()
            || !childNodes.item(index.row()).isElement())
        return QVariant();

    QDomElement element = childNodes.at(index.row()).toElement();

    if(role == TagNameRole)
        return element.tagName();
    else if (role == TextRole)
        return element.firstChild().isText() ? element.firstChild().toText().nodeValue() : "n/a";
    else if (role == IsExpandableRole)
        return element.tagName() == "to-do";
    else if (role == IsLeafRole)
        return element.childNodes().count() <= 1;

    else if (role == ColorRole)
        return element.attribute("color", "blue");
    else if (role == DateRole)
        return element.attribute("date");
    else if (role == IsDoneRole)
        return element.attribute("done", "false") == "true";
    else if (role == ProgressRole)
        return element.attribute("progress", "-1").toDouble();
    else if (role == IdRole)
        return element.attribute("id", "-1").toInt();
    return QVariant();
}

int NodeListModel::rowCount(const QModelIndex &/*parent*/) const{
    return childNodes.at(0).isText() ? childNodes.count() - 1 : childNodes.count();
}

void NodeListModel::setParentFromSelection(NodeListModel *model, int selectionIndex){
    qDebug("Setting new parent from selection...");
    beginResetModel();

    if(model->childNodes.at(0).isText())
        selectionIndex++;

    parentModel = model;
    document = parentModel->document;
    root = parentModel->root;
    parentElement = parentModel->getElementAt(selectionIndex);
    childNodes = parentElement.childNodes();
    endResetModel();

    qDebug("New child count is: %d", childNodes.count());
}

void NodeListModel::setRoot(ToDoStorage *storage){
    qDebug("Setting new root for model...");
    beginResetModel();

    document = storage->getDocument();
    root = storage->getRootElement();
    parentElement = root;
    childNodes = parentElement.childNodes();

    qDebug("New child count is: %d", childNodes.count());
    endResetModel();
}

void NodeListModel::addElement(QString type, QString text, QString color){
    if (parentModel != NULL) {
        parentModel->beginResetModel();
    }
    beginResetModel();

    QDomElement element = document.createElement(type);
    element.appendChild(document.createTextNode(text));
    if(type == "to-do"){
        element.setAttribute("color", color);
    }

    int max_id = getMaxId();
    max_id++;
    element.setAttribute("id", max_id);
    root.setAttribute("max_id", max_id);

    const QDomNode firstChild = parentElement.firstChild();
    if(firstChild.isText()){
        parentElement.insertAfter(element, firstChild);
    }else{
        parentElement.insertBefore(element, firstChild);
    }
    endResetModel();
    if (parentModel != NULL) {
        parentModel->endResetModel();
    }

    emit changed();
}

void NodeListModel::deleteElement(int index){
    if (parentModel != NULL) {
        parentModel->beginResetModel();
    }
    beginResetModel();

    if(childNodes.at(0).isText())
        index++;

    QString id = childNodes.at(index).toElement().attribute("id", "-1");
    QStringList deleted = root.attribute("deleted_ids", "").split(",");
    deleted.append(id);

    parentElement.removeChild(childNodes.at(index));
    endResetModel();
    if (parentModel != NULL) {
        parentModel->endResetModel();
    }

    root.setAttribute("deleted_ids", deleted.join(","));
    emit changed();
}

QStringList NodeListModel::getSketchNamesForIndex(int index) {
    qDebug() << "Searching for sketches at index: " << index;
    if (childNodes.at(0).isText())
        index++;

    if (index >= 0) {
        QDomElement element = childNodes.at(index).toElement();
        return getSketchNames(element);
    } else {
        return getSketchNames(root);
    }
}

QStringList NodeListModel::getSketchNames(QDomElement element) {
    QStringList ret;

    if (element.tagName() != "to-do" && element.tagName() != "root")
        return ret;

    QDomNodeList subNodes = element.childNodes();

    if (subNodes.count() <= 0)
        return ret;

    for (int i = subNodes.at(0).isText() ? 1 : 0; i < subNodes.count(); i++) {
        QDomElement subElement = subNodes.at(i).toElement();

        if (subElement.tagName() == "sketch") {
            QString sketchName = subElement.text();
            qDebug() << "Found sketch " + sketchName;
            ret << sketchName;
        }

        if (subElement.tagName() == "to-do") {
            ret << getSketchNames(subElement);
        }
    }

    return ret;
}

void NodeListModel::updateElement(int rowIndex, QString type, QString text, QString color){
    bool isTextNode = false;
    if(childNodes.at(0).isText())
        isTextNode = true;

    QDomElement element = childNodes.at(isTextNode ? rowIndex + 1 : rowIndex).toElement();
    element.setTagName(type);
    element.firstChild().toText().setData(text);

    if(type == "to-do"){
        element.setAttribute("color", color);
    }
    element.setAttribute("mtime", QDateTime::currentDateTime().toString(Qt::ISODate));

    QModelIndex modelIndex = index(rowIndex, 0);
    emit dataChanged(modelIndex, modelIndex);
    emit changed();
}

void NodeListModel::setAttribute(int rowIndex, QString name, QString value){
    bool isTextNode = false;
    if(childNodes.at(0).isText())
        isTextNode = true;

    QDomElement element = childNodes.at(isTextNode ? rowIndex + 1 : rowIndex).toElement();
    element.setAttribute(name, value);
    element.setAttribute("mtime", QDateTime::currentDateTime().toString(Qt::ISODate));

    QModelIndex modelIndex = index(rowIndex, 0);
    emit dataChanged(modelIndex, modelIndex);
    emit changed();
}

void NodeListModel::move(int from, int to){
    if(childNodes.at(0).isText()){
        from++;
        to++;
    }

    QDomNode temp = parentElement.removeChild(childNodes.at(from));
    if(to == 0){
        parentElement.insertBefore(temp, childNodes.at(to));
    }else{
        parentElement.insertAfter(temp, childNodes.at(to - 1));
    }

    const QModelIndex fromIndex = index(from, 0);
    const QModelIndex toIndex = index(to, 0);

    if (from < to) {
        emit dataChanged(fromIndex, toIndex);
    } else {
        emit dataChanged(toIndex, fromIndex);
    }
}

int NodeListModel::countSubTodos(int index, bool todoOnly, bool recursive){
    if (index < 0) {
        return -1;
    }

    QDomElement element = childNodes.at(index).toElement();
    if(element.tagName() != "to-do")
        return -1;

    QDomNodeList subNodes = element.childNodes();
    if(subNodes.count() <= 1)
        return 0;

    return countSubNodeTodos(subNodes, todoOnly, recursive);
}

int NodeListModel::countSubNodeTodos(QDomNodeList subNodes, bool todoOnly, bool recursive){
    int count = 0;

    for(int i = 1; i < subNodes.count(); i++){
        QDomElement subElement = subNodes.at(i).toElement();

        if(subElement.tagName() == "to-do"){
            if(!todoOnly){
                count++;

                if(recursive && subElement.childNodes().count() > 1){
                    count += countSubNodeTodos(subElement.childNodes(), todoOnly, recursive);
                }
                continue;
            }

            if(subElement.attribute("done", "false") == "false"){
                count++;

                if(recursive && subElement.childNodes().count() > 1){
                    count += countSubNodeTodos(subElement.childNodes(), todoOnly, recursive);
                }
            }
        }
    }

    return count;
}

void NodeListModel::cleanDone(){
    beginResetModel();

    int index = 0;

    if(childNodes.at(0).isText())
        index++;

    QStringList deleted = root.attribute("deleted_ids", "").split(",");

    for (int i = 0; i < childNodes.count(); i++) {
        QDomNode node = childNodes.at(i);
        if (! node.isText()) {
            QDomElement element = node.toElement();
            if (element.attribute("done", "false") == "true") {
                QString id = element.attribute("id", "-1");
                deleted.append(id);
                parentElement.removeChild(element);
                i--;
            }
        }
    }

    root.setAttribute("deleted_ids", deleted.join(","));
    endResetModel();
    emit changed();
}
