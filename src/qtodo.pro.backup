android: {
    message(Android build with Qt version: $$QT_VERSION)
    TEMPLATE = app

    QT += qml quick widgets xml

    HEADERS += \
        todostorage.h \
        nodelistmodel.h \
        merger.h

    SOURCES += \
        todostorage.cpp \
        nodelistmodel.cpp \
        merger.cpp \
        main-qt5.cpp

    RESOURCES += android.qrc

    # Additional import path used to resolve QML modules in Qt Creator's code model
    QML_IMPORT_PATH =

    # Default rules for deployment.
    x86 {
        target.path = /libs/x86
    } else: armeabi-v7a {
        target.path = /libs/armeabi-v7a
    } else {
        target.path = /libs/armeabi
    }
    export(target.path)
    INSTALLS += target
    export(INSTALLS)

    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

    OTHER_FILES += \
        android/AndroidManifest.xml
} else {
    message(Building with Qt version: $$QT_VERSION)

    isEqual(QT_MAJOR_VERSION, 5) {
        message(Qt5 Build)

        DEFINES += QT5_BUILD

        QT += qml quick

        INCLUDEPATH += \
            synctoimap/lib/include

        qmlCommon.source = qml/qtquick2/common
    } else {
        qmlCommon.source = qml/common
    }

    exists("/usr/lib/qt5/qml/Sailfish/Silica/SilicaGridView.qml"): {
        message(SailfishOS build)

        TARGET = harbour-qtodo
        target.path = /usr/bin

        DEFINES += QDECLARATIVE_BOOSTER
        DEFINES += MER_EDITION_SAILFISH
        MER_EDITION = sailfish

        qmlSailfishCommon.source = qml/qtquick2/sailfish/common
        qmlSailfishCommon.target = /usr/share/harbour-qtodo/qml
        qmlSailfishMain.source = qml/qtquick2/sailfish/main.qml
        qmlSailfishMain.target = /usr/share/harbour-qtodo/qml
        DEPLOYMENTFOLDERS += qmlSailfishCommon qmlSailfishMain

    #    CONFIG += sailfishapp
        INCLUDEPATH += /usr/include/sailfishapp

        CONFIG += link_pkgconfig
        PKGCONFIG += qmfclient5 sailfishapp
    } else:exists($$QMAKE_INCDIR_QT"/../mdeclarativecache/MDeclarativeCache"): {
        message(Nemomobile build)

        DEFINES += QDECLARATIVE_BOOSTER
        DEFINES += MER_EDITION_NEMO
        MER_EDITION = nemo

        qmlMeego.source = qml/meego
        qmlMeego.target = qml

        qmlMeegoCommon.source = qml/meego/common
        qmlMeegoCommon.target = qml

        DEPLOYMENTFOLDERS += qmlMeego qmlMeegoCommon

        CONFIG += link_pkgconfig
        PKGCONFIG += qmfclient
    } else:exists($$QMAKE_INCDIR_QT"/../applauncherd/MDeclarativeCache"): {
        message(MeeGo/Harmattan build)

        MEEGO_VERSION_MAJOR     = 1
        MEEGO_VERSION_MINOR     = 2
        MEEGO_VERSION_PATCH     = 0
        MEEGO_EDITION           = harmattan

        DEFINES += QDECLARATIVE_BOOSTER
        DEFINES += MEEGO_EDITION_HARMATTAN

        arch = armv7hl
        os = linux/harmattan
        qmlCanvasImport.source = lib/build/$${os}/$${arch}/qmlcanvas
        qmlCanvasImport.target = lib/imports

        qmlMeego.source = qml/meego
        qmlMeego.target = qml

        qmlMeegoCommon.source = qml/meego/common
        qmlMeegoCommon.target = qml

        DEPLOYMENTFOLDERS += qmlMeego qmlMeegoCommon qmlCanvasImport

        wrapperScripts.files = qtodo_harmattan.sh
        wrapperScripts.path = /opt/$${TARGET}/bin

        CONFIG += link_pkgconfig
        PKGCONFIG += qmfclient

        INSTALLS += wrapperScripts
    } else:exists($$QMAKE_INCDIR_QT"/../bbndk.h"): {
        message(BB10 Build)

        DEFINES += BB10_BUILD

        LIBS += -lbbdata -lbb -lbbcascades
        QT += declarative xml opengl

        INCLUDEPATH += \
            lib/include

        LIBS += \
            -L$$PWD/lib/link/bb10 \
            -lqmfclient

        qmlCanvasImport.source = lib/build/bb10/qmlcanvas
        qmlCanvasImport.target = lib/imports

        qmfLibs.source = lib/build/bb10/qmf
        qmfLibs.target = lib

        qmlBB10.source = qml/bb10
        qmlBB10.target = qml

        DEPLOYMENTFOLDERS += qmlBB10 qmlCanvasImport qmfLibs

        barDescriptor.files = bar-descriptor.xml
        barDescriptor.path = $${TARGET}

        INSTALLS += barDescriptor
    } else:win32 {
        message(Windows Build)

        DEFINES += WINDOWS_DESKTOP
        DEFINES += _UNICODE

    #    CONFIG += console

        INCLUDEPATH += \
            lib/include \
            lib/include/QxtCore \
            lib/include/QxtGui

        LIBS += \
            -Llib/build/windows/x86 \
            -lqmfclient \
            -lQxtCore \
            -lQxtGui

        HEADERS += \
            qtodotrayicon.h \
            qtodoview.h

        SOURCES += \
            qtodotrayicon.cpp \
            qtodoview.cpp

        RC_FILE = qtc_packaging/windows/qtodo.rc

        RESOURCES += \
            icon.qrc \
            windows_resources.qrc
    } else {
        message(Defaulting to Linux desktop build.)

        DEFINES += LINUX_DESKTOP

        QT += widgets

        RESOURCES += \
            icon.qrc

        HEADERS += \
            qtodotrayicon.h

        SOURCES += \
            qtodotrayicon.cpp

        contains(DEFINES, QT5_BUILD) {
            message(Qt5 Linux Desktop Build)

            LIBS += \
                -L$$PWD/synctoimap/lib/build/linux/x86_64/qmf/lib \
                -lqmfclient5
            QMAKE_LFLAGS += '-Wl,-rpath,\'\$$ORIGIN/lib/qmf/lib\''

            # TODO: Dynamically determine architecture.
            arch = x86_64
            os = linux
            desktopQmfLibs.source = synctoimap/lib/build/$${os}/$${arch}/qmf
            desktopQmfLibs.target = lib
            qmlDesktopCommon.source = qml/qtquick2/desktop/common
            qmlDesktopCommon.target = qml
            qmlDesktopMain.source = qml/qtquick2/desktop/main.qml
            qmlDesktopMain.target = qml
            DEPLOYMENTFOLDERS += desktopQmfLibs qmlDesktopCommon qmlDesktopMain
        } else {
            error(Qt4 Linux Desktop Build is not supported anymore!)
        }
    }

    QT += xml

    # If your application uses the Qt Mobility libraries, uncomment the following
    # lines and add the respective components to the MOBILITY variable.
    # CONFIG += mobility
    # MOBILITY +=
    # QT += opengl

    HEADERS += \
        todostorage.h \
        nodelistmodel.h \
        merger.h

    SOURCES += \
        todostorage.cpp \
        nodelistmodel.cpp \
        merger.cpp

    contains(DEFINES, QT5_BUILD) {
        SOURCES += main-qt5.cpp
    } else {
        SOURCES += main.cpp
    }

    message(Building sync support...)
    DEFINES += QTODO_SYNC_SUPPORT
    HEADERS += \
        synctoimap/src/envvarhelper.h \
        synctoimap/src/filehelper.h \
        synctoimap/src/imapstorage.h \
        synctoimap/src/imapaccountlistmodel.h \
        synctoimap/src/imapaccounthelper.h \
        synctoimap/src/synctoimap.h
    INCLUDEPATH += \
        synctoimap/src
    SOURCES += \
        synctoimap/src/envvarhelper.cpp \
        synctoimap/src/filehelper.cpp \
        synctoimap/src/imapstorage.cpp \
        synctoimap/src/imapaccountlistmodel.cpp \
        synctoimap/src/imapaccounthelper.cpp \
        synctoimap/src/synctoimap.cpp
    syncToImapQml.source = synctoimap/qml/synctoimap

    OTHER_FILES += \
        qtodo.desktop \
        qtodo.png \
        qtodo.sh \
        qtodo.svg \
        qtodo_harmattan.desktop \
        qtodo_harmattan.sh \
        qtodo_mer.desktop \
        qtc_packaging/debian_harmattan/rules \
        qtc_packaging/debian_harmattan/README \
        qtc_packaging/debian_harmattan/copyright \
        qtc_packaging/debian_harmattan/control \
        qtc_packaging/debian_harmattan/compat \
        qtc_packaging/debian_harmattan/changelog \
        qml/bb10/main.qml \
        qml/common/AboutDialog.qml \
        qml/common/Drawing.qml \
        qml/common/FlowListView.qml \
        qml/common/MainRectangle.qml \
        qml/common/nodelisthelper.js \
        qml/common/NodeListView.qml \
        qml/common/ProgressDialog.qml \
        qml/common/QToDoToolBar.qml \
        qml/common/TreeView.qml \
        qml/meego/EditSketchSheet.qml \
        qml/meego/EditToDoSheet.qml \
        qml/meego/main.qml \
        qml/meego/common/CommonButton.qml \
        qml/meego/common/CommonDialog.qml \
        qml/meego/common/CommonTextArea.qml \
        qml/meego/common/CommonTextField.qml \
        qml/meego/common/CommonToolBar.qml \
        qml/meego/common/CommonToolIcon.qml \
        qml/meego/common/ConfirmationDialog.qml \
        qml/meego/common/ImapAccountSettingsSheet.qml \
        qml/qtquick2/common/AboutDialog.qml \
        qml/qtquick2/common/Drawing.qml \
        qml/qtquick2/common/EditSketchSheet.qml \
        qml/qtquick2/common/EditToDoSheet.qml \
        qml/qtquick2/common/FastScroll.js \
        qml/qtquick2/common/FastScroll.qml \
        qml/qtquick2/common/FlowListView.qml \
        qml/qtquick2/common/Header.qml \
        qml/qtquick2/common/ImapAccountSettingsSheet.qml \
        qml/qtquick2/common/MainRectangle.qml \
        qml/qtquick2/common/MessageDialog.qml \
        qml/qtquick2/common/nodelisthelper.js \
        qml/qtquick2/common/NodeListDelegate.qml \
        qml/qtquick2/common/NodeListDelegateContainer.qml \
        qml/qtquick2/common/NodeListView.qml \
        qml/qtquick2/common/ProgressDialog.qml \
        qml/qtquick2/common/QToDoToolBar.qml \
        qml/qtquick2/common/SelectionDialog.qml \
        qml/qtquick2/common/SyncDirToImap.qml \
        qml/qtquick2/common/SyncFileToImap.qml \
        qml/qtquick2/common/SyncMessageDeleter.qml \
        qml/qtquick2/common/SyncToImapBase.qml \
        qml/qtquick2/common/TreeView.qml \
        qml/qtquick2/android/main.qml \
        qml/qtquick2/android/common/MainRectangle.qml \
        qml/qtquick2/desktop/main.qml \
        qml/qtquick2/desktop/MainMenu.qml \
        qml/qtquick2/desktop/common/CommonButton.qml \
        qml/qtquick2/desktop/common/CommonDialog.qml \
        qml/qtquick2/desktop/common/CommonTextArea.qml \
        qml/qtquick2/desktop/common/CommonTextField.qml \
        qml/qtquick2/desktop/common/CommonToolIcon.qml \
        qml/qtquick2/desktop/common/ConfirmationDialog.qml \
        qml/qtquick2/desktop/common/Dialog.qml \
        qml/qtquick2/desktop/common/NodeListDelegateContainer.qml \
        qml/qtquick2/sailfish/main.qml \
        qml/qtquick2/sailfish/MainMenu.qml \
        qml/qtquick2/sailfish/common/CommonButton.qml \
        qml/qtquick2/sailfish/common/CommonDialog.qml \
        qml/qtquick2/sailfish/common/CommonTextArea.qml \
        qml/qtquick2/sailfish/common/CommonTextField.qml \
        qml/qtquick2/sailfish/common/CommonToolIcon.qml \
        qml/qtquick2/sailfish/common/ConfirmationDialog.qml \
        qml/qtquick2/sailfish/common/Dialog.qml \
        qml/qtquick2/sailfish/common/NodeListDelegateContainer.qml \
        qml/sailfish/main.qml \
        qml/sailfish/common/AboutDialog.qml \
        qml/sailfish/common/CommonButton.qml \
        qml/sailfish/common/CommonDialog.qml \
        qml/sailfish/common/CommonFlickable.qml \
        qml/sailfish/common/CommonTextArea.qml \
        qml/sailfish/common/CommonTextField.qml \
        qml/sailfish/common/CommonToolBar.qml \
        qml/sailfish/common/CommonToolIcon.qml \
        qml/sailfish/common/ConfirmationDialog.qml \
        qml/sailfish/common/MessageDialog.qml \
        qml/sailfish/common/NodeListDelegateContainer.qml \
        qml/sailfish/common/ProgressDialog.qml \
        qml/sailfish/EditToDoDialog.qml \
        qml/windows/main.qml \
        accounts_gui.sh \
        qtmail.sh \
        bar-descriptor.xml \
        qml/bb10/CommonBB10TextArea.qml \
        rpm/harbour-qtodo.yaml \
        rpm/harbour-qtodo.spec \
        harbour-qtodo.desktop

    #RESOURCES += \
    #    res.qrc

    contains(DEFINES, MER_EDITION_SAILFISH) {
        iconDeployment.source = icons
        iconDeployment.target = usr/share/harbour-qtodo/qml
        qmlCommon.target = usr/share/harbour-qtodo/qml
        syncToImapQml.target = usr/share/harbour-qtodo/qml
    } else {
        qmlCommon.target = qml
        syncToImapQml.target = qml

        iconDeployment.source = icons
        iconDeployment.target = qml

        logoFiles.files = icons/logo.png
        logoFiles.path = /opt/$${TARGET}/icons

        splash.files = splash.png
        splash.path = /opt/$${TARGET}

        sampleXml.files = sample.xml
        sampleXml.path = /opt/$${TARGET}

        licenseInfo.files = LICENSES
        licenseInfo.path = /opt/$${TARGET}

        INSTALLS += logoFiles splash licenseInfo
        #sampleXml
    }

    DEPLOYMENTFOLDERS += qmlCommon iconDeployment syncToImapQml

    # Please do not modify the following two lines. Required for deployment.
    include(deployment.pri)
    qtcAddDeployment()

    contains(DEFINES, QDECLARATIVE_BOOSTER): {
        message(Enabling qdeclarative booster.)
        CONFIG += qdeclarative-boostable
        QMAKE_CXXFLAGS += -fPIC -fvisibility=hidden -fvisibility-inlines-hidden
        QMAKE_LFLAGS += -pie -rdynamic
    }
}
