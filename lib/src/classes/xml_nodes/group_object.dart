import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:mvr/src/classes/xml_nodes/base/mvr_relationship.dart';
import 'package:xml/xml.dart';

class GroupObjectNode extends Relationship {
  List<MVRNode> children;

  GroupObjectNode({required super.uuid, super.name, this.children = const []})
    : super(tagName: 'GroupObject');

  factory GroupObjectNode.from(XmlElement element) {
    return GroupObjectNode(
      uuid: element.getAttribute('uuid')!,
      name: element.getAttribute('name') ?? '',
      children: MVRNode.mapChildren(element.childElements),
    );
  }
}
