import 'package:mvr/src/classes/mvr_fixture.dart';
import 'package:mvr/src/classes/xml_nodes/child_list.dart';
import 'package:mvr/src/classes/xml_nodes/fixture.dart';
import 'package:mvr/src/classes/xml_nodes/layer.dart';

class MVRLayer {
  final String uuid;
  final String name;

  final List<MVRFixture> fixtures;

  MVRLayer({required this.uuid, this.name = '', this.fixtures = const []});

  factory MVRLayer.fromNode(LayerNode node) {
    final childListNode = node.children.whereType<ChildListNode>().firstOrNull;

    return MVRLayer(
      uuid: node.uuid,
      name: node.name,
      fixtures:
          childListNode == null
              ? []
              : childListNode.children
                  .whereType<FixtureNode>()
                  .map((fixtureNode) => MVRFixture.fromNode(fixtureNode))
                  .toList(),
    );
  }
}
