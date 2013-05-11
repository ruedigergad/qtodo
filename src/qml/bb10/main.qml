import QtQuick 1.1
import "../common"

Rectangle {
    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "lightgoldenrodyellow"

        Header {
            id: header
            height: 72
        }

        MainRectangle {
            anchors{left: parent.left; right: parent.right; top: header.bottom; bottom: toolBarItem.top}

            id: mainRectangle

            Component.onCompleted: {
                treeView.fontPixelSize = 80
            }
        }

        Rectangle {
            id: toolBarItem
            anchors {left: parent.left; right: parent.right; bottom: parent.bottom}
            height: commonTools.height

            property int minWidth: commonTools.minWidth + resizeItem.width + 20

            color: "lightgray"
            radius: parent.radius

            QToDoToolBar {
                id: commonTools
            }
        }
    }

    Menu {
        id: mainMenu

        CommonButton{
            id: cleanDone
            anchors.bottom: syncToImap.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            text: "Clean Done"
            onClicked: {
                mainRectangle.confirmCleanDoneDialog.open()
                mainMenu.close()
            }
        }

        CommonButton{
            id: syncToImap
            anchors.bottom: syncSketchesToImap.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            text: "Sync to IMAP"
            onClicked: {
                mainRectangle.confirmSyncToImapDialog.open()
                mainMenu.close()
            }
        }

        CommonButton{
            id: syncSketchesToImap
            anchors.bottom: about.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            text: "Sync Sketches to IMAP"
            onClicked: {
                mainRectangle.confirmSyncSketchesToImapDialog.open()
                mainMenu.close()
            }
        }

        CommonButton{
            id: about
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            text: "About"
            onClicked: {
                mainRectangle.aboutDialog.open()
                mainMenu.close()
            }
        }
    }

    Menu {
        id: contextMenu

        CommonButton{
            id: moveToTopItem
            anchors.bottom: moveToBottomItem.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            text: "Move to Top"
            onClicked: {
                mainRectangle.moveCurrentItemToTop()
                contextMenu.close()
            }
        }

        CommonButton{
            id: moveToBottomItem
            anchors.bottom: editItem.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            text: "Move to Bottom"
            onClicked: {
                mainRectangle.moveCurrentItemToBottom()
                contextMenu.close()
            }
        }

        CommonButton{
            id: editItem
            anchors.bottom: deleteItem.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            text: "Edit"
            onClicked: {
                mainRectangle.editCurrentItem()
                contextMenu.close()
            }
        }

        CommonButton{
            id: deleteItem
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
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
}
