/*
 * This file had been initally taken from the painting example in qmlcanvas.
 * At the time this file was taken there was no license attached 
 * to any of the files in the painting example.
 * 
 * Changes (by Ruediger Gad) include the adaptation of the import statements
 * the addition of the load function, or the introduction of the
 * backgroundColor property.
 * These changes come without any warranty and are free for use 
 * without any further requirements.
 *
 * You can find the original version at:
 * https://qt.gitorious.org/qt-labs/qmlcanvas/trees/master/examples/painting
 *
 * PS: Update 2021-05-16, the link above seems to be dead.
 * This implementation was upated to use QtQuick Canvas.
 */

import QtQuick 2.15

Canvas {
    id: canvas
    //color: "white"
    property int paintX
    property int paintY
    property int count: 0
    property int lineWidth: 2
    property string drawColor: "black"
    property string backgroundColor: "white"

    MouseArea {
        id:mousearea
        hoverEnabled:true
        anchors.fill: parent
        onClicked: drawPoint();
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

    function drawPoint() {
        context.lineWidth = lineWidth
        context.fillStyle = drawColor
        context.fillRect(mousearea.mouseX, mousearea.mouseY, 2, 2);
        requestPaint()
    }

    function clear() {
        getContext("2d")
        context.fillStyle = backgroundColor
        context.fillRect(0, 0, width, height);
        context.fillStyle = drawColor
    }

    // Added by Ruediger Gad
    // Code comes without warranty but is free for use without any further requirements.
    property string path: ""
    onImageLoaded: {
        console.log("Image loaded. Drawing to canvas: " + path)
        context.drawImage("file:/" + path, 0, 0, width, height)
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
        context.lineWidth = 1
        context.strokeStyle = "salmon"
        var gap = 3
        context.strokeRect(gap, gap, width - (2*gap), height - (2*gap));
    }
}
