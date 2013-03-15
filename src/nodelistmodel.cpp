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

NodeListModel::NodeListModel(QObject *parent) :
    QAbstractListModel(parent)
{
    QHash<int, QByteArray> roles;
    roles[TagNameRole] = "tagName";
    roles[TextRole] = "elementText";
    roles[IsExpandableRole] = "isExpandable";
    roles[IsLeafRole] = "isLeaf";

    roles[ColorRole] = "elementColor";
    roles[DateRole] = "elementDate";
    roles[IsDoneRole] = "isDone";
    roles[ProgressRole] = "elementProgress";
    roles[IdRole] = "elementId";
    setRoleNames(roles);
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

    document = model->document;
    root = model->root;
    parentElement = model->getElementAt(selectionIndex);
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

    emit changed();
}

void NodeListModel::deleteElement(int index){
    beginResetModel();
    if(childNodes.at(0).isText())
        index++;

    parentElement.removeChild(childNodes.at(index));
    endResetModel();
    emit changed();
}

void NodeListModel::updateElement(int index, QString type, QString text, QString color){
    beginResetModel();
    if(childNodes.at(0).isText())
        index++;

    QDomElement element = childNodes.at(index).toElement();
    element.setTagName(type);
    element.firstChild().toText().setData(text);

    if(type == "to-do"){
        element.setAttribute("color", color);
    }
    endResetModel();
    emit changed();
}

void NodeListModel::setAttribute(int index, QString name, QString value){
    beginResetModel();
    if(childNodes.at(0).isText())
        index++;

    childNodes.at(index).toElement().setAttribute(name, value);

    endResetModel();
    emit changed();
}

void NodeListModel::move(int from, int to, int /*n*/){
    beginResetModel();
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
    endResetModel();
}

int NodeListModel::countSubTodos(int index, bool todoOnly, bool recursive){
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

    for (int i = 0; i < childNodes.count(); i++) {
        QDomNode node = childNodes.at(i);
        if (! node.isText()) {
            QDomElement element = node.toElement();
            if (element.attribute("done", "false") == "true") {
                parentElement.removeChild(element);
                i--;
            }
        }
    }

    endResetModel();
    emit changed();
}
