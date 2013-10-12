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
    int ownPathLength = readlink("/proc/self/cwd", ownPath, 256);
    QString ownPathStr = QString::fromUtf8(ownPath, ownPathLength);
    qDebug() << "Found own path:" << ownPathStr;

    QString libDirPath;
    QString qmfPluginsEnvVar;
    if (QFile::exists(ownPathStr + "/../lib/qmf/lib/qmf/plugins5/messageservices/libimap.so")) {
        qmfPluginsEnvVar = ownPathStr + "/../lib/qmf/lib/qmf/plugins5";
        libDirPath = ownPathStr + "/../lib/qmf/lib";
    } else if (QFile::exists(ownPathStr + "/lib/qmf/lib/qmf/plugins5/messageservices/libimap.so")) {
        qmfPluginsEnvVar = ownPathStr + "/lib/qmf/lib/qmf/plugins5";
        libDirPath = ownPathStr + "/lib/qmf/lib";
    } else if (QFile::exists("lib/qmf/lib/qmf/plugins5/messageservices/libimap.so")) {
        qmfPluginsEnvVar = "lib/qmf/lib/qmf/plugins5";
        libDirPath = "lib/qmf/lib";
    } else {
        qErrnoWarning("Couldn't find QMF plugins directory. Synchronization feature might not work.");
        return -1;
    }

    if (! qmfPluginsEnvVar.isEmpty()) {
        qDebug() << "Setting QMF_PLUGINS to:" << qmfPluginsEnvVar.toLatin1();
        qDebug() << "setenv returned:" << setenv("QMF_PLUGINS", qmfPluginsEnvVar.toLocal8Bit().constData(), 1);
    }

    if (! libDirPath.isEmpty()) {
        char *ldLibraryPath = getenv("LD_LIBRARY_PATH");
        qDebug() << "Got LD_LIBRARY_PATH:" << ldLibraryPath;

        libDirPath = QString(ldLibraryPath) + ":" + libDirPath;
        qDebug() << "Setting new LD_LIBRARY_PATH:" << libDirPath;
        qDebug() << "setenv returned:" << setenv("LD_LIBRARY_PATH", libDirPath.toLocal8Bit().constData(), 1);
    }

    return 0;
#endif
}

int SyncToImap::startMessageServer() {
    return 0;
}

int SyncToImap::stopMessageServer() {
    return 0;
}
