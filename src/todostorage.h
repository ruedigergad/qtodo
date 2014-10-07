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

#ifndef TODOSTORAGE_H
#define TODOSTORAGE_H

#include <QDir>
#include <QObject>
#include <QDomDocument>
#include <QDomElement>

#define DEFAULT_PATH QDir::homePath() + "/to-do-o"
#define DEFAULT_FILE "/default.xml"

class ToDoStorage : public QObject
{
    Q_OBJECT
public:
    explicit ToDoStorage(QObject *parent = 0);
    ~ToDoStorage();

    QDomDocument getDocument() { return document; }
    QDomElement getRootElement() { return document.documentElement(); }

    Q_INVOKABLE QString getPath();
    Q_INVOKABLE void open();
    Q_INVOKABLE void open(QString fileName);

    Q_INVOKABLE void save();
    Q_INVOKABLE void save(QString fileName);

signals:
    void documentOpened();
    void error(QString message);
    void saved();
    void saving();

private:
    QDomDocument document;

};

#endif // TODOSTORAGE_H
