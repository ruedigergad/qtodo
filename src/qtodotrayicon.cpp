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

#include <QAction>
#include <QDebug>
#include <QMenu>
#include <QSettings>
#include "qtodotrayicon.h"

QTodoTrayIcon::QTodoTrayIcon(const QIcon &icon, QQuickView *view, QApplication *app) :
    QSystemTrayIcon(icon),
    app(app),
    view(view)
{
    QMenu *trayMenu = new QMenu();

    QAction *alwaysOnTopAction = new QAction("Always on Top", this);
    alwaysOnTopAction->setCheckable(true);
    alwaysOnTopAction->setChecked(QSettings().value("alwaysOnTop", true).toBool());
    connect(alwaysOnTopAction, SIGNAL(triggered(bool)), this, SLOT(toggleAlwaysOnTop(bool)));
//    trayMenu->addAction(alwaysOnTopAction);

#ifdef LINUX_DESKTOP
    QAction *hideDecorationAction = new QAction("Hide Window Decoration", this);
    hideDecorationAction->setCheckable(true);
    hideDecorationAction->setChecked(QSettings().value("hideDecoration", true).toBool());
    connect(hideDecorationAction, SIGNAL(triggered(bool)), this, SLOT(toggleHideDecoration(bool)));
//    trayMenu->addAction(hideDecorationAction);
#endif

    QAction *quitAction = new QAction("Quit", this);
    trayMenu->addAction(quitAction);
    connect(quitAction, SIGNAL(triggered()), app, SLOT(quit()));

    setContextMenu(trayMenu);

    connect(this, SIGNAL(activated(QSystemTrayIcon::ActivationReason)), this, SLOT(handleActivation(QSystemTrayIcon::ActivationReason)));
}

void QTodoTrayIcon::handleActivation(QSystemTrayIcon::ActivationReason reason) {
    switch(reason) {
    case QSystemTrayIcon::Trigger:
        toggleViewHide();
        break;
    default:
        break;
    }
}

void QTodoTrayIcon::toggleAlwaysOnTop(bool val) {
    QSettings().setValue("alwaysOnTop", val);
    if (val) {
        view->setFlags(view->flags() | Qt::WindowStaysOnTopHint);
        view->show();
    } else {
        view->setFlags(view->flags() & (~ Qt::WindowStaysOnTopHint));
        view->show();
    }
}

void QTodoTrayIcon::toggleHideDecoration(bool val) {
    QSettings().setValue("hideDecoration", val);
    if (val) {
        view->setFlags(view->flags() | Qt::FramelessWindowHint);
        view->show();
    } else {
        view->setFlags(view->flags() & (~ Qt::FramelessWindowHint));
        view->show();
    }
}

void QTodoTrayIcon::toggleViewHide() {
    if (!view->isVisible()) {
        view->setPosition(oldPosition);
        view->setVisible(true);
    } else {
        oldPosition = view->position();
        view->setVisible(false);
    }
}
