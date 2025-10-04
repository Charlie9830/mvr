import 'package:mvr/src/classes/mvr_graphic_objects.dart';
import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:mvr/src/classes/xml_nodes/child_list.dart';
import 'package:mvr/src/classes/xml_nodes/fixture.dart';
import 'package:mvr/src/classes/xml_nodes/group_object.dart';
import 'package:mvr/src/classes/xml_nodes/layer.dart';

class MVRLayer {
  final String uuid;
  final String name;

  final List<MVRGraphicObject> children;

  MVRLayer({required this.uuid, this.name = '', this.children = const []});

  factory MVRLayer.fromNode(LayerNode node) {
    final childListNode = node.children.whereType<ChildListNode>().firstOrNull;

    return MVRLayer(
      uuid: node.uuid,
      name: node.name,
      children:
          childListNode == null ? [] : _processChildren(childListNode.children),
    );
  }

  static List<MVRGraphicObject> _processChildren(List<MVRNode> nodes) {
    return nodes
        .map((node) {
          return switch (node) {
            FixtureNode n => MVRFixture.fromNode(n),
            GroupObjectNode n => MVRGroupObject.fromNode(n),
            MVRNode _ => null,
          };
        })
        .nonNulls
        .toList();
  }
}
