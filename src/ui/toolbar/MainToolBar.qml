/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.12
import QtQuick.Controls 2.4
import QtQuick.Layouts  1.11
import QtQuick.Dialogs  1.3

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.Palette               1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Controllers           1.0

Rectangle {
    id:     _root
    color:  qgcPal.toolbarBackground

    property int currentToolbar: flyViewToolbar

    readonly property int flyViewToolbar:   0
    readonly property int planViewToolbar:  1
    readonly property int simpleToolbar:    2

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property bool   _communicationLost: _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property color  _mainStatusBGColor: qgcPal.brandingPurple

    QGCPalette { id: qgcPal }

    /// Bottom single pixel divider
    Rectangle {
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        height:         1
        color:          "black"
        visible:        qgcPal.globalTheme === QGCPalette.Light
    }

    Rectangle {
        anchors.fill:   viewButtonRow
        visible:        currentToolbar === flyViewToolbar

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0;                                     color: _mainStatusBGColor }
            GradientStop { position: currentButton.x + currentButton.width; color: _mainStatusBGColor }
            GradientStop { position: 1;                                     color: _root.color }
        }
    }

    RowLayout {
        id:                     viewButtonRow
        anchors.bottomMargin:   1
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        spacing:                ScreenTools.defaultFontPixelWidth / 2

        QGCToolBarButton {
            id:                     currentButton
            Layout.preferredHeight: viewButtonRow.height
            icon.source:            "/res/QGCLogoFull"
            logo:                   true
            onClicked:              mainWindow.showToolSelectDialog()
        }

        MainStatusIndicator {
            Layout.preferredHeight: viewButtonRow.height
            visible:                currentToolbar === flyViewToolbar
        }

        QGCButton {
            id:                 disconnectButton
            text:               qsTr("Disconnect")
            onClicked:          _activeVehicle.closeVehicle()
            visible:            _activeVehicle && _communicationLost && currentToolbar === flyViewToolbar
        }
    }

    QGCFlickable {
        id:                     toolsFlickable
        anchors.leftMargin:     ScreenTools.defaultFontPixelWidth * ScreenTools.largeFontPointRatio * 1.5
        anchors.left:           viewButtonRow.right
        anchors.bottomMargin:   1
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.right:          parent.right
        contentWidth:           indicatorLoader.x + indicatorLoader.width
        flickableDirection:     Flickable.HorizontalFlick

        Loader {
            id:                 indicatorLoader
            anchors.left:       parent.left
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            source:             currentToolbar === flyViewToolbar ?
                                    "qrc:/toolbar/MainToolBarIndicators.qml" :
                                    (currentToolbar == planViewToolbar ? "qrc:/qml/PlanToolBarIndicators.qml" : "")
        }
    }

    //------------------------------------------------------------------------
    //-- Custom branding by Mamy

    Rectangle {
        x: toolsFlickable.x + toolsFlickable.contentWidth + ScreenTools.defaultFontPixelWidth * 10
        width: brandInput.width + brand.width
        height: parent.height
        color : "transparent"
        visible: _activeVehicle

        Row {
            spacing: 5
            anchors.centerIn: parent
            TextField {
                id: brandInput
                width: ScreenTools.defaultFontPixel*10
                placeholderText: "Space to enter text"
                visible: false
                onTextChanged: brand.text = text
                Keys.onReturnPressed: {
                    // Hide the text input form when user hits `Enter` key
                    brandInput.visible = false
                    QGroundControl.saveGlobalSetting("CustomName", text)
                }
            }
            Text {
                id: brand
                text: QGroundControl.loadGlobalSetting("CustomName", "SUN-J")
                anchors.verticalCenter: parent.verticalCenter
                color: "white"

                MouseArea {
                    anchors.fill: parent
                    onDoubleClicked: {
                        // Show the text input form when user double-clicks the text
                        brandInput.visible = true
                        uploadBtn.visible = !brandInput.visible
                    }
                }
            }
            Button {
                id: uploadBtn
                text: qsTr("Upload logo")
                visible: false
                onClicked: fileDialog.open()
            }
        }
    }
    FileDialog {
        id: fileDialog
        title: qsTr("Choose a logo")
        folder: shortcuts.home
        nameFilters: ["Image files (*.png *.jpg *.bmp)"]
        signal updateCustomLogo(string uri)

        onAccepted: {
            updateCustomLogo(fileDialog.fileUrl.toString());
            uploadBtn.visible = false // Hide the upload form when user picks a logo
            QGroundControl.saveGlobalSetting("CustomLogo", fileDialog.fileUrl.toString());
        }

        onRejected: {
            console.log("File selection cancelled");
        }
    }
    Image {
        id:                     permanentLogo
        anchors.right:          brandingLogo.left
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.margins:        ScreenTools.defaultFontPixelHeight * 0.66
        anchors.rightMargin:    ScreenTools.defaultFontPixelHeight * 6
        visible:                currentToolbar !== planViewToolbar && _activeVehicle && !_communicationLost && x > (toolsFlickable.x + toolsFlickable.contentWidth + ScreenTools.defaultFontPixelWidth)
        fillMode:               Image.PreserveAspectFit
        source:                 "/custom/img/ct_logo.png"
        mipmap:                 true
    }

    //-------------------------------------------------------------------------
    //-- Branding Logo
    Image {
        id:                     brandingLogo
        anchors.right:          parent.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.margins:        ScreenTools.defaultFontPixelHeight * 0.66
        visible:                currentToolbar !== planViewToolbar && _activeVehicle && !_communicationLost && x > (toolsFlickable.x + toolsFlickable.contentWidth + ScreenTools.defaultFontPixelWidth)
        fillMode:               Image.PreserveAspectFit
        source:                 _brandImage
        mipmap:                 true

        property string _brandImage:            brandImage()

        // Initialize the branding logo with the default image or the last stored image
        function brandImage() {
            var defaultLogo = _activeVehicle ? _activeVehicle.brandImageIndoor : "";
            return QGroundControl.loadGlobalSetting("CustomLogo", defaultLogo);
        }

        // Update branding logo with the user picked image
        Connections {
            target: fileDialog
            onUpdateCustomLogo: brandingLogo.source = fileDialog.fileUrl.toString()
        }

        MouseArea {
            anchors.fill: parent
            onDoubleClicked: {
                // Show the logo upload form when user double-clicks the logo
                uploadBtn.visible = true
                brandInput.visible = !uploadBtn.visible
            }
        }
    }

    // Small parameter download progress bar
    Rectangle {
        anchors.bottom: parent.bottom
        height:         _root.height * 0.05
        width:          _activeVehicle ? _activeVehicle.loadProgress * parent.width : 0
        color:          qgcPal.colorGreen
        visible:        !largeProgressBar.visible
    }

    // Large parameter download progress bar
    Rectangle {
        id:             largeProgressBar
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        height:         parent.height
        color:          qgcPal.window
        visible:        _showLargeProgress

        property bool _initialDownloadComplete: _activeVehicle ? _activeVehicle.initialConnectComplete : true
        property bool _userHide:                false
        property bool _showLargeProgress:       !_initialDownloadComplete && !_userHide && qgcPal.globalTheme === QGCPalette.Light

        Connections {
            target:                 QGroundControl.multiVehicleManager
            function onActiveVehicleChanged(activeVehicle) { largeProgressBar._userHide = false }
        }

        Rectangle {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            width:          _activeVehicle ? _activeVehicle.loadProgress * parent.width : 0
            color:          qgcPal.colorGreen
        }

        QGCLabel {
            anchors.centerIn:   parent
            text:               qsTr("Downloading")
            font.pointSize:     ScreenTools.largeFontPointSize
        }

        QGCLabel {
            anchors.margins:    _margin
            anchors.right:      parent.right
            anchors.bottom:     parent.bottom
            text:               qsTr("Click anywhere to hide")

            property real _margin: ScreenTools.defaultFontPixelWidth / 2
        }

        MouseArea {
            anchors.fill:   parent
            onClicked:      largeProgressBar._userHide = true
        }
    }
}
