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
#include <QMenu>
#include "qtodotrayicon.h"

QTodoTrayIcon::QTodoTrayIcon(const QIcon &icon, QDeclarativeView *view) :
    QSystemTrayIcon(icon),
    view(view)
{
    QMenu *trayMenu = new QMenu();
    QAction *quitAction = new QAction("Quit", 0);
    trayMenu->addAction(quitAction);
    connect(quitAction, SIGNAL(triggered()), view, SLOT(close()));
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

void QTodoTrayIcon::toggleViewHide() {
    if (view->isHidden()) {
        view->show();
    } else {
        view->hide();
    }
}
