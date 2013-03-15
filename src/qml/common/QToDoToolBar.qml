import QtQuick 1.1

CommonToolBar {
    id: toolBar

    CommonToolIcon {
        id: iconAdd
        platformIconId: "toolbar-add"
        text: "+"
        opacity: enabled ? 1 : 0.5
        onClicked: {
            editToDoSheet.color = "blue"
            editToDoSheet.type = "to-do"
            editToDoSheet.text = ""
            editToDoSheet.edit = false
            editToDoSheet.open()
        }
    }
    CommonToolIcon {
        id: iconSketch
        iconSource: "../icons/sketch.png"
        opacity: enabled ? 1 : 0.5
        onClicked: {
            editSketchSheet.edit = false
            editSketchSheet.sketchPath = storage.getPath() + "/sketches/" + (rootElementModel.getMaxId() + 1) + ".png"
            editSketchSheet.open()
        }
    }
    CommonToolIcon {
        id: iconMarkDone
        platformIconId: "toolbar-done"
        text: "Done"
        enabled: mainRectangle.treeView.currentItem.type === "to-do"
        opacity: enabled ? 1 : 0.5
        onClicked: {
            if(mainRectangle.treeView.currentItem.done){
                mainRectangle.treeView.currentModel.setAttribute(mainRectangle.treeView.currentIndex, "done", "false")
            }else{
                mainRectangle.treeView.currentModel.setAttribute(mainRectangle.treeView.currentIndex, "done", "true")
            }
        }
    }
    CommonToolIcon {
        id: iconDelete
        platformIconId: "toolbar-delete"
        text: "Del"
        enabled: mainRectangle.treeView.currentIndex >= 0
        opacity: enabled ? 1 : 0.5
        onClicked: {
            mainRectangle.confirmDeleteDialog.message = "Delete \"" + mainRectangle.treeView.currentItem.text + "\"?"
            mainRectangle.confirmDeleteDialog.open()
        }
    }
    CommonToolIcon {
        id: iconBack
        iconSource: "../icons/back.png"
        enabled: mainRectangle.treeView.currentLevel > 0
        opacity: enabled ? 1 : 0.5
        onClicked: mainRectangle.treeView.currentLevel--
    }
    CommonToolIcon {
        id: iconMenu
        platformIconId: "toolbar-view-menu"
        text: "Menu"
        anchors.right: parent === undefined ? undefined : parent.right
        onClicked: myMenu.status === DialogStatus.Closed ? myMenu.open() : myMenu.close()
        opacity: enabled ? 1 : 0.5
    }
}
