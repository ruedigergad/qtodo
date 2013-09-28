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

#if defined(LINUX_DESKTOP)
#include <QApplication>
#endif

#include <QQuickView>
#include <QProcess>
#include <QtQml>

//#include "qtodoview.h"

#include "filehelper.h"

#ifdef QTODO_SYNC_SUPPORT
#include "imapaccounthelper.h"
#include "imapaccountlistmodel.h"
#include "imapstorage.h"
#endif

#include "merger.h"
#include "nodelistmodel.h"
#include "todostorage.h"

#if defined(LINUX_DESKTOP)
#include "qtodotrayicon.h"
#endif

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    printf("Entering Q To-Do main...");
    qDebug("Initializing Q To-Do...");

    /*
     * Init Application
     */
#if defined(LINUX_DESKTOP)
    QApplication *app = new QApplication(argc, argv);
#else
    QGuiApplication *app = new QGuiApplication(argc, argv);
#endif
    QQuickView *view = new QQuickView();

    QCoreApplication::setOrganizationName("ruedigergad.com");
    QCoreApplication::setOrganizationDomain("ruedigergad.com");
    QCoreApplication::setApplicationName("qtodo");

//    view = new QToDoView();

    /*
     * Setup application.
     */
    qmlRegisterType<FileHelper>("SyncToImap", 1, 0, "FileHelper");

#ifdef QTODO_SYNC_SUPPORT
    qmlRegisterType<ImapAccountHelper>("SyncToImap", 1, 0, "ImapAccountHelper");
    qmlRegisterType<ImapAccountListModel>("SyncToImap", 1, 0, "ImapAccountListModel");
    qmlRegisterType<ImapStorage>("SyncToImap", 1, 0, "ImapStorage");
#endif

    qmlRegisterType<Merger>("qtodo", 1, 0, "Merger");
    qmlRegisterType<NodeListModel>("qtodo", 1, 0, "NodeListModel");
    qmlRegisterType<ToDoStorage>("qtodo", 1, 0, "ToDoStorage");


    app->setApplicationName("Q To-Do");
    app->setApplicationDisplayName("Q To-Do");

#if defined(LINUX_DESKTOP)
    QIcon icon(":/icon/icon.png");
    view->setIcon(icon);
    QTodoTrayIcon *trayIcon = new QTodoTrayIcon(icon, view, app);
    trayIcon->show();
#endif

//#ifdef WINDOWS_DESKTOP
//    view->setSource(QUrl("qrc:/qml/main.qml"));
//#else
//    view->setSource(QUrl("qml/main.qml"));
//#endif

    view->setResizeMode(QQuickView::SizeRootObjectToView);
    QUrl mainQmlLocation;
    if (QFile::exists(app->applicationDirPath() + "/../qml/main.qml")) {
        mainQmlLocation = QUrl(app->applicationDirPath() + "/../qml/main.qml");
    } else if (QFile::exists(app->applicationDirPath() + "/qml/main.qml")) {
        mainQmlLocation = QUrl(app->applicationDirPath() + "/qml/main.qml");
    } else if (QFile::exists("qml/main.qml")) {
        mainQmlLocation = QUrl("qml/main.qml");
    } else {
        qErrnoWarning("Couldn't find qml/main.qml, aborting.");
        return -1;
    }
    view->setSource(mainQmlLocation);
    view->resize(400, 500);
    view->show();

    int ret = app->exec();

    return ret;
}

