import 'package:mvr/src/classes/xml_nodes/base/mvr_relationship.dart';
import 'package:xml/xml.dart';

class ClassNode extends Relationship {
  ClassNode({required super.uuid, super.name}) : super(tagName: 'Classing');

  factory ClassNode.from(XmlElement element) {
    return ClassNode(
      uuid: element.getAttribute('uuid') ?? '',
      name: element.getAttribute('name') ?? '',
    );
  }
}
