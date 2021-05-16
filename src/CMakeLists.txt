cmake_minimum_required(VERSION 3.14)

project(qtodo VERSION 1.12.2 LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# QtCreator supports the following variables for Android, which are identical to qmake Android variables.
# Check https://doc.qt.io/qt/deployment-android.html for more information.
# They need to be set before the find_package(...) calls below.

#if(ANDROID)
#    set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
#    if (ANDROID_ABI STREQUAL "armeabi-v7a")
#        set(ANDROID_EXTRA_LIBS
#            ${CMAKE_CURRENT_SOURCE_DIR}/path/to/libcrypto.so
#            ${CMAKE_CURRENT_SOURCE_DIR}/path/to/libssl.so)
#    endif()
#endif()

find_package(QT NAMES Qt6 Qt5 COMPONENTS Core Quick REQUIRED)
find_package(Qt${QT_VERSION_MAJOR} COMPONENTS Core Quick REQUIRED)
find_package(Qt6 COMPONENTS Xml REQUIRED)

set(PROJECT_SOURCES
        main-qt6.cpp
        filehelper.cpp
        filehelper.h
        merger.h
        merger.cpp
        nodelistmodel.h
        nodelistmodel.cpp
        todostorage.h
        todostorage.cpp
)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    message("Building for Qt6...")
    if(ANDROID)
        message("Building for Android...")
        qt_add_executable(qtodo
            MANUAL_FINALIZATION
            ${PROJECT_SOURCES}
            android.qrc
        )
    else()
        message("Building for default platform...")
        qt_add_executable(qtodo
            MANUAL_FINALIZATION
            ${PROJECT_SOURCES}
            qml_desktop.qrc
        )
    endif()
else()
    if(ANDROID)
        add_library(qtodo SHARED
            ${PROJECT_SOURCES}
        )
    else()
        add_executable(qtodo
          ${PROJECT_SOURCES}
          qml_desktop.qrc
        )
    endif()
endif()

target_compile_definitions(qtodo
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(qtodo
  PRIVATE Qt${QT_VERSION_MAJOR}::Core Qt${QT_VERSION_MAJOR}::Quick)
target_link_libraries(qtodo PRIVATE Qt6::Xml)

set_target_properties(qtodo PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
)

if(QT_VERSION_MAJOR EQUAL 6)
    qt_import_qml_plugins(qtodo)
    qt_finalize_executable(qtodo)
endif()
