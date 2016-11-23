/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.4
import QtQuick.Controls 1.3
import QtQuick.Dialogs  1.2
import QtQuick.Layouts  1.2

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controllers   1.0

/// Multi-Vehicle View
QGCView {
    id:         qgcView
    viewPanel:  panel

    property real _margins: ScreenTools.defaultFontPixelWidth

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    QGCViewPanel {
        id:             panel
        anchors.fill:   parent

        Rectangle {
            anchors.fill:   parent
            color:          qgcPal.window

            QGCFlickable {
                anchors.fill:       parent
                contentHeight:      vehicleColumn.height
                flickableDirection: Flickable.VerticalFlick
                clip:               true

                Column {
                    id:                 vehicleColumn
                    anchors.margins:    _margins
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    anchors.top:        parent.top
                    spacing:            _margins

                    QGCLabel { text: qsTr("All Vehicles") }

                    Repeater {
                        model: QGroundControl.multiVehicleManager.vehicles

                        Column {
                            anchors.left:   parent.left
                            anchors.right:  parent.right
                            spacing:        ScreenTools.defaultFontPixelHeight / 2

                            MissionController {
                                id: missionController

                                Component.onCompleted: startStaticActiveVehicle(object)

                                property bool missionAvailable: visualItems && visualItems.count > 1

                                /*
                            function loadFromSelectedFile() {
                                if (ScreenTools.isMobile) {
                                    qgcView.showDialog(mobileFilePicker, qsTr("Select Mission File"), qgcView.showDialogDefaultWidth, StandardButton.Yes | StandardButton.Cancel)
                                } else {
                                    missionController.loadFromFilePicker()
                                    fitMapViewportToMissionItems()
                                    _currentMissionItem = _visualItems.get(0)
                                }
                            }

                            function saveToSelectedFile() {
                                if (ScreenTools.isMobile) {
                                    qgcView.showDialog(mobileFileSaver, qsTr("Save Mission File"), qgcView.showDialogDefaultWidth, StandardButton.Save | StandardButton.Cancel)
                                } else {
                                    missionController.saveToFilePicker()
                                }
                            } */
                            } // MissionController

                            GeoFenceController {
                                id: geoFenceController

                                Component.onCompleted: startStaticActiveVehicle(object)

                                property bool fenceAvailable: fenceSupported && (circleSupported || polygonSupported)

                                /*
                            function saveToSelectedFile() {
                                if (ScreenTools.isMobile) {
                                    qgcView.showDialog(mobileFileSaver, qsTr("Save Fence File"), qgcView.showDialogDefaultWidth, StandardButton.Save | StandardButton.Cancel)
                                } else {
                                    geoFenceController.saveToFilePicker()
                                }
                            }

                            function loadFromSelectedFile() {
                                if (ScreenTools.isMobile) {
                                    qgcView.showDialog(mobileFilePicker, qsTr("Select Fence File"), qgcView.showDialogDefaultWidth, StandardButton.Yes | StandardButton.Cancel)
                                } else {
                                    geoFenceController.loadFromFilePicker()
                                    fitMapViewportToFenceItems()
                                }
                            }*/
                            } // GeoFenceController

                            RallyPointController {
                                id: rallyPointController

                                Component.onCompleted: startStaticActiveVehicle(object)

                                property bool pointsAvailable: rallyPointsSupported && points.count

                                /*
                            function saveToSelectedFile() {
                                if (ScreenTools.isMobile) {
                                    qgcView.showDialog(mobileFileSaver, qsTr("Save Rally Point File"), qgcView.showDialogDefaultWidth, StandardButton.Save | StandardButton.Cancel)
                                } else {
                                    rallyPointController.saveToFilePicker()
                                }
                            }

                            function loadFromSelectedFile() {
                                if (ScreenTools.isMobile) {
                                    qgcView.showDialog(mobileFilePicker, qsTr("Select Rally Point File"), qgcView.showDialogDefaultWidth, StandardButton.Yes | StandardButton.Cancel)
                                } else {
                                    rallyPointController.loadFromFilePicker()
                                    fitMapViewportToRallyItems()
                                }
                            }*/
                            } // RallyPointController

                            QGCLabel {
                                text: "Vehicle #" + object.id
                            }

                            Rectangle {
                                anchors.left:   parent.left
                                anchors.right:  parent.right
                                height:         (lostConnectionRow.visible ? lostConnectionRow.height : indicatorRow.height )+ (_margins * 2)
                                color:          qgcPal.windowShade

                                Row {
                                    id:                 lostConnectionRow
                                    spacing:            _margins
                                    anchors.margins:    _margins
                                    anchors.right:      parent.right
                                    anchors.top:        parent.top
                                    layoutDirection:    Qt.RightToLeft
                                    visible:            object.connectionLost

                                    QGCButton {
                                        text:       qsTr("Disconnect")
                                        onClicked:  object.disconnectInactiveVehicle()
                                    }

                                    QGCLabel {
                                        text:                   qsTr("COMMUNICATION LOST")
                                        font.pointSize:         ScreenTools.largeFontPointSize
                                        font.family:            ScreenTools.demiboldFontFamily
                                        color:                  "red"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Row {
                                    id:                 indicatorRow
                                    anchors.margins:    _margins
                                    anchors.left:       parent.left
                                    anchors.top:        parent.top
                                    spacing:            _margins
                                    visible:            !object.connectionLost

                                    Rectangle {
                                        width:          missionLabel.contentWidth + _margins
                                        height:         ScreenTools.defaultFontPixelHeight + _margins
                                        radius:         height / 4
                                        color:          missionController.missionAvailable ? "green" : qgcPal.window
                                        border.width:   1
                                        border.color:   qgcPal.text

                                        QGCLabel {
                                            id:                 missionLabel
                                            anchors.margins:    _margins / 2
                                            anchors.left:       parent.left
                                            anchors.top:        parent.top
                                            text:               qsTr("Mission")
                                        }
                                    }

                                    Rectangle {
                                        width:          fenceLabel.contentWidth + _margins
                                        height:         ScreenTools.defaultFontPixelHeight + _margins
                                        radius:         height / 4
                                        color:          geoFenceController.fenceAvailable ? "green" : qgcPal.window
                                        border.width:   1
                                        border.color:   qgcPal.text

                                        QGCLabel {
                                            id:                 fenceLabel
                                            anchors.margins:    _margins / 2
                                            anchors.left:       parent.left
                                            anchors.top:        parent.top
                                            text:               qsTr("Fence")
                                        }
                                    }

                                    Rectangle {
                                        width:          rallyLabel.contentWidth + _margins
                                        height:         ScreenTools.defaultFontPixelHeight + _margins
                                        radius:         height / 4
                                        color:          rallyPointController.pointsAvailable ? "green" : qgcPal.window
                                        border.width:   1
                                        border.color:   qgcPal.text

                                        QGCLabel {
                                            id:                 rallyLabel
                                            anchors.margins:    _margins / 2
                                            anchors.left:       parent.left
                                            anchors.top:        parent.top
                                            text:               qsTr("Rally")
                                        }
                                    }

                                    FlightModeDropdown { activeVehicle: object }

                                    GuidedBar { activeVehicle: object }
                                } // Row - contents display
                            } // Rectangle - contents display
                        } // Column - layout for vehicle
                    } // Repeater - vehicle repeater
                } // Column
            } // QGCFlickable
        } // Rectangle - View background
    } // QGCViewPanel
} // QGCVIew
