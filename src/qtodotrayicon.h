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

#ifndef QTODOTRAYICON_H
#define QTODOTRAYICON_H

#include <QApplication>
#include <QIcon>
#include <QObject>
#include <QQuickView>
#include <QSystemTrayIcon>

class QTodoTrayIcon : public QSystemTrayIcon
{
    Q_OBJECT
public:
    explicit QTodoTrayIcon(const QIcon &icon, QQuickView *view, QApplication *app);
    
signals:
    
public slots:
    void toggleViewHide();

private:
    QApplication *app;
    QPoint oldPosition;
    QQuickView *view;

private slots:
    void handleActivation(QSystemTrayIcon::ActivationReason reason);
    void toggleAlwaysOnTop(bool val);
    void toggleHideDecoration(bool val);
    
};

#endif // QTODOTRAYICON_H
