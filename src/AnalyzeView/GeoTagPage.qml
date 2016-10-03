/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.5
import QtQuick.Controls 1.3
import QtQuick.Dialogs  1.2

import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0

AnalyzePage {
    id:                 geoTagPage
    pageComponent:      pageComponent
    pageName:           qsTr("GeoTag Images (WIP)")
    pageDescription:    qsTr("GetTag Images is used to geotag a set of images from a survey mission with gps coordinates. You must provide the binary log from the flight as well as the directory which contains the images to tag.")

    property real _margin: ScreenTools.defaultFontPixelWidth

    FileDialog {
        id: fileDialog

        property var textField

        onAccepted: {
            console.log(fileDialog.fileUrl)
            textField.text = fileDialog.fileUrl
        }
    }

    Component {
        id: pageComponent

        Column {
            id:         mainColumn
            width:      availableWidth
            spacing:    _margin

            Row {
                spacing: _margin

                QGCLabel {
                    text: "Log file:"
                }

                QGCLabel {
                    id: logFilePath
                }

                QGCButton {
                    text: qsTr("Select log file")
                    onClicked: {
                        fileDialog.textField = logFilePath
                        fileDialog.selectFolder = false
                        fileDialog.open()
                    }
                }
            }

            Row {
                spacing: _margin

                QGCLabel {
                    text: "Image directory:"
                }

                QGCLabel {
                    id: imageDirectory
                }

                QGCButton {
                    text: qsTr("Select image directory")
                    onClicked: {
                        fileDialog.textField = imageDirectory
                        fileDialog.selectFolder = true
                        fileDialog.open()
                    }
                }
            }

            QGCButton {
                text: qsTr("GeoTag")

                onClicked: {
                    if (logFilePath.text == "" || imageDirectory.text == "") {
                        geoTagPage.showMessage(qsTr("Error"), qsTr("You must select a log file and image directory before you can GeoTag."), StandardButton.Ok)
                        return
                    }
                    geoTagPage.showMessage(qsTr("GeoTag call"), qsTr("This is where the geotag call would be made"), StandardButton.Ok)
                }
            }
        } // Column
    } // Component
} // AnalyzePage
