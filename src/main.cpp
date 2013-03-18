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

#include <QtGui/QApplication>
#include <QtDeclarative>

#ifdef MEEGO_EDITION_HARMATTAN
#include <applauncherd/MDeclarativeCache>
#endif

#include <filehelper.h>
#include <imapstorage.h>
#include <merger.h>
#include <nodelistmodel.h>
#include <todostorage.h>

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QApplication *app;
    QDeclarativeView *view;

#ifdef MEEGO_EDITION_HARMATTAN
    app = MDeclarativeCache::qApplication(argc, argv);
    view = MDeclarativeCache::qDeclarativeView();
#else
    app = new QApplication(argc, argv);
    view = new QDeclarativeView();
#endif

    qmlRegisterType<FileHelper>("qtodo", 1, 0, "FileHelper");
    qmlRegisterType<ImapStorage>("qtodo", 1, 0, "ImapStorage");
    qmlRegisterType<Merger>("qtodo", 1, 0, "Merger");
    qmlRegisterType<NodeListModel>("qtodo", 1, 0, "NodeListModel");
    qmlRegisterType<ToDoStorage>("qtodo", 1, 0, "ToDoStorage");

    view->setAttribute(Qt::WA_OpaquePaintEvent);
    view->setAttribute(Qt::WA_NoSystemBackground);
    view->viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    view->viewport()->setAttribute(Qt::WA_NoSystemBackground);

#ifdef MEEGO_EDITION_HARMATTAN
    view->setSource(QUrl("/opt/qtodo/qml/meego/main.qml"));
    view->showFullScreen();
#else
    view->setSource(QUrl("qml/desktop/main.qml"));
    view->setResizeMode(QDeclarativeView::SizeRootObjectToView);
    view->resize(500, 600);
    view->show();
#endif
    return app->exec();
}
