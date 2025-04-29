import 'package:mvr/src/classes/xml_nodes/base/mvr_value_node.dart';
import 'package:xml/xml.dart';

class GDTFSpecValueNode extends MVRValueNode<String> {
  GDTFSpecValueNode(super.value) : super(tagName: "GDTFSpec");

  factory GDTFSpecValueNode.from(XmlElement element) {
    return GDTFSpecValueNode(element.innerText);
  }
}
