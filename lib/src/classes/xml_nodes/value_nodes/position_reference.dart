import 'package:mvr/src/classes/xml_nodes/base/mvr_value_node.dart';
import 'package:xml/xml.dart';

class PositionValueNode extends MVRValueNode<String> {
  PositionValueNode(super.value) : super(tagName: "Position");

  factory PositionValueNode.from(XmlElement element) {
    return PositionValueNode(element.innerText);
  }
}
