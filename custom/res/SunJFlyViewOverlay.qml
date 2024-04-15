

/****************************************************************************
 *
 * (c) 2009-2019 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 * @file
 *   @author Gus Grubba <gus@auterion.com>
 */
import QtQuick 2.12
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0

import Custom.Widgets 1.0

Item {
    property var parentToolInsets
    // These insets tell you what screen real estate is available for positioning the controls in your overlay
    property var totalToolInsets: _totalToolInsets // The insets updated for the custom overlay additions
    property var mapControl

    readonly property string noGPS: qsTr("NO GPS")
    readonly property real indicatorValueWidth: ScreenTools.defaultFontPixelWidth * 7

    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property real _indicatorDiameter: ScreenTools.defaultFontPixelWidth * 18
    property real _indicatorsHeight: ScreenTools.defaultFontPixelHeight
    property color _indicatorsColor: qgcPal.text
    property real _heading: _activeVehicle ? _activeVehicle.heading.rawValue : 0
    property string _altitude: _activeVehicle ? (isNaN(
                                                     _activeVehicle.altitudeRelative.value) ? "0.0" : _activeVehicle.altitudeRelative.value.toFixed(1)) + ' ' + _activeVehicle.altitudeRelative.units : "0.0"
    property real _toolsMargin: ScreenTools.defaultFontPixelWidth * 0.75
    property bool _setVisible: _activeVehicle ? true : false

    QGCToolInsets {
        id: _totalToolInsets
        topEdgeCenterInset: headingNeedle.y + headingNeedle.height
        leftEdgeBottomInset: parent.width // - compassIndicator.x
    }

    //-------------------------------------------------------------------------
    Item {
        // Compass
        id: compassIndicator
        anchors.bottomMargin: _toolsMargin
        anchors.leftMargin: _pipOverlay.visible ? parent.width * 0.25 : _toolsMargin
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        height: _indicatorsHeight * 10
        width: height

        Image {
            id: indicator
            anchors.centerIn: compassIndicator
            height: compassIndicator.height - _toolsMargin * 2
            width: height
            source: "/custom/img/compass_background.svg"
            fillMode: Image.PreserveAspectFit
            sourceSize.height: height
        }

        Image {
            id: headingNeedle
            anchors.centerIn: indicator
            height: indicator.height * 0.6
            width: height * 1.2
            source: "/custom/img/compass_needle.svg"
            mipmap: true
            fillMode: Image.PreserveAspectFit
            sourceSize.height: height
            sourceSize.width: width
            transform: [
                Rotation {
                    origin.x: headingNeedle.width / 2
                    origin.y: headingNeedle.height / 2
                    angle: QGroundControl.settingsManager.flyViewSettings.lockNoseUpCompass.value ? 0 : _heading
                }
            ]
        }

        Rectangle {
            anchors.centerIn: parent
            width: ScreenTools.defaultFontPixelHeight * 2.5
            height: ScreenTools.defaultFontPixelHeight
            radius: 2
            color: qgcPal.windowShade
            z: headingNeedle.z - 1

            QGCLabel {
                text: _headingString3
                font.family: _activeVehicle ? ScreenTools.demiboldFontFamily : ScreenTools.normalFontFamily
                font.pointSize: 8
                color: qgcPal.text
                anchors.centerIn: parent

                property string _headingString: _activeVehicle ? _heading.toFixed(
                                                                     0) : "OFF"
                property string _headingString2: _headingString.length
                                                 === 1 ? "0" + _headingString : _headingString
                property string _headingString3: _headingString2.length
                                                 === 2 ? "0" + _headingString2 : _headingString2
            }
        }
    }

    CustomAttitudeWidget {
        // Pitch indicator
        id: _pitch
        isPitch: true
        anchors.topMargin: _toolsMargin * 2
        anchors.rightMargin: ScreenTools.defaultFontPixelHeight * 8
        anchors.top: parent.top
        anchors.right: parent.right
        size: ScreenTools.defaultFontPixelHeight * 10
        vehicle: _activeVehicle
        visible: _setVisible
    }

    CustomAttitudeWidget {
        // Roll indicator
        id: _roll
        isPitch: false
        anchors.topMargin: _toolsMargin * 10
        anchors.leftMargin: _toolsMargin * 14
        anchors.top: parent.top
        anchors.left: parent.left
        size: ScreenTools.defaultFontPixelHeight * 10
        vehicle: _activeVehicle
        visible: _setVisible
    }

    Rectangle {
        // Depth indicator
        width: altitude.width + _toolsMargin * 2
        height: ScreenTools.defaultFontPixelHeight * 2
        color: qgcPal.window
        radius: ScreenTools.defaultFontPixelWidth / 2
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: _toolsMargin * 2
        visible:  _setVisible

        Text {
            id: altitude
            text: qsTr("Depth ") + _altitude
            anchors.centerIn: parent
            font.family: _activeVehicle ? ScreenTools.demiboldFontFamily : ScreenTools.normalFontFamily
            font.pointSize: 12
            color: qgcPal.text
        }
    }
}
