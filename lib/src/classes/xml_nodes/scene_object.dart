import 'package:mvr/src/classes/xml_nodes/base/mvr_multipatch.dart';
import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:xml/xml.dart';

class SceneObjectNode extends MultiPatch {
  List<MVRNode> children;

  SceneObjectNode({
    required super.uuid,
    super.name,
    super.multiPatch,
    this.children = const [],
  }) : super(tagName: 'Fixture');

  factory SceneObjectNode.from(XmlElement element) {
    return SceneObjectNode(
      uuid: element.getAttribute('uuid')!,
      name: element.getAttribute('name') ?? '',
      multiPatch: element.getAttribute('multiPatch') ?? '',
      children: MVRNode.mapChildren(element.childElements),
    );
  }
}
