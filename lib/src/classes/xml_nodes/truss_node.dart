import 'package:mvr/src/classes/xml_nodes/base/mvr_multipatch.dart';
import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:xml/xml.dart';

class TrussNode extends MultiPatch {
  final List<MVRNode> children;

  TrussNode({
    required super.uuid,
    required super.tagName,
    this.children = const [],
    super.name,
    super.multiPatch,
  });

  factory TrussNode.from(XmlElement element) {
    return TrussNode(
      tagName: 'Truss',
      uuid: element.getAttribute('uuid')!,
      name: element.getAttribute('name') ?? '',
      multiPatch: element.getAttribute('multiPatch') ?? '',
      children: MVRNode.mapChildren(element.childElements),
    );
  }
}
