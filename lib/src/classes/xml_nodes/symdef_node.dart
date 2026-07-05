import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:mvr/src/classes/xml_nodes/base/mvr_relationship.dart';
import 'package:xml/xml.dart';

class SymdefNode extends Relationship {
  final List<MVRNode> children;
  SymdefNode({required super.uuid, super.name, this.children = const []})
    : super(tagName: 'Symdef');

  factory SymdefNode.from(XmlElement element) {
    return SymdefNode(
      uuid: element.getAttribute('uuid')!,
      name: element.getAttribute('name') ?? '',
      children: MVRNode.mapChildren(element.childElements),
    );
  }
}
