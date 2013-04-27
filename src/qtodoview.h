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

#ifndef QTODOVIEW_H
#define QTODOVIEW_H

#include <QDeclarativeView>

class QToDoView : public QDeclarativeView
{
    Q_OBJECT
    Q_PROPERTY(bool windowFocus READ getWindowFocus() NOTIFY windowFocusChanged)

public:
    explicit QToDoView(QWidget *parent = 0);
    
    bool getWindowFocus() { return m_windowFocus; }

signals:
    void windowFocusChanged(bool focus);

protected:
    void focusInEvent(QFocusEvent *event);
    void focusOutEvent(QFocusEvent *event);

public slots:
    
private:
    bool m_windowFocus;

    void setWindowFocus(bool focus) {
        m_windowFocus = focus;
        windowFocusChanged(m_windowFocus);
    }
};

#endif // QTODOVIEW_H
