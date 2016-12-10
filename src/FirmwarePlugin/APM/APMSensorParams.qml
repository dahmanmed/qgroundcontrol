import QtQuick 2.2

import QGroundControl.FactSystem 1.0

Item {
    /// Must be specified by consumer of control
    property var factPanelController

    property Fact _noFact: Fact { }

    property Fact compassPrimaryFact:               factPanelController.getParameterFact(-1, "COMPASS_PRIMARY")
    property bool compass1Primary:                  compassPrimaryFact.rawValue == 0
    property bool compass2Primary:                  compassPrimaryFact.rawValue == 1
    property bool compass3Primary:                  compassPrimaryFact.rawValue == 2
    property var  rgCompassPrimary:                 [ compass1Primary, compass2Primary, compass3Primary ]

    property Fact compass1Id:                       factPanelController.getParameterFact(-1, "COMPASS_DEV_ID")
    property Fact compass2Id:                       factPanelController.getParameterFact(-1, "COMPASS_DEV_ID2")
    property Fact compass3Id:                       factPanelController.getParameterFact(-1, "COMPASS_DEV_ID3")

    property bool compass1Available:                compass1Id.value > 0
    property bool compass2Available:                compass2Id.value > 0
    property bool compass3Available:                compass3Id.value > 0
    property var  rgCompassAvailable:               [ compass1Available, compass2Available, compass3Available ]

    property bool compass1RotParamAvailable:        factPanelController.parameterExists(-1, "COMPASS_ORIENT")
    property bool compass2RotParamAvailable:        factPanelController.parameterExists(-1, "COMPASS_ORIENT2")
    property bool compass3RotParamAvailable:        factPanelController.parameterExists(-1, "COMPASS_ORIENT3")
    property var  rgCompassRotParamAvailable:       [ compass1RotParamAvailable, compass2RotParamAvailable, compass3RotParamAvailable ]

    property Fact compass1RotFact:                  compass2RotParamAvailable ? factPanelController.getParameterFact(-1, "COMPASS_ORIENT") : _noFact
    property Fact compass2RotFact:                  compass2RotParamAvailable ? factPanelController.getParameterFact(-1, "COMPASS_ORIENT2") : _noFact
    property Fact compass3RotFact:                  compass3RotParamAvailable ? factPanelController.getParameterFact(-1, "COMPASS_ORIENT3") : _noFact
    property var  rgCompassRotFact:                 [ compass1RotFact, compass2RotFact, compass3RotFact ]

    property bool compass1UseParamAvailable:        factPanelController.parameterExists(-1, "COMPASS_USE")
    property bool compass2UseParamAvailable:        factPanelController.parameterExists(-1, "COMPASS_USE2")
    property bool compass3UseParamAvailable:        factPanelController.parameterExists(-1, "COMPASS_USE3")
    property var  rgCompassUseParamAvailable:       [ compass1UseParamAvailable, compass2UseParamAvailable, compass3UseParamAvailable ]

    property Fact compass1UseFact:                  compass1UseParamAvailable ? factPanelController.getParameterFact(-1, "COMPASS_USE") : _noFact
    property Fact compass2UseFact:                  compass2UseParamAvailable ? factPanelController.getParameterFact(-1, "COMPASS_USE2") : _noFact
    property Fact compass3UseFact:                  compass3UseParamAvailable ? factPanelController.getParameterFact(-1, "COMPASS_USE3") : _noFact
    property var  rgCompassUseFact:                 [ compass1UseFact, compass2UseFact, compass3UseFact ]

    property bool compass1Use:                      compass1UseParamAvailable ? compass1UseFact.value : true
    property bool compass2Use:                      compass2UseParamAvailable ? compass2UseFact.value : true
    property bool compass3Use:                      compass3UseParamAvailable ? compass3UseFact.value : true

    property bool compass1ExternalParamAvailable:   factPanelController.parameterExists(-1, "COMPASS_EXTERNAL")
    property bool compass2ExternalParamAvailable:   factPanelController.parameterExists(-1, "COMPASS_EXTERN2")
    property bool compass3ExternalParamAvailable:   factPanelController.parameterExists(-1, "COMPASS_EXTERN3")
    property var  rgCompassExternalParamAvailable:  [ compass1ExternalParamAvailable, compass2ExternalParamAvailable, compass3ExternalParamAvailable ]

    property Fact compass1ExternalFact:             compass1ExternalParamAvailable ? factPanelController.getParameterFact(-1, "COMPASS_EXTERNAL") : _noFact
    property Fact compass2ExternalFact:             compass2ExternalParamAvailable ? factPanelController.getParameterFact(-1, "COMPASS_EXTERN2") : _noFact
    property Fact compass3ExternalFact:             compass3ExternalParamAvailable ? factPanelController.getParameterFact(-1, "COMPASS_EXTERN3") : _noFact

    property bool compass1External:                 !!compass1ExternalFact.rawValue
    property bool compass2External:                 !!compass2ExternalFact.rawValue
    property bool compass3External:                 !!compass3ExternalFact.rawValue
    property var  rgCompassExternal:                [ compass1External, compass2External, compass3External ]
}
