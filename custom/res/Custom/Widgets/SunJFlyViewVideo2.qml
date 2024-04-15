

/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/
import QtQuick 2.12
import QtQuick.Controls 2.4
import QtMultimedia 5.8

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Controllers 1.0
import QGroundControl.ScreenTools 1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap 1.0
import QGroundControl.Palette 1.0
import QGroundControl.Vehicle 1.0

Item {
    id: _root
    visible: QGroundControl.videoManager.hasVideo

    property double _ar: QGroundControl.videoManager.aspectRatio
    property bool _showGrid: QGroundControl.settingsManager.videoSettings.gridLines.rawValue > 0
    property var _dynamicCameras: globals.activeVehicle ? globals.activeVehicle.cameraManager : null
    property int _curCameraIndex: _dynamicCameras ? _dynamicCameras.currentCamera : 0
    property bool _isCamera: _dynamicCameras ? _dynamicCameras.cameras.count > 0 : false
    property var _camera: _isCamera ? _dynamicCameras.cameras.get(
                                          _curCameraIndex) : null
    property bool _hasZoom: _camera && _camera.hasZoom
    property int _fitMode: QGroundControl.settingsManager.videoSettings.videoFit.rawValue

    property Item pipState: video2PipState
    QGCPipState {
        id: video2PipState
        pipOverlay: _pipVideo2Overlay
        isDark: true

        onWindowAboutToOpen: {
            QGroundControl.videoManager.stopVideo()
            videoStartDelay2.start()
        }

        onWindowAboutToClose: {
            QGroundControl.videoManager.stopVideo()
            videoStartDelay2.start()
        }

        onStateChanged: {
            if (pipState.state !== pipState.fullState) {
                QGroundControl.videoManager.fullScreen = false
            }
        }
    }

    Timer {
        id: videoStartDelay2
        interval: 2000
        running: false
        repeat: false
        onTriggered: QGroundControl.videoManager.startVideo()
    }

    Rectangle {
        id: noVideo2
        anchors.fill: parent
        color: Qt.rgba(1, 0, 0, 0.75)
        visible: !(QGroundControl.videoManager.decoding)
        QGCLabel {
            text: QGroundControl.settingsManager.videoSettings.streamEnabled.rawValue ? qsTr("WAITING FOR VIDEO") : qsTr("VIDEO DISABLED")
            font.family: ScreenTools.demiboldFontFamily
            color: "white"
            font.pointSize: ScreenTools.largeFontPointSize
            anchors.centerIn: parent
        }
    }

    //-- Video IP Camera widget
    Rectangle {
        // Second Camera
        anchors.fill: parent
        color: "black"
        visible: QGroundControl.videoManager.decoding
        function getWidth() {
            //-- Fit Width or Stretch
            if (_fitMode === 0 || _fitMode === 2) {
                return parent.width
            }
            //-- Fit Height
            return _ar != 0.0 ? parent.height * _ar : parent.width
        }
        function getHeight() {
            //-- Fit Height or Stretch
            if (_fitMode === 1 || _fitMode === 2) {
                return parent.height
            }
            //-- Fit Width
            return _ar != 0.0 ? parent.width * (1 / _ar) : parent.height
        }
        Component {
            id: videoBackgroundComponent2
            QGCVideoBackground {
                id: videoContent1
                objectName: "videoContent1"

                Connections {
                    target: QGroundControl.videoManager
                    function onImageFileChanged() {
                        videoContent1.grabToImage(function (result) {
                            if (!result.saveToFile(
                                        QGroundControl.videoManager.imageFile)) {
                                console.error('Error capturing video frame')
                            }
                        })
                    }
                }
                Rectangle {
                    color: Qt.rgba(1, 1, 1, 0.5)
                    height: parent.height
                    width: 1
                    x: parent.width * 0.33
                    visible: _showGrid
                             && !QGroundControl.videoManager.fullScreen
                }
                Rectangle {
                    color: Qt.rgba(1, 1, 1, 0.5)
                    height: parent.height
                    width: 1
                    x: parent.width * 0.66
                    visible: _showGrid
                             && !QGroundControl.videoManager.fullScreen
                }
                Rectangle {
                    color: Qt.rgba(1, 1, 1, 0.5)
                    width: parent.width
                    height: 1
                    y: parent.height * 0.33
                    visible: _showGrid
                             && !QGroundControl.videoManager.fullScreen
                }
                Rectangle {
                    color: Qt.rgba(1, 1, 1, 0.5)
                    width: parent.width
                    height: 1
                    y: parent.height * 0.66
                    visible: _showGrid
                             && !QGroundControl.videoManager.fullScreen
                }
            }
        }
        Loader {
            height: parent.getHeight()
            width: parent.getWidth()
            anchors.centerIn: parent
            visible: QGroundControl.videoManager.decoding
            sourceComponent: videoBackgroundComponent2

            property bool videoDisabled: QGroundControl.settingsManager.videoSettings.videoSource.rawValue === QGroundControl.settingsManager.videoSettings.disabledVideoSource
        }

        //-- Zoom
        PinchArea {
            id: pinchZoom2
            enabled: _hasZoom
            anchors.fill: parent
            onPinchStarted: pinchZoom2.zoom = 0
            onPinchUpdated: {
                var z = 0
                if (pinch.scale < 1) {
                    z = Math.round(pinch.scale * -10)
                } else {
                    z = Math.round(pinch.scale)
                }
                if (pinchZoom2.zoom != z) {
                    _camera.stepZoom(z)
                }
            }
            property int zoom: 0
        }
    }

    MouseArea {
        id: flyViewVideo2MouseArea
        anchors.fill: parent
        enabled: pipState.state === pipState.fullState
        hoverEnabled: true
    }
}
