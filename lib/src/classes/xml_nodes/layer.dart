import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:mvr/src/classes/xml_nodes/base/mvr_relationship.dart';
import 'package:xml/xml.dart';

class LayerNode extends Relationship {
  List<MVRNode> children;

  LayerNode({required super.uuid, super.name, this.children = const []})
    : super(tagName: 'Layer');

  factory LayerNode.from(XmlElement element) {
    return LayerNode(
      uuid: element.getAttribute('uuid')!,
      name: element.getAttribute('name') ?? '',
      children: MVRNode.mapChildren(element.childElements),
    );
  }
}
