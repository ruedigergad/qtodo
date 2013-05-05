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
 */

import qmlcanvas 1.0
import QtQuick 1.1

Canvas {
    id: canvas
    color: "white"
    property int paintX
    property int paintY
    property int count: 0
    property int lineWidth: 2
    property string drawColor: "black"
    property string backgroundColor: "white"
    property variant ctx

    MouseArea {
        id:mousearea
        hoverEnabled:true
        anchors.fill: parent
        onClicked: drawPoint();
        onPositionChanged:  {
            if (mousearea.pressed)
                drawLine(paintX, paintY, mousearea.mouseX, mousearea.mouseY);
            paintX = mouseX;
            paintY = mouseY;
        }
    }

    function drawLine(x1, y1, x2, y2) {
        ctx.beginPath();
        ctx.strokeStyle = drawColor
        ctx.lineWidth = lineWidth
        ctx.moveTo(x1, y1);
        ctx.lineTo(x2, y2);
        ctx.stroke();
        ctx.closePath();
    }

    function drawPoint() {
        ctx.lineWidth = lineWidth
        ctx.fillStyle = drawColor
        ctx.fillRect(mousearea.mouseX, mousearea.mouseY, 2, 2);
    }

    function clear() {
        ctx.fillStyle = backgroundColor
        ctx.fillRect(0, 0, width, height);
        ctx.fillStyle = drawColor
    }

    // Added by Ruediger Gad
    // Code comes without warranty but is free for use without any further requirements.
    function load(path) {
        ctx = getContext("2d")
        var img = ctx.createImage(path)
        ctx.drawImage(img, 0, 0, width, height)
    }
    function init(){
        ctx = getContext("2d")
        clear()
        ctx.lineWidth = 1
        ctx.strokeStyle = "salmon"
        var gap = 3
        ctx.strokeRect(gap, gap, width - (2*gap), height - (2*gap));
    }
}
