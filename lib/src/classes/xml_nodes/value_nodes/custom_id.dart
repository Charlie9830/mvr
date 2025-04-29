import 'package:mvr/src/classes/xml_nodes/base/mvr_value_node.dart';
import 'package:xml/xml.dart';

class CustomIdValueNode extends MVRValueNode<int> {
  CustomIdValueNode(super.value) : super(tagName: "CustomID");

  factory CustomIdValueNode.from(XmlElement element) {
    return CustomIdValueNode(int.parse(element.innerText.trim()));
  }
}
