import 'package:mvr/src/classes/xml_nodes/base/mvr_multipatch.dart';
import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:xml/xml.dart';

class FixtureNode extends MultiPatch {
  List<MVRNode> children;

  FixtureNode({
    required super.uuid,
    super.name,
    super.multiPatch,
    this.children = const [],
  }) : super(tagName: 'Fixture');

  factory FixtureNode.from(XmlElement element) {
    return FixtureNode(
      uuid: element.getAttribute('uuid')!,
      name: element.getAttribute('name') ?? '',
      multiPatch: element.getAttribute('multiPatch') ?? '',
      children: MVRNode.mapChildren(element.childElements),
    );
  }
}
