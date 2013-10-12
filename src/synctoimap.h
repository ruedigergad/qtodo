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

#ifndef SYNCTOIMAP_H
#define SYNCTOIMAP_H

#include <QProcess>
#include <QString>

class SyncToImap
{
public:
    static int setEnvironmentVariables();
    static int startMessageServer();
    static int stopMessageServer();

private:
    SyncToImap();

    static int getOwnLibPath();
    static int getOwnPath();

    static QString ownLibPathStr;
    static QString ownPathStr;
    static QProcess *messageServerProcess;
    static bool messageServerStarted;
};

#endif // SYNCTOIMAP_H
