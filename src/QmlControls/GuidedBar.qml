/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick 2.5

import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0

//-- Guided mode bar

Item {
    width:  guidedModeBar.width
    height: guidedModeBar.height

    property var    activeVehicle                                           ///< Vehicle to show guided bar for
    property real   fontPointSize:      ScreenTools.defaultFontPointSize    ///< point size for fonts in control
    property color  backgroundColor:    qgcPal.windowShadeDark              ///< Background color for bar

    readonly property int confirmHome:          1
    readonly property int confirmLand:          2
    readonly property int confirmTakeoff:       3
    readonly property int confirmArm:           4
    readonly property int confirmDisarm:        5
    readonly property int confirmEmergencyStop: 6
    readonly property int confirmChangeAlt:     7
    readonly property int confirmGoTo:          8
    readonly property int confirmRetask:        9
    readonly property int confirmOrbit:         10

    property int    _confirmActionCode
    property real   _showMargin:    _margins
    property real   _hideMargin:    _margins - guidedModeBar.height
    property real   _barMargin:     _showMargin

    function actionConfirmed() {
        switch (_confirmActionCode) {
        case confirmHome:
            activeVehicle.guidedModeRTL()
            break;
        case confirmLand:
            activeVehicle.guidedModeLand()
            break;
        case confirmTakeoff:
            var altitude1 = altitudeSlider.getValue()
            if (!isNaN(altitude1)) {
                activeVehicle.guidedModeTakeoff(altitude1)
            }
            break;
        case confirmArm:
            activeVehicle.armed = true
            break;
        case confirmDisarm:
            activeVehicle.armed = false
            break;
        case confirmEmergencyStop:
            activeVehicle.emergencyStop()
            break;
        case confirmChangeAlt:
            var altitude2 = altitudeSlider.getValue()
            if (!isNaN(altitude2)) {
                activeVehicle.guidedModeChangeAltitude(altitude2)
            }
            break;
        case confirmGoTo:
            activeVehicle.guidedModeGotoLocation(_flightMap._gotoHereCoordinate)
            break;
        case confirmRetask:
            activeVehicle.setCurrentMissionSequence(_flightMap._retaskSequence)
            break;
        case confirmOrbit:
            //-- All parameters controlled by RC
            activeVehicle.guidedModeOrbit()
            //-- Center on current flight map position and orbit with a 50m radius (velocity/direction controlled by the RC)
            //activeVehicle.guidedModeOrbit(QGroundControl.flightMapPosition, 50.0)
            break;
        default:
            console.warn(qsTr("Internal error: unknown _confirmActionCode"), _confirmActionCode)
        }
    }

    function rejectGuidedModeConfirm() {
        guidedModeConfirm.visible = false
        guidedModeBar.visible = true
        /*
        altitudeSlider.visible = false
        _flightMap._gotoHereCoordinate = QtPositioning.coordinate()
        guidedModeHideTimer.restart()
        */
    }

    function confirmAction(actionCode) {
        //guidedModeHideTimer.stop()
        _confirmActionCode = actionCode
        switch (_confirmActionCode) {
        case confirmArm:
            guidedModeConfirm.confirmText = qsTr("arm")
            break;
        case confirmDisarm:
            guidedModeConfirm.confirmText = qsTr("disarm")
            break;
        case confirmEmergencyStop:
            guidedModeConfirm.confirmText = qsTr("STOP ALL MOTORS!")
            break;
        case confirmTakeoff:
            altitudeSlider.visible = true
            altitudeSlider.setInitialValueMeters(3)
            guidedModeConfirm.confirmText = qsTr("takeoff")
            break;
        case confirmLand:
            guidedModeConfirm.confirmText = qsTr("land")
            break;
        case confirmHome:
            guidedModeConfirm.confirmText = qsTr("return to land")
            break;
        case confirmChangeAlt:
            altitudeSlider.visible = true
            altitudeSlider.setInitialValueAppSettingsDistanceUnits(activeVehicle.altitudeAMSL.value)
            guidedModeConfirm.confirmText = qsTr("change altitude")
            break;
        case confirmGoTo:
            guidedModeConfirm.confirmText = qsTr("move vehicle")
            break;
        case confirmRetask:
            guidedModeConfirm.confirmText = qsTr("active waypoint change")
            break;
        case confirmOrbit:
            guidedModeConfirm.confirmText = qsTr("enter orbit mode")
            break;
        }
        guidedModeBar.visible = false
        guidedModeConfirm.visible = true
    }

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    Rectangle {
        id:                         guidedModeBar
        width:                      guidedModeColumn.width  + (_margins * 2)
        height:                     guidedModeColumn.height + (_margins * 2)
        radius:                     ScreenTools.defaultFontPixelHeight * 0.25
        color:                      backgroundColor

        Column {
            id:                 guidedModeColumn
            anchors.margins:    _margins
            anchors.top:        parent.top
            anchors.left:       parent.left
            spacing:            _margins

            /*
            QGCLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                color:      _lightWidgetBorders ? qgcPal.mapWidgetBorderDark : qgcPal.mapWidgetBorderLight
                text:       "Click in map to move vehicle"
                visible:    gotoEnabled
            }*/

            Row {
                spacing: _margins * 2

                QGCButton {
                    pointSize:  fontPointSize
                    text:       (activeVehicle && activeVehicle.armed) ? (activeVehicle.flying ? qsTr("Emergency Stop") : qsTr("Disarm")) :  qsTr("Arm")
                    visible:    activeVehicle
                    onClicked:  confirmAction(activeVehicle.armed ? (activeVehicle.flying ? confirmEmergencyStop : confirmDisarm) : confirmArm)
                }

                QGCButton {
                    pointSize:  fontPointSize
                    text:       qsTr("RTL")
                    visible:    (activeVehicle && activeVehicle.armed) && activeVehicle.guidedModeSupported && activeVehicle.flying
                    onClicked:  confirmAction(confirmHome)
                }

                QGCButton {
                    pointSize:  fontPointSize
                    text:       (activeVehicle && activeVehicle.flying) ?  qsTr("Land"):  qsTr("Takeoff")
                    visible:    activeVehicle && activeVehicle.guidedModeSupported && activeVehicle.armed
                    onClicked:  confirmAction(activeVehicle.flying ? confirmLand : confirmTakeoff)
                }

                QGCButton {
                    pointSize:  fontPointSize
                    text:       qsTr("Pause")
                    visible:    (activeVehicle && activeVehicle.armed) && activeVehicle.pauseVehicleSupported && activeVehicle.flying
                    onClicked:  {
                        guidedModeHideTimer.restart()
                        activeVehicle.pauseVehicle()
                    }
                }

                QGCButton {
                    pointSize:  fontPointSize
                    text:       qsTr("Change Altitude")
                    visible:    (activeVehicle && activeVehicle.flying) && activeVehicle.guidedModeSupported && activeVehicle.armed
                    onClicked:  confirmAction(confirmChangeAlt)
                }

                QGCButton {
                    pointSize:  fontPointSize
                    text:       qsTr("Orbit")
                    visible:    (activeVehicle && activeVehicle.flying) && activeVehicle.orbitModeSupported && activeVehicle.armed
                    onClicked:  confirmAction(confirmOrbit)
                }

            } // Row
        } // Column
    } // Rectangle - Guided mode buttons

    /*
    MouseArea {
        anchors.fill:   parent
        enabled:        guidedModeConfirm.visible
        onClicked:      rejectGuidedModeConfirm()
    }
    */

    // Action confirmation control
    SliderSwitch {
        id:                         guidedModeConfirm
        visible:                    false
        fontPointSize:              fontPointSize

        onAccept: {
            guidedModeConfirm.visible = false
            guidedModeBar.visible = true
            actionConfirmed()
            /*
            altitudeSlider.visible = false
            guidedModeHideTimer.restart()
            */
        }

        onReject: rejectGuidedModeConfirm()
    }
} // Item
