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

#if defined(MER_EDITION_SAILFISH) && defined(SAILFISH_BOOSTER)
#include <MDeclarativeCache>
#endif

#if defined(MER_EDITION_SAILFISH)
#include <sailfishapp.h>
#else
#include <QApplication>
#endif

#if defined(LINUX_DESKTOP)
#include "qtodotrayicon.h"
#endif

#ifdef QTODO_SYNC_SUPPORT
#include <synctoimap.h>
#include <filehelper.h>
#include <imapaccounthelper.h>
#include <imapaccountlistmodel.h>
#include <imapstorage.h>
#endif



Q_DECL_EXPORT int main(int argc, char *argv[])
{
    qDebug("Initializing Q To-Do...");

#if defined(QTODO_SYNC_SUPPORT) && defined(LINUX_DESKTOP)
    SyncToImap::init();
#endif

    /*
     * Init Application
     */
#if defined(MER_EDITION_SAILFISH)
    QGuiApplication *app = SailfishApp::application(argc, argv);
    QQuickView *view = SailfishApp::createView();
#else
    QApplication *app = new QApplication(argc, argv);
    QQuickView *view = new QQuickView();
#endif

    QCoreApplication::setOrganizationName("ruedigergad.com");
    QCoreApplication::setOrganizationDomain("ruedigergad.com");
    QCoreApplication::setApplicationName("qtodo");

//    view = new QToDoView();

#if defined(MER_EDITION_SAILFISH)
    qmlRegisterType<FileHelper>("harbour.qtodo", 1, 0, "FileHelper");
    qmlRegisterType<ImapAccountHelper>("harbour.qtodo", 1, 0, "ImapAccountHelper");
    qmlRegisterType<ImapAccountListModel>("harbour.qtodo", 1, 0, "ImapAccountListModel");
    qmlRegisterType<ImapStorage>("harbour.qtodo", 1, 0, "ImapStorage");

    qmlRegisterType<Merger>("harbour.qtodo", 1, 0, "Merger");
    qmlRegisterType<NodeListModel>("harbour.qtodo", 1, 0, "NodeListModel");
    qmlRegisterType<ToDoStorage>("harbour.qtodo", 1, 0, "ToDoStorage");
#else
    qmlRegisterType<Merger>("qtodo", 1, 0, "Merger");
    qmlRegisterType<NodeListModel>("qtodo", 1, 0, "NodeListModel");
    qmlRegisterType<ToDoStorage>("qtodo", 1, 0, "ToDoStorage");

    app->setApplicationName("Q To-Do");
    app->setApplicationDisplayName("Q To-Do");
#endif

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

#if defined(MER_EDITION_SAILFISH)
    view->setSource(QUrl("/usr/share/harbour-qtodo/qml/main.qml"));
#elif defined(LINUX_DESKTOP)
    QUrl mainQmlLocation;
    if (QFile::exists(QCoreApplication::applicationDirPath() + "/../qml/main.qml")) {
        mainQmlLocation = QUrl(QCoreApplication::applicationDirPath() + "/../qml/main.qml");
    } else if (QFile::exists(QCoreApplication::applicationDirPath() + "/qml/main.qml")) {
        mainQmlLocation = QUrl(QCoreApplication::applicationDirPath() + "/qml/main.qml");
    } else if (QFile::exists("qml/main.qml")) {
        mainQmlLocation = QUrl("qml/main.qml");
    } else {
        qErrnoWarning("Couldn't find qml/main.qml, aborting.");
        return -1;
    }
    view->setSource(mainQmlLocation);
#elif defined(Q_OS_ANDROID)
    view->setSource(QUrl(QStringLiteral("qrc:/main.qml")));
#endif

    view->setResizeMode(QQuickView::SizeRootObjectToView);

#if defined(MER_EDITION_SAILFISH) || defined(Q_OS_ANDROID)
    view->show();
#elif defined(LINUX_DESKTOP)
    view->resize(400, 500);
    view->show();
#endif

    int ret = app->exec();

#if defined(QTODO_SYNC_SUPPORT) && defined(LINUX_DESKTOP)
    SyncToImap::shutdown();
#endif

    return ret;
}
