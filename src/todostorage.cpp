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

#include "todostorage.h"

#include <QFile>
#include <QTextStream>

ToDoStorage::ToDoStorage(QObject *parent) :
    QObject(parent)
{
    if(!QDir().exists(getPath())){
        QDir().mkdir(getPath());
        QFile file(DEFAULT_FILE);
        file.open(QFile::WriteOnly);
        // Quite a hack but this should work for now...
        file.write("<?xml version='1.0' encoding='UTF-8'?><root></root>");
        file.flush();
        file.close();
    }
    if(!QDir().exists(getPath() + "/sketches")){
        QDir().mkdir(getPath() + "/sketches");
    }
}

ToDoStorage::~ToDoStorage(){
    document.clear();
}

void ToDoStorage::open(){
    open(DEFAULT_FILE);
}

void ToDoStorage::open(QString fileName){
    document.clear();
    QFile file(fileName);

    if(! file.open(QFile::ReadOnly)){
        QString msg = "Error opening file " + fileName + ".";
        qErrnoWarning(msg.toUtf8().constData());
        emit error(msg);
        return;
    }

    QString errMsg;
    if(! document.setContent(&file, &errMsg)){
        QString msg = "Error reading file " + fileName + ": " + errMsg;
        qErrnoWarning(msg.toUtf8().constData());
        emit error(msg);
        return;
    }

    qDebug("Successfully opened: %s", fileName.toUtf8().constData());
    emit documentOpened();
}

void ToDoStorage::save(){
    save(DEFAULT_FILE);
}

void ToDoStorage::save(QString fileName){
    QFile file(fileName);

    if(! file.open(QFile::WriteOnly)){
        QString msg = "Error opening file " + fileName + " for writing.";
        qErrnoWarning(msg.toUtf8().constData());
        emit error(msg);
        return;
    }

    file.resize(0);
    QTextStream out(&file);
    out << document.toString(2);
    out.flush();
    file.close();

    qDebug("Successfully saved: %s", fileName.toUtf8().constData());

}
