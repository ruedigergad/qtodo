# Add more folders to ship with the application, here

qmlCommon.source = qml/common
qmlCommon.target = qml

iconDeployment.source = icons
iconDeployment.target = qml

DEPLOYMENTFOLDERS += qmlCommon iconDeployment

load(sailfishsilicabackground)
contains(LIBS,-lsailfishsilicabackground): {
    message(SailfishOS build)

    DEFINES += MER_EDITION_SAILFISH
    MER_EDITION = sailfish

    qmlSailfish.source = qml/sailfish
    qmlSailfish.target = qml

    qmlSailfishCommon.source = qml/sailfish/common
    qmlSailfishCommon.target = qml

    DEPLOYMENTFOLDERS += qmlSailfish qmlSailfishCommon
} else:exists($$QMAKE_INCDIR_QT"/../applauncherd/MDeclarativeCache"): {
    message(MeeGo/Harmattan build)
    MEEGO_VERSION_MAJOR     = 1
    MEEGO_VERSION_MINOR     = 2
    MEEGO_VERSION_PATCH     = 0
    MEEGO_EDITION           = harmattan

    DEFINES += MEEGO_EDITION_HARMATTAN

    qmlMeego.source = qml/meego
    qmlMeego.target = qml

    qmlMeegoCommon.source = qml/meego/common
    qmlMeegoCommon.target = qml

    DEPLOYMENTFOLDERS += qmlMeego qmlMeegoCommon
} else {
    message(Desktop build)
    qmlDesktop.source = qml/desktop
    qmlDesktop.target = qml

    qmlDesktopCommon.source = qml/desktop/common
    qmlDesktopCommon.target = qml

    # TODO: Dynamically determine architecture.
    arch = x86_64
    os = linux
    qmlCanvasImport.source = lib/build/$${os}/$${arch}/qmlcanvas
    qmlCanvasImport.target = lib/imports
    qmfLibs.source = lib/build/$${os}/$${arch}/qmf
    qmfLibs.target = lib

    DEPLOYMENTFOLDERS += qmlDesktop qmlDesktopCommon qmlCanvasImport qmfLibs
    QML_IMPORT_PATH += lib/build/linux/x86_64

    wrapperScript.source = qtodo.sh
    wrapperScript.target = /opt/$${TARGET}/bin
    INSTALLS += wrapperScript
}

CONFIG += link_pkgconfig
PKGCONFIG += qmfclient

QT+= declarative xml
symbian:TARGET.UID3 = 0xE1CCA219

# Smart Installer package's UID
# This UID is from the protected range and therefore the package will
# fail to install if self-signed. By default qmake uses the unprotected
# range value if unprotected UID is defined for the application and
# 0x2002CCCF value if protected UID is given to the application
#symbian:DEPLOYMENT.installer_header = 0x2002CCCF

# Allow network access on Symbian
symbian:TARGET.CAPABILITY += NetworkServices

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
# CONFIG += mobility
# MOBILITY +=
# QT += opengl

HEADERS += \
    todostorage.h \
    nodelistmodel.h \
    filehelper.h \
    imapstorage.h \
    merger.h

SOURCES += main.cpp \
    todostorage.cpp \
    nodelistmodel.cpp \
    filehelper.cpp \
    imapstorage.cpp \
    merger.cpp

OTHER_FILES += \
    qtodo.desktop \
    qtodo.svg \
    qtodo.png \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog \
    qml/common/AboutDialog.qml \
    qml/common/Drawing.qml \
    qml/common/FlowListView.qml \
    qml/common/MainRectangle.qml \
    qml/common/nodelisthelper.js \
    qml/common/NodeListView.qml \
    qml/common/ProgressDialog.qml \
    qml/common/QToDoToolBar.qml \
    qml/common/TreeView.qml \
    qml/desktop/EditToDoSheet.qml \
    qml/desktop/main.qml \
    qml/desktop/Menu.qml \
    qml/desktop/common/CommonButton.qml \
    qml/desktop/common/CommonDialog.qml \
    qml/desktop/common/CommonTextArea.qml \
    qml/desktop/common/CommonTextField.qml \
    qml/desktop/common/CommonToolBar.qml \
    qml/desktop/common/CommonToolIcon.qml \
    qml/desktop/common/ConfirmationDialog.qml \
    qml/desktop/common/Dialog.qml \
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
    qml/sailfish/main.qml \
    qml/sailfish/common/CommonButton.qml \
    qml/sailfish/common/CommonDialog.qml \
    qml/sailfish/common/CommonTextArea.qml \
    qml/sailfish/common/CommonTextField.qml \
    qml/sailfish/common/CommonToolBar.qml \
    qml/sailfish/common/CommonToolIcon.qml \
    qml/sailfish/common/ConfirmationDialog.qml \
    qml/sailfish/common/CommonFlickable.qml \
    qml/sailfish/EditToDoDialog.qml



#RESOURCES += \
#    res.qrc

logoFiles.files = icons/logo.png
logoFiles.path = /opt/$${TARGET}/icons

splash.files = splash.png
splash.path = /opt/$${TARGET}

sampleXml.files = sample.xml
sampleXml.path = /opt/$${TARGET}

INSTALLS += logoFiles splash
#sampleXml

# Please do not modify the following two lines. Required for deployment.
include(deployment.pri)
qtcAddDeployment()

exists($$QMAKE_INCDIR_QT"/../applauncherd/MDeclarativeCache"): {
    CONFIG += qdeclarative-boostable
    QMAKE_CXXFLAGS += -fPIC -fvisibility=hidden -fvisibility-inlines-hidden
    QMAKE_LFLAGS += -pie -rdynamic
}
