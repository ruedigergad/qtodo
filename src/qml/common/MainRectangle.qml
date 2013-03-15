import QtQuick 1.1
import qtodo 1.0

Rectangle{
    id: mainRectangle

    anchors.fill: parent
    color: "lightgoldenrodyellow"

    function editSelectedItem() {
        var currentItem = treeView.currentItem
        if (currentItem.type === "sketch") {
            editSketchSheet.sketchPath = currentItem.text
            editSketchSheet.edit = true
            editSketchSheet.open()
        } else {
            editToDoSheet.color = currentItem.itemColor
            editToDoSheet.type = currentItem.type
            editToDoSheet.text = currentItem.text
            editToDoSheet.edit = true
            editToDoSheet.open()
        }
    }

    Rectangle {
        id: header
        height: 72
        color: "#0c61a8"
        anchors{left: parent.left; right: parent.right; top: parent.top}
        z: 48

        Text {
            text: "My To-Dos"
            color: "white"
            font{pixelSize: 32; family: "Nokia Pure Text Light"}
            anchors{left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter}
        }
    }

    TreeView {
        id: treeView
        anchors{left: parent.left; right: parent.right; bottom: parent.bottom; top: header.bottom}
        model: rootElementModel
        color: parent.color

        onCurrentItemChanged: {
            console.log(currentItem.type)
            if(currentItem === null) {
                iconMarkDone.enabled = false
            }else{
                iconMarkDone.enabled = currentItem.type === "to-do"
            }
        }
        onDoubleClicked: editSelectedItem()
        onPressAndHold: contextMenu.open()
    }

    AboutDialog {
        id: aboutDialog
    }

    ConfirmationDialog {
        id: confirmDeleteDialog

        titleText: "Delete?"

        onAccepted: {
            var currentItem = treeView.currentItem
            if (currentItem.type === "sketch") {
                fileHelper.rm(currentItem.text)
            }
            treeView.currentModel.deleteElement(treeView.currentIndex)
        }
    }

    FileHelper { id: fileHelper }

    NodeListModel {
        id: rootElementModel
    }

    ToDoStorage {
        id: storage

        onDocumentOpened: {
            console.log("Document opened.")
            rootElementModel.setRoot(storage);
        }
    }

    Component.onCompleted: {
        storage.open()
//        storage.open("/opt/qtodo/sample.xml")

        iconMarkDone.enabled = false
    }
}


