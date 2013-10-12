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

#include "synctoimap.h"

#include <QDebug>
#include <QFile>

#include <unistd.h>

SyncToImap::SyncToImap()
{
}

int SyncToImap::setEnvironmentVariables() {
    qDebug("Setting SyncToImap environment variables...");
#ifdef LINUX_DESKTOP
    char ownPath[256];
    readlink("/proc/self/cwd", ownPath, 256);
    QString ownPathStr = QString::fromLocal8Bit(ownPath);
    qDebug() << "Found own path:" << ownPathStr;

    /* Set QMF_PLUGINS environment variable.*/
    QString qmfPluginsEnvVar;
    if (QFile::exists(ownPathStr + "/../lib/qmf/lib/qmf/plugins5/messageservices/libimap.so")) {
        qmfPluginsEnvVar = ownPathStr + "/../lib/qmf/lib/qmf/plugins5";
    } else if (QFile::exists(ownPathStr + "/lib/qmf/lib/qmf/plugins5/messageservices/libimap.so")) {
        qmfPluginsEnvVar = ownPathStr + "/lib/qmf/lib/qmf/plugins5";
    } else if (QFile::exists("lib/qmf/lib/qmf/plugins5/messageservices/libimap.so")) {
        qmfPluginsEnvVar = "lib/qmf/lib/qmf/plugins5";
    } else {
        qErrnoWarning("Couldn't find QMF plugins directory. Synchronization feature might not work.");
        return -1;
    }

    if (! qmfPluginsEnvVar.isEmpty()) {
        qDebug() << "Setting QMF_PLUGINS to:" << qmfPluginsEnvVar.toLatin1();
        qDebug() << "setenv returned:" << setenv("QMF_PLUGINS", qmfPluginsEnvVar.toLocal8Bit().constData(), 1);
        return 0;
    }

    return -2;
#endif
}

int SyncToImap::startMessageServer() {
    return 0;
}

int SyncToImap::stopMessageServer() {
    return 0;
}
