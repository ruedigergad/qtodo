/*
 * This file had been taken from the painting example in qmlcanvas.
 * At the time this file was taken there was no license attached 
 * to any of the files in the painting example.
 * 
 * The only changes made were to adjust the imports.
 * You can find the original version at:
 * https://qt.gitorious.org/qt-labs/qmlcanvas/trees/master/examples/painting
 */

import qmlcanvas 1.0
import QtQuick 1.1


Canvas {
    id:canvas
    color: "white"
    property int paintX
    property int paintY
    property int count: 0
    property int lineWidth: 2
    property variant drawColor: "black"
    property variant ctx: getContext("2d");

    MouseArea {
        id:mousearea
        hoverEnabled:true
        anchors.fill: parent
        onClicked: drawPoint();
        onPositionChanged:  {
            if (mousearea.pressed)
                drawLineSegment();
            paintX = mouseX;
            paintY = mouseY;
        }
    }

    function drawLineSegment() {
        ctx.beginPath();
        ctx.strokeStyle = drawColor
        ctx.lineWidth = lineWidth
        ctx.moveTo(paintX, paintY);
        ctx.lineTo(mousearea.mouseX, mousearea.mouseY);
        ctx.stroke();
        ctx.closePath();
    }

    function drawPoint() {
        ctx.lineWidth = lineWidth
        ctx.fillStyle = drawColor
        ctx.fillRect(mousearea.mouseX, mousearea.mouseY, 2, 2);
    }

    function clear() {
        ctx.clearRect(0, 0, width, height);
    }
}
