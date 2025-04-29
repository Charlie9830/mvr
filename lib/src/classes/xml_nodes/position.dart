import 'package:mvr/src/classes/xml_nodes/base/mvr_relationship.dart';
import 'package:xml/xml.dart';

class PositionNode extends Relationship {
  PositionNode({required super.uuid, super.name}) : super(tagName: 'Position');

  factory PositionNode.from(XmlElement element) {
    return PositionNode(
      uuid: element.getAttribute('uuid')!,
      name: element.getAttribute('name') ?? '',
    );
  }
}
