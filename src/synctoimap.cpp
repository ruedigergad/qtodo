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

QString SyncToImap::ownLibPathStr = "";
QString SyncToImap::ownPathStr = "";
QProcess *SyncToImap::messageServerProcess = NULL;
bool SyncToImap::messageServerStarted = false;

SyncToImap::SyncToImap()
{
}

int SyncToImap::getOwnLibPath() {
#ifdef LINUX_DESKTOP
    if (QFile::exists(ownPathStr + "/../lib/qmf/lib/qmf/plugins5/messageservices/libimap.so")) {
        ownLibPathStr = ownPathStr + "/../lib";
    } else if (QFile::exists(ownPathStr + "/lib/qmf/lib/qmf/plugins5/messageservices/libimap.so")) {
        ownLibPathStr = ownPathStr + "/lib";
    } else if (QFile::exists("lib/qmf/lib/qmf/plugins5/messageservices/libimap.so")) {
        ownLibPathStr = "lib";
    } else {
        qErrnoWarning("Couldn't find own lib directory. Synchronization feature might not work.");
        return -1;
    }
#endif
    return 0;
}

int SyncToImap::getOwnPath() {
#ifdef LINUX_DESKTOP
    char ownPath[256];
    int ownPathLength = readlink("/proc/self/cwd", ownPath, 256);
    ownPathStr = QString::fromUtf8(ownPath, ownPathLength);
    qDebug() << "Found own path:" << ownPathStr;
#endif
    return 0;
}

int SyncToImap::setEnvironmentVariables() {
    qDebug("Setting SyncToImap environment variables...");

    getOwnPath();
    getOwnLibPath();
#ifdef LINUX_DESKTOP
    QString libDirPath = ownLibPathStr + "/qmf/lib";
    QString qmfPluginsEnvVar = ownLibPathStr + "/qmf/lib/qmf/plugins5";

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
#ifdef WINDOWS_DESKTOP
    QString messageServerRunningQuery = "tasklist | find /N \"messageserver.exe\"";
    QString messageServerExecutable = "messageserver.exe";
#endif
#ifdef LINUX_DESKTOP
    QString messageServerRunningQuery = "ps -el | grep messageserver5";
    QString messageServerExecutable = ownLibPathStr + "/qmf/bin/messageserver5";
#endif
#if defined(LINUX_DESKTOP) || defined(WINDOWS_DESKTOP)
    QProcess queryMessageServerRunning;
    queryMessageServerRunning.start(messageServerRunningQuery);
    queryMessageServerRunning.waitForFinished(-1);

    if (queryMessageServerRunning.exitCode() != 0) {
        qDebug("Starting messageserver...");
        messageServerProcess = new QProcess();
        messageServerProcess->start(messageServerExecutable);
        messageServerStarted = true;
    } else {
        qDebug("Messageserver is already running.");
    }
#endif

    return 0;
}

int SyncToImap::stopMessageServer() {
    return 0;
}
