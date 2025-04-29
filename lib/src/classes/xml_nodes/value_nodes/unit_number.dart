import 'package:mvr/src/classes/xml_nodes/base/mvr_value_node.dart';
import 'package:xml/xml.dart';

class UnitNumberValueNode extends MVRValueNode<int> {
  UnitNumberValueNode(super.value) : super(tagName: "UnitNumber");

  factory UnitNumberValueNode.from(XmlElement element) {
    return UnitNumberValueNode(int.parse(element.innerText.trim()));
  }
}
