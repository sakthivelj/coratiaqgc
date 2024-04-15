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

import QtQuick              2.11
import QtGraphicalEffects   1.0

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0
import QGroundControl.FlightMap     1.0

Item {
    id: root

    property bool isPitch:    true
    property var  vehicle:      null
    property real size
    property bool showHeading:  false

    property real _rollAngle:   vehicle ? vehicle.roll.rawValue.toFixed(2)  : 0.0
    property real _pitchAngle:  vehicle ? vehicle.pitch.rawValue.toFixed(2) : 0.0

    width:  size
    height: size

    Item {
        id:             instrument
        // visible:        false

        //----------------------------------------------------
        //-- Instrument Dial
        Image {
            id:                 instrumentDial
            source:             isPitch ? "/custom/img/pitch.svg" : "/custom/img/roll.svg"
            fillMode:           Image.PreserveAspectFit
            sourceSize.height:  size
        }

        Image {
            id:                 instrumentNeedle
            source:             isPitch ? "/custom/img/pitch_needle.svg" : "/custom/img/roll_needle.svg"
            fillMode:           Image.PreserveAspectFit
            sourceSize.height:  size
            anchors.bottom:     instrumentDial.bottom

            transform: Rotation {
                origin.x:       instrumentNeedle.x + instrumentNeedle.width / 2 - _toolsMargin * 1.5
                origin.y:       instrumentNeedle.height - _toolsMargin * 5
                angle:          isPitch ? _pitchAngle : _rollAngle
            }
        }

        Rectangle {
            width:                      textAttitude.width +  ScreenTools.defaultFontPixelWidth
            height:                     textAttitude.height
            anchors.bottom:             instrumentDial.bottom
            anchors.horizontalCenter:   instrumentDial.horizontalCenter
            anchors.bottomMargin:       _toolsMargin * -5
            radius:                     2
            color:                      qgcPal.windowShade

            QGCLabel {
                id:                 textAttitude
                text:               isPitch ? _pitchAngle + ' °' : _rollAngle + ' °'
                font.family:        vehicle ? ScreenTools.demiboldFontFamily : ScreenTools.normalFontFamily
                font.pointSize:     8
                color:              qgcPal.text
                anchors.centerIn:   parent
            }
        }
    }

    Rectangle {
        id:             mask
        anchors.fill:   instrument
        color:          "black"
        visible:        false
    }

    OpacityMask {
        anchors.fill:   instrument
        source:         instrument
        maskSource:     mask
    }
}
