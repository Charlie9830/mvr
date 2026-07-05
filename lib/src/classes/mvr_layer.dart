import 'package:mvr/src/classes/mvr_graphic_objects.dart';
import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:mvr/src/classes/xml_nodes/child_list.dart';
import 'package:mvr/src/classes/xml_nodes/fixture.dart';
import 'package:mvr/src/classes/xml_nodes/group_object.dart';
import 'package:mvr/src/classes/xml_nodes/layer.dart';
import 'package:mvr/src/classes/xml_nodes/truss_node.dart';
import 'package:mvr/src/context.dart';

class MVRLayer {
  final String uuid;
  final String name;

  final List<MVRGraphicObject> children;

  MVRLayer({required this.uuid, this.name = '', this.children = const []});

  factory MVRLayer.fromNode(Context ctx, LayerNode node) {
    final childListNode = node.children.whereType<ChildListNode>().firstOrNull;

    return MVRLayer(
      uuid: node.uuid,
      name: node.name,
      children:
          childListNode == null
              ? []
              : _processChildren(ctx, childListNode.children),
    );
  }

  static List<MVRGraphicObject> _processChildren(
    Context ctx,
    List<MVRNode> nodes,
  ) {
    return nodes
        .map((node) {
          return switch (node) {
            FixtureNode n => MVRFixture.fromNode(n),
            GroupObjectNode n => MVRGroupObject.fromNode(n),
            TrussNode n => MVRTruss.fromNode(ctx, n),
            MVRNode _ => null,
          };
        })
        .nonNulls
        .toList();
  }
}
