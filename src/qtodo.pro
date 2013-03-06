# Add more folders to ship with the application, here

exists($$QMAKE_INCDIR_QT"/../applauncherd/MDeclarativeCache"): {
    MEEGO_VERSION_MAJOR     = 1
    MEEGO_VERSION_MINOR     = 2
    MEEGO_VERSION_PATCH     = 0
    MEEGO_EDITION           = harmattan

    DEFINES += MEEGO_EDITION_HARMATTAN

    # enable booster
    CONFIG += qdeclarative-boostable
    QMAKE_CXXFLAGS += -fPIC -fvisibility=hidden -fvisibility-inlines-hidden
    QMAKE_LFLAGS += -pie -rdynamic
}

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

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
    filehelper.h

SOURCES += main.cpp \
    todostorage.cpp \
    nodelistmodel.cpp \
    filehelper.cpp

OTHER_FILES += \
    qml/main.qml \
    qtodo.desktop \
    qtodo.svg \
    qtodo.png \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog \
    qml/NodeListView.qml \
    qml/nodelisthelper.js \
    qml/TreeView.qml \
    qml/EditToDoSheet.qml \
    qml/AboutDialog.qml \
    qml/FlowListView.qml

#RESOURCES += \
#    res.qrc

jsFiles.path = /opt/$${TARGET}/qml
jsFiles.files = qml/*.js

qmlFiles.path = /opt/$${TARGET}/qml
qmlFiles.files = qml/*.qml

iconFiles.path = /opt/$${TARGET}/icons
iconFiles.files = icons/*

logoFiles.path = /opt/$${TARGET}/icons
logoFiles.files = icons/logo.png

sampleXml.path = /opt/$${TARGET}
sampleXml.files = sample.xml

INSTALLS += iconFiles jsFiles qmlFiles logoFiles
#sampleXml

# Please do not modify the following two lines. Required for deployment.
include(deployment.pri)
qtcAddDeployment()

splash.files = splash.png
splash.path = /opt/qtodo
INSTALLS += splash
