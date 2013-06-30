import QtQuick 1.1
import "../common"

Rectangle {
    anchors.fill: parent

    property int primaryFontSize: 15
    property int primaryBorderSize: 40

    Rectangle {
        anchors.fill: parent
        color: "lightgoldenrodyellow"

        Header {
            id: header
        }

        MainRectangle {
            anchors{left: parent.left; right: parent.right; top: header.bottom; bottom: toolBarItem.top}

            id: mainRectangle
        }

        Rectangle {
            id: toolBarItem
            anchors {left: parent.left; right: parent.right; bottom: parent.bottom}
            height: commonTools.height * 1.25

            color: "white"
            radius: parent.radius

            QToDoToolBar {
                id: commonTools
//                    width: parent.width

                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.right: parent.right
                anchors.rightMargin: 5
                anchors.bottom: parent.bottom
                anchors.bottomMargin: - (height - parent.height) / 2
            }
        }
    }

    Menu {
        id: mainMenu

        anchors.bottomMargin: toolBarItem.height

        onClosed: toolBarItem.enabled = true
        onOpened: toolBarItem.enabled = false

        CommonButton{
            id: cleanDone
            anchors.bottom: syncToImap.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Clean Done"
            onClicked: {
                mainRectangle.confirmCleanDoneDialog.open()
                mainMenu.close()
            }
        }

        CommonButton{
            id: syncToImap
            anchors.bottom: syncSketchesToImap.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Sync To-Do List"
            onClicked: {
                mainRectangle.confirmSyncToImapDialog.open()
                mainMenu.close()
            }
        }

        CommonButton{
            id: syncSketchesToImap
            anchors.bottom: syncAccountSettings.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Sync Sketches"
            onClicked: {
                mainRectangle.confirmSyncSketchesToImapDialog.open()
                mainMenu.close()
            }
        }

        CommonButton{
            id: syncAccountSettings
            anchors.bottom: about.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Sync Account Settings"
            onClicked: {
                imapAccountSettings.open()
                mainMenu.close()
            }
        }

        CommonButton{
            id: about
            anchors.bottom: parent.bottom
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "About"
            onClicked: {
                mainRectangle.aboutDialog.open()
                mainMenu.close()
            }
        }
    }

    Menu {
        id: contextMenu

        anchors.bottomMargin: toolBarItem.height

        onClosed: toolBarItem.enabled = true
        onOpened: toolBarItem.enabled = false

        CommonButton{
            id: moveToTopItem
            anchors.bottom: moveToBottomItem.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Move to Top"
            onClicked: {
                mainRectangle.moveCurrentItemToTop()
                contextMenu.close()
            }
        }

        CommonButton{
            id: moveToBottomItem
            anchors.bottom: editItem.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Move to Bottom"
            onClicked: {
                mainRectangle.moveCurrentItemToBottom()
                contextMenu.close()
            }
        }

        CommonButton{
            id: editItem
            anchors.bottom: deleteItem.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Edit"
            onClicked: {
                mainRectangle.editCurrentItem()
                contextMenu.close()
            }
        }

        CommonButton{
            id: deleteItem
            anchors.bottom: parent.bottom
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Delete"
            onClicked: {
                mainRectangle.deleteCurrentItem()
                contextMenu.close()
            }
        }
    }

    EditToDoSheet {
        id: editToDoItem

        onClosed: {
            mainRectangle.focus = true
        }
    }

    EditSketchSheet {
        id: editSketchItem
    }

    ImapAccountSettingsSheet {
        id: imapAccountSettings
    }
}
