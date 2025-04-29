import 'package:flutter_test/flutter_test.dart';
import 'package:mvr/src/classes/xml_nodes/child_list.dart';
import 'package:mvr/src/classes/xml_nodes/layer.dart';
import 'package:mvr/src/classes/xml_nodes/layers.dart';
import 'package:mvr/src/classes/xml_nodes/scene.dart';
import 'package:mvr/src/classes/xml_nodes/user_data.dart';

import 'package:mvr/src/parse_general_scene_description.dart';

import '../test_parameters/test_parameters.dart';

void main() {
  test('Parse General Scene Description into Intermediate Format', () async {
    final gsdFileContents = await generalGsdTestParams.getTestFileContents();
    final gsdNode = parseGeneralSceneDescription(gsdFileContents);

    expect(
      gsdNode.verMajor,
      generalGsdTestParams.majorVersion,
      reason: 'MVR major version does not match test parameters',
    );

    expect(
      gsdNode.verMinor,
      generalGsdTestParams.minorVersion,
      reason: 'MVR minor version does not match test parameters',
    );

    expect(
      gsdNode.children.whereType<UserDataNode>().length,
      generalGsdTestParams.userDataNodeCount,
      reason: "Incorrect number of <UserData/> nodes",
    );

    expect(
      gsdNode.children.whereType<SceneNode>().length,
      generalGsdTestParams.sceneNodeCount,
      reason: "Incorrect number of <Scene/> nodes",
    );

    expect(
      gsdNode.children
          .whereType<SceneNode>()
          .first
          .children
          .whereType<LayersNode>()
          .length,
      generalGsdTestParams.layersNodeCount,
      reason: "Incorrect number of <Layers/> nodes",
    );

    expect(
      gsdNode.children
          .whereType<SceneNode>()
          .first
          .children
          .whereType<LayersNode>()
          .first
          .children
          .whereType<LayerNode>()
          .length,
      generalGsdTestParams.layerNodeCount,
      reason: "Incorrect number of <Layer/> nodes",
    );

    expect(
      gsdNode.children
          .whereType<SceneNode>()
          .first
          .children
          .whereType<LayersNode>()
          .first
          .children
          .whereType<LayerNode>()
          .expand(
            (layerNode) =>
                layerNode.children.whereType<ChildListNode>().first.children,
          )
          .length,
      generalGsdTestParams.totalFixtureCount,
      reason: "Incorrect total number of <Fixture/> elements",
    );
  });
}
