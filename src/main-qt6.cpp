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

#include <QCoreApplication>
#include <QGuiApplication>
#include <QQuickView>
#include <QtQml>

#include "merger.h"
#include "nodelistmodel.h"
#include "todostorage.h"

#if defined(LINUX_DESKTOP)
#include "qtodotrayicon.h"
#endif


int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);

    qmlRegisterType<Merger>("qtodo", 1, 0, "Merger");
    qmlRegisterType<NodeListModel>("qtodo", 1, 0, "NodeListModel");
    qmlRegisterType<ToDoStorage>("qtodo", 1, 0, "ToDoStorage");

    app.setApplicationName("Q To-Do");
    app.setApplicationDisplayName("Q To-Do");

    QQuickView *view = new QQuickView();
    view->setSource(QUrl(QStringLiteral("qrc:/main.qml")));
    view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->resize(400, 500);
    view->show();

    return app.exec();
}
