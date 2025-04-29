import 'package:mvr/src/classes/xml_nodes/base/mvr_value_node.dart';
import 'package:xml/xml.dart';

class GDTFModeValueNode extends MVRValueNode<String> {
  GDTFModeValueNode(super.value) : super(tagName: "GDTFMode");

  factory GDTFModeValueNode.from(XmlElement element) {
    return GDTFModeValueNode(element.innerText);
  }
}
