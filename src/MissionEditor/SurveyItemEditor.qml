import QtQuick          2.2
import QtQuick.Controls 1.2
import QtQuick.Dialogs  1.2
import QtQuick.Layouts  1.2

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0

// Editor for Survery mission items
Rectangle {
    id:         _root
    height:     visible ? (editorColumn.height + (_margin * 2)) : 0
    width:      availableWidth
    color:      qgcPal.windowShadeDark
    radius:     _radius

    // The following properties must be available up the hierarchy chain
    //property real   availableWidth    ///< Width for control
    //property var    missionItem       ///< Mission Item for editor

    property real   _margin:        ScreenTools.defaultFontPixelWidth / 2
    property int    _cameraIndex:   1

    readonly property int _gridTypeManual:          0
    readonly property int _gridTypeCustomCamera:    1
    readonly property int _gridTypeCamera:          2

    ListModel {
        id: cameraModelList

        ListElement {
            text:           qsTr("Manual Grid")
            sensorWidth:    0
            sensorHeight:   0
            imageWidth:     0
            imageHeight:    0
            focalLength:    0
        }
        ListElement {
            text:           qsTr("Custom Camera Grid")
            sensorWidth:    0
            sensorHeight:   0
            imageWidth:     0
            imageHeight:    0
            focalLength:    0
        }
        ListElement {
            text:           qsTr("Sony ILCE-QX1") //http://www.sony.co.uk/electronics/interchangeable-lens-cameras/ilce-qx1-body-kit/specifications
            sensorWidth:    23.2                  //http://www.sony.com/electronics/camera-lenses/sel16f28/specifications
            sensorHeight:   15.4
            imageWidth:     5456
            imageHeight:    3632
            focalLength:    16
        }
        ListElement {
            text:           qsTr("Canon S100 PowerShot")
            sensorWidth:    7.6
            sensorHeight:   5.7
            imageWidth:     4000
            imageHeight:    3000
            focalLength:    5.2
        }
        ListElement {
            text:           qsTr("Canon SX260 HS PowerShot")
            sensorWidth:    6.17
            sensorHeight:   4.55
            imageWidth:     4000
            imageHeight:    3000
            focalLength:    4.5
        }
        ListElement {
            text:           qsTr("Canon EOS-M 22mm")
            sensorWidth:    22.3
            sensorHeight:   14.9
            imageWidth:     5184
            imageHeight:    3456
            focalLength:    22
        }
        ListElement {
            text:           qsTr("Sony a6000 16mm") //http://www.sony.co.uk/electronics/interchangeable-lens-cameras/ilce-6000-body-kit#product_details_default
            sensorWidth:    23.5
            sensorHeight:   15.6
            imageWidth:     6000
            imageHeight:    4000
            focalLength:    16
        }
    }

    function recalcFromCameraValues() {
        var focalLength = cameraModelList.get(_cameraIndex).focalLength
        var sensorWidth = cameraModelList.get(_cameraIndex).sensorWidth
        var sensorHeight = cameraModelList.get(_cameraIndex).sensorHeight
        var imageWidth = cameraModelList.get(_cameraIndex).imageWidth
        var imageHeight = cameraModelList.get(_cameraIndex).imageHeight

        var gsd = Number(gsdField.text)
        var frontalOverlap = Number(frontalOverlapField.text)
        var sideOverlap = Number(sideOverlapField.text)

        if (focalLength <= 0.0 || sensorWidth <= 0.0 || sensorHeight <= 0.0 || imageWidth < 0 || imageHeight < 0 || gsd < 0.0 || frontalOverlap < 0 || sideOverlap < 0) {
            missionItem.gridAltitude.rawValue = 0
            missionItem.gridSpacing.rawValue = 0
            missionItem.cameraTriggerDistance.rawValue = 0
            return
        }

        var altitude
        var imageSizeSideGround //size in side (non flying) direction of the image on the ground
        var imageSizeFrontGround //size in front (flying) direction of the image on the ground
        var gridSpacing
        var cameraTriggerDistance

        altitude = (imageWidth * gsd * focalLength) / (sensorWidth * 100)

        if (cameraOrientationLandscape.checked) {
            imageSizeSideGround = (imageWidth * gsd) / 100
            imageSizeFrontGround = (imageHeight * gsd) / 100
        } else {
            imageSizeSideGround = (imageHeight * gsd) / 100
            imageSizeFrontGround = (imageWidth * gsd) / 100
        }

        gridSpacing = imageSizeSideGround * ( (100-sideOverlap) / 100 )
        cameraTriggerDistance = imageSizeFrontGround * ( (100-frontalOverlap) / 100 )

        missionItem.gridAltitude.rawValue = altitude
        missionItem.gridSpacing.rawValue = gridSpacing
        missionItem.cameraTriggerDistance.rawValue = cameraTriggerDistance
    }

    function recalcFromMissionValues() {
        var focalLength = cameraModelList.get(_cameraIndex).focalLength
        var sensorWidth = cameraModelList.get(_cameraIndex).sensorWidth
        var sensorHeight = cameraModelList.get(_cameraIndex).sensorHeight
        var imageWidth = cameraModelList.get(_cameraIndex).imageWidth
        var imageHeight = cameraModelList.get(_cameraIndex).imageHeight

        var altitude = missionItem.gridAltitude.rawValue
        var gridSpacing = missionItem.gridSpacing.rawValue
        var cameraTriggerDistance = missionItem.cameraTriggerDistance.rawValue

        if (focalLength <= 0.0 || sensorWidth <= 0.0 || sensorHeight <= 0.0 || imageWidth < 0 || imageHeight < 0 || altitude < 0.0 || gridSpacing < 0.0 || cameraTriggerDistance < 0.0) {
            gsdField.text = "0.0"
            sideOverlapField.text = "0"
            frontalOverlapField.text = "0"
            return
        }

        var gsd
        var imageSizeSideGround //size in side (non flying) direction of the image on the ground
        var imageSizeFrontGround //size in front (flying) direction of the image on the ground

        gsd = (altitude * sensorWidth * 100) / (imageWidth * focalLength)

        if (cameraOrientationLandscape.checked) {
            imageSizeSideGround = (imageWidth * gsd) / 100
            imageSizeFrontGround = (imageHeight * gsd) / 100
        } else {
            imageSizeSideGround = (imageHeight * gsd) / 100
            imageSizeFrontGround = (imageWidth * gsd) / 100
        }

        var sideOverlap = (imageSizeSideGround == 0 ? 0 : 100 - (gridSpacing*100 / imageSizeSideGround))
        var frontOverlap = (imageSizeFrontGround == 0 ? 0 : 100 - (cameraTriggerDistance*100 / imageSizeFrontGround))

        gsdField.text = gsd.toFixed(1)
        sideOverlapField.text = sideOverlap.toFixed(0)
        frontalOverlapField.text = frontOverlap.toFixed(0)
    }

    function polygonCaptureStarted() {
        missionItem.clearPolygon()
    }

    function polygonCaptureFinished(coordinates) {
        for (var i=0; i<coordinates.length; i++) {
            missionItem.addPolygonCoordinate(coordinates[i])
        }
    }

    function polygonAdjustVertex(vertexIndex, vertexCoordinate) {
        missionItem.adjustPolygonCoordinate(vertexIndex, vertexCoordinate)
    }

    function polygonAdjustStarted() { }
    function polygonAdjustFinished() { }

    Component {
        id: cameraDialog

        QGCViewDialog {

            Column {
                id:                 dialogColumn
                anchors.margins:    _margin
                anchors.top:        parent.top
                anchors.left:       parent.left
                anchors.right:      parent.right
                spacing:            _margin * 5

                Row {
                    spacing: ScreenTools.defaultFontPixelWidth

                    QGCLabel {
                        id:                 selectCameraModelText
                        text:               qsTr("Select Camera Model:")
                    }

                    QGCComboBox {
                        id:                 cameraModelCombo
                        model:              cameraModelList
                        width:              dialogColumn.width - selectCameraModelText.width - ScreenTools.defaultFontPixelWidth

                        onActivated: {
                            _cameraIndex = index
                        }

                        Component.onCompleted: {
                            var index = _cameraIndex
                            if (index === -1) {
                                console.warn("Active camera model name not in combo", _cameraIndex)
                            } else {
                                cameraModelCombo.currentIndex = index
                            }
                        }
                    }
                }

                Grid {
                    columns: 2
                    spacing: ScreenTools.defaultFontPixelWidth
                    verticalItemAlignment: Grid.AlignVCenter

                    QGCLabel { text: qsTr("Sensor Width:") }
                    QGCTextField {
                        id:                 sensorWidthField
                        unitsLabel:         "mm"
                        showUnits:          true
                        text:               cameraModelList.get(_cameraIndex).sensorWidth.toFixed(2)
                        readOnly:           _cameraIndex != 0
                        enabled:            _cameraIndex == 0
                        validator:          DoubleValidator{bottom:0.0; decimals:2}
                        onEditingFinished:  {
                            if (_cameraIndex == 0) {
                                cameraModelList.setProperty(_cameraIndex, "sensorWidth", Number(text))
                            }
                        }
                    }

                    QGCLabel { text: qsTr("Sensor Height:") }
                    QGCTextField {
                        id:                 sensorHeightField
                        unitsLabel:         "mm"
                        showUnits:          true
                        text:               cameraModelList.get(_cameraIndex).sensorHeight.toFixed(2)
                        readOnly:           _cameraIndex != 0
                        enabled:            _cameraIndex == 0
                        validator:          DoubleValidator{bottom:0.0; decimals:2}
                        onEditingFinished:  {
                            if (_cameraIndex == 0) {
                                cameraModelList.setProperty(_cameraIndex, "sensorHeight", Number(text))
                            }
                        }
                    }

                    QGCLabel { text: qsTr("Image Width:") }
                    QGCTextField {
                        id:                 imageWidthField
                        unitsLabel:         "px"
                        showUnits:          true
                        text:               cameraModelList.get(_cameraIndex).imageWidth.toFixed(0)
                        readOnly:           _cameraIndex != 0
                        enabled:            _cameraIndex == 0
                        validator:          IntValidator {bottom:0}
                        onEditingFinished:  {
                            if (_cameraIndex == 0) {
                                cameraModelList.setProperty(_cameraIndex, "imageWidth", Number(text))
                            }
                        }
                    }

                    QGCLabel { text: qsTr("Image Height:") }
                    QGCTextField {
                        id:                 imageHeightField
                        unitsLabel:         "px"
                        showUnits:          true
                        text:               cameraModelList.get(_cameraIndex).imageHeight.toFixed(0)
                        readOnly:           _cameraIndex != 0
                        enabled:            _cameraIndex == 0
                        validator:          IntValidator {bottom:0}
                        onEditingFinished:  {
                            if (_cameraIndex == 0) {
                                cameraModelList.setProperty(_cameraIndex, "imageHeight", Number(text))
                            }
                        }
                    }

                    QGCLabel { text: qsTr("Focal Length:") }
                    QGCTextField {
                        id:                 focalLengthField
                        unitsLabel:         "mm"
                        showUnits:          true
                        text:               cameraModelList.get(_cameraIndex).focalLength.toFixed(2)
                        readOnly:           _cameraIndex != 0
                        enabled:            _cameraIndex == 0
                        validator:          DoubleValidator{bottom:0.0; decimals:2}
                        onEditingFinished:  {
                            if (_cameraIndex == 0) {
                                cameraModelList.setProperty(_cameraIndex, "focalLength", Number(text))
                            }
                        }
                    }
                }
            }

            function accept() {
                hideDialog()
                recalcFromCameraValues()
            }
        } // QGCViewDialog
    } // Component

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    ExclusiveGroup {
        id:                 cameraOrientationGroup
        onCurrentChanged:   recalcFromMissionValues()
    }

    Column {
        id:                 editorColumn
        anchors.margins:    _margin
        anchors.top:        parent.top
        anchors.left:       parent.left
        anchors.right:      parent.right
        spacing:            _margin

        QGCLabel {
            anchors.left:   parent.left
            anchors.right:  parent.right
            wrapMode:       Text.WordWrap
            font.pointSize: ScreenTools.smallFontPointSize
            text:           gridTypeCombo.currentIndex == 0 ?
                                qsTr("Create a flight path which covers a polygonal area by specifying all grid parameters.") :
                                qsTr("Create a flight path which fully covers a polygonal area using camera specifications.")
        }

        QGCComboBox {
            id:             gridTypeCombo
            anchors.left:   parent.left
            anchors.right:  parent.right
            model:          cameraModelList
        }

        // Camera based grid ui
        Column {
            anchors.left:   parent.left
            anchors.right:  parent.right
            spacing:        _margin
            visible:        gridTypeCombo.currentIndex != _gridTypeManual

            QGCLabel { text: qsTr("Camera:") }

            Rectangle {
                anchors.left:   parent.left
                anchors.right:  parent.right
                height:         1
                color:          qgcPal.text
            }

            Row {
                spacing: _margin

                QGCRadioButton {
                    id:             cameraOrientationLandscape
                    width:          _editFieldWidth
                    text:           "Landscape"
                    checked:        true
                    exclusiveGroup: cameraOrientationGroup
                }

                QGCRadioButton {
                    id:             cameraOrientationPortrait
                    text:           "Portrait"
                    exclusiveGroup: cameraOrientationGroup
                }
            }

            Column {
                anchors.left:   parent.left
                anchors.right:  parent.right
                spacing:        _margin
                visible:        gridTypeCombo.currentIndex == _gridTypeCustomCamera

                GridLayout {
                    columns:        5
                    columnSpacing:  _margin
                    rowSpacing:     _margin

                    QGCLabel { text: qsTr("Sensor") }
                    QGCLabel { text: qsTr("W:") }
                    QGCTextField {
                        id:                     sensorWidthField
                        Layout.preferredWidth:   ScreenTools.defaultFontPixelWidth * 8
                        unitsLabel:             "mm"
                        showUnits:              true
                        validator:              DoubleValidator{bottom:0.0; decimals:1}
                        text:                   cameraModelList.get(_gridTypeCustomCamera).sensorWidth.toFixed(1)
                        onEditingFinished:      cameraModelList.setProperty(_gridTypeCustomCamera, "sensorWidth", Number(text))
                    }
                    QGCLabel { text: qsTr("H:") }
                    QGCTextField {
                        Layout.preferredWidth:   ScreenTools.defaultFontPixelWidth * 8
                        unitsLabel:         "mm"
                        showUnits:          true
                        text:               cameraModelList.get(_gridTypeCustomCamera).sensorHeight.toFixed(1)
                        validator:          DoubleValidator{bottom:0.0; decimals:1}
                        onEditingFinished:  cameraModelList.setProperty(_gridTypeCustomCamera, "sensorHeight", Number(text))
                    }

                    QGCLabel { text: qsTr("Image") }
                    QGCLabel { text: qsTr("W:") }
                    QGCTextField {
                        Layout.preferredWidth:   ScreenTools.defaultFontPixelWidth * 8
                        unitsLabel:         "px"
                        showUnits:          true
                        text:               cameraModelList.get(_gridTypeCustomCamera).imageWidth.toFixed(0)
                        validator:          IntValidator {bottom:0}
                        onEditingFinished:  cameraModelList.setProperty(_gridTypeCustomCamera, "imageWidth", Number(text))
                    }
                    QGCLabel { text: qsTr("H:") }
                    QGCTextField {
                        Layout.preferredWidth:   ScreenTools.defaultFontPixelWidth * 8
                        unitsLabel:         "px"
                        showUnits:          true
                        text:               cameraModelList.get(_gridTypeCustomCamera).imageHeight.toFixed(0)
                        validator:          IntValidator {bottom:0}
                        onEditingFinished:  cameraModelList.setProperty(_gridTypeCustomCamera, "imageHeight", Number(text))
                    }
                }

                Row {
                    spacing: _margin

                    QGCLabel {
                        anchors.baseline:   focalLengthField.baseline
                        text:               qsTr("Focal Length:")
                    }
                    QGCTextField {
                        id:                 focalLengthField
                        unitsLabel:         "mm"
                        showUnits:          true
                        text:               cameraModelList.get(_gridTypeCustomCamera).focalLength.toFixed(2)
                        validator:          DoubleValidator{bottom:0.0; decimals:2}
                        onEditingFinished:  cameraModelList.setProperty(_gridTypeCustomCamera, "focalLength", Number(text))
                    }
                }
            } // Column - custom camera

            QGCLabel { text: qsTr("Image Overlap") }

            Row {
                spacing:        _margin

                Item {
                    width:  ScreenTools.defaultFontPixelWidth * 2
                    height: 1
                }

                QGCLabel {
                    anchors.baseline:   frontalOverlapField.baseline
                    text:               qsTr("Frontal:")
                }

                QGCTextField {
                    id:                 frontalOverlapField
                    width:              ScreenTools.defaultFontPixelWidth * 5
                    unitsLabel:         "%"
                    showUnits:          true
                    onEditingFinished:  recalcFromCameraValues()
                    validator:          IntValidator {bottom:0}
                }

                QGCLabel {
                    anchors.baseline:   frontalOverlapField.baseline
                    text:               qsTr("Side:")
                }

                QGCTextField {
                    id:                 sideOverlapField
                    width:              frontalOverlapField.width
                    unitsLabel:         "%"
                    showUnits:          true
                    onEditingFinished:  recalcFromCameraValues()
                    validator:          IntValidator {bottom:0}
                }
            }

            Row {
                spacing:        _margin

                QGCLabel {
                    anchors.baseline:   gsdField.baseline
                    text:               qsTr("GSD:")
                }

                QGCTextField {
                    id:                 gsdField
                    width:              _editFieldWidth
                    unitsLabel:         "cm/px"
                    showUnits:          true
                    onEditingFinished:  recalcFromCameraValues()
                    validator:          DoubleValidator{bottom:0.0; decimals:2}
                }

                Component.onCompleted: recalcFromMissionValues()
            }

            QGCLabel { text: qsTr("Grid:") }

            Rectangle {
                anchors.left:   parent.left
                anchors.right:  parent.right
                height:         1
                color:          qgcPal.text
            }

            Repeater {
                model: [ missionItem.gridAngle, missionItem.gridAltitude, missionItem.turnaroundDist ]

                Item {
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    height:         textField.height

                    QGCLabel {
                        anchors.baseline:   textField.baseline
                        anchors.left:       parent.left
                        text:               modelData.name + ":"
                    }

                    FactTextField {
                        id:                 textField
                        anchors.right:      parent.right
                        width:              _editFieldWidth
                        showUnits:          true
                        fact:               modelData
                        onEditingFinished:  recalcFromMissionValues()
                        validator:          DoubleValidator{bottom:0.0; decimals:2}
                    }
                }
            }
        }

        // Manual grid ui
        Column {
            anchors.left:   parent.left
            anchors.right:  parent.right
            spacing:        _margin
            visible:        gridTypeCombo.currentIndex == _gridTypeManual

            QGCLabel { text: qsTr("Grid:") }

            Rectangle {
                anchors.left:   parent.left
                anchors.right:  parent.right
                height:         1
                color:          qgcPal.text
            }

            Repeater {
                model: [ missionItem.gridAngle, missionItem.gridSpacing, missionItem.gridAltitude, missionItem.turnaroundDist ]

                Item {
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    height:         textField.height

                    QGCLabel {
                        anchors.baseline:   textField.baseline
                        anchors.left:       parent.left
                        text:               modelData.name + ":"
                    }

                    FactTextField {
                        id:             textField
                        anchors.right:  parent.right
                        width:          _editFieldWidth
                        showUnits:      true
                        fact:           modelData
                        onEditingFinished: recalcFromMissionValues()
                        validator:      DoubleValidator{bottom:0.0; decimals:2}
                    }
                }
            }

            QGCCheckBox {
                anchors.left:   parent.left
                text:           qsTr("Relative altitude")
                checked:        missionItem.gridAltitudeRelative
                onClicked:      missionItem.gridAltitudeRelative = checked
            }

            QGCLabel { text: qsTr("Camera:") }

            Rectangle {
                anchors.left:   parent.left
                anchors.right:  parent.right
                height:         1
                color:          qgcPal.text
            }

            Row {
                spacing:        _margin

                QGCCheckBox {
                    id:                 cameraTrigger
                    anchors.baseline:   cameraTriggerDistanceField.baseline
                    text:               qsTr("Trigger Distance:")
                    checked:            missionItem.cameraTrigger
                    onClicked:          missionItem.cameraTrigger = checked
                }

                FactTextField {
                    id:                 cameraTriggerDistanceField
                    width:              _editFieldWidth
                    showUnits:          true
                    fact:               missionItem.cameraTriggerDistance
                    enabled:            missionItem.cameraTrigger
                    onEditingFinished:  recalcFromMissionValues()
                    validator:          DoubleValidator{bottom:0.0; decimals:2}
                }
            }
        }

        QGCLabel { text: qsTr("Polygon:") }

        Rectangle {
            anchors.left:   parent.left
            anchors.right:  parent.right
            height:         1
            color:          qgcPal.text
        }

        Row {
            spacing: ScreenTools.defaultFontPixelWidth

            QGCButton {
                text:       editorMap.polygonDraw.drawingPolygon ? qsTr("Finish Draw") : qsTr("Draw")
                visible:    !editorMap.polygonDraw.adjustingPolygon
                enabled:    ((editorMap.polygonDraw.drawingPolygon && editorMap.polygonDraw.polygonReady) || !editorMap.polygonDraw.drawingPolygon)

                onClicked: {
                    if (editorMap.polygonDraw.drawingPolygon) {
                        editorMap.polygonDraw.finishCapturePolygon()
                    } else {
                        editorMap.polygonDraw.startCapturePolygon(_root)
                    }
                }
            }

            QGCButton {
                text:       editorMap.polygonDraw.adjustingPolygon ? qsTr("Finish Adjust") : qsTr("Adjust")
                visible:    missionItem.polygonPath.length > 0 && !editorMap.polygonDraw.drawingPolygon

                onClicked: {
                    if (editorMap.polygonDraw.adjustingPolygon) {
                        editorMap.polygonDraw.finishAdjustPolygon()
                    } else {
                        editorMap.polygonDraw.startAdjustPolygon(_root, missionItem.polygonPath)
                    }
                }
            }
        }

        QGCLabel { text: qsTr("Statistics:") }

        Rectangle {
            anchors.left:   parent.left
            anchors.right:  parent.right
            height:         1
            color:          qgcPal.text
        }

        Grid {
            columns: 2
            spacing: ScreenTools.defaultFontPixelWidth

            QGCLabel { text: qsTr("Survey area:") }
            QGCLabel { text: QGroundControl.squareMetersToAppSettingsAreaUnits(missionItem.coveredArea).toFixed(2) + " " + QGroundControl.appSettingsAreaUnitsString }

            QGCLabel { text: qsTr("# shots:") }
            QGCLabel { text: missionItem.cameraShots }
        }
    }
}
