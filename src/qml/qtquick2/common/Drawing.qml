/*
 * This file had been initally taken from:
 * https://qt.gitorious.org/qt-labs/qmlcanvas/trees/master/examples/painting
 *
 * Update 2021-05-16, the link above seems to be dead.
 * In the meantime, Canvas was added to QtQuick and this file was largely reworked.
 * Thus, this file is now also released under the terms of the GPLv3, like the rest of qtodo.
 */

import QtQuick 2.15

Canvas {
    id: canvas

    property int paintX
    property int paintY
    property string path: ""
    property int lineWidth: 2
    property string drawColor: "black"
    property string backgroundColor: "white"

    MouseArea {
        id:mousearea
        hoverEnabled:true
        anchors.fill: parent

        onPressed: {
            paintX = mouseX;
            paintY = mouseY;
        }
        onPositionChanged:  {
            if (mousearea.pressed)
                drawLine(paintX, paintY, mouseX, mouseY);
            paintX = mouseX;
            paintY = mouseY;
        }
    }

    function drawLine(x1, y1, x2, y2) {
        context.beginPath();
        context.strokeStyle = drawColor
        context.lineWidth = lineWidth
        context.moveTo(x1, y1);
        context.lineTo(x2, y2);
        context.stroke();
        context.closePath();
        requestPaint()
    }

    function clear() {
        getContext("2d")
        context.fillStyle = backgroundColor
        context.fillRect(0, 0, width, height);
        context.fillStyle = drawColor
    }

    onImageLoaded: {
        console.log("Image loaded. Drawing to canvas: " + path)
        context.drawImage("file:/" + path, 0, 0, width, height)
        unloadImage("file:/" + path)
        requestPaint()
    }

    function load(path) {
        console.log("Loading existing image for editing: " + path)
        canvas.path = path
        clear()
        if (isImageLoaded("file:/" + path)) {
            imageLoaded()
        } else {
            loadImage("file:/" + path)
        }
    }
    function init(){
        clear()
        requestPaint()
    }
}
