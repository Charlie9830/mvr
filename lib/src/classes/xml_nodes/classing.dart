import 'package:mvr/src/classes/xml_nodes/base/mvr_relationship.dart';
import 'package:xml/xml.dart';

class ClassingNode extends Relationship {
  ClassingNode({required super.uuid, super.name}) : super(tagName: 'Classing');

  factory ClassingNode.from(XmlElement element) {
    return ClassingNode(
      uuid: element.getAttribute('uuid') ?? '',
      name: element.getAttribute('name') ?? '',
    );
  }
}
