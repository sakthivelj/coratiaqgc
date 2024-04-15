import QtQuick 2.12

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Controllers 1.0
import QGroundControl.ScreenTools 1.0

Rectangle {
    width: parent.width * 0.25
    height: width * (9 / 16)
    color: "transparent"

    //-- Oculus sonar widget
    Item {
        id: oculusSonarWidget
        anchors.fill: parent
        objectName: "oculusCustomWidget"
        x: parent.x
        y: parent.y
    }
}
