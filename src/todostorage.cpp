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

#include <QDebug>
#include <QFile>
#include <QTextStream>

#ifdef Q_OS_ANDROID
#include <QStandardPaths>
#endif

ToDoStorage::ToDoStorage(QObject *parent) :
    QObject(parent)
{
    QString path = getPath();
    if (!QDir().exists(path)) {
        QDir().mkdir(path);
    }
    if (!QDir().exists(path + "/sketches")) {
        QDir().mkdir(path + "/sketches");
    }
    if (! QFile::exists(path + DEFAULT_FILE)) {
        QFile file(path + DEFAULT_FILE);
        file.open(QFile::WriteOnly);
        // Quite a hack but this should work for now...
        file.write("<?xml version='1.0' encoding='UTF-8'?><root></root>");
        file.flush();
        file.close();
    }
}

ToDoStorage::~ToDoStorage(){
    document.clear();
}

QString ToDoStorage::getPath() {
#ifdef Q_OS_ANDROID
    return QStandardPaths::standardLocations(QStandardPaths::DataLocation).at(1);
#else
    return DEFAULT_PATH;
#endif
}

void ToDoStorage::open(){
    open(getPath() + DEFAULT_FILE);
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
    save(getPath() + DEFAULT_FILE);
}

void ToDoStorage::save(QString fileName){
    qDebug() << "Saving file to: " << fileName;
    emit saving();
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
    emit saved();
}
