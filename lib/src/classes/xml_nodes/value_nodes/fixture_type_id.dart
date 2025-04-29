import 'package:mvr/src/classes/xml_nodes/base/mvr_value_node.dart';
import 'package:xml/xml.dart';

class FixtureTypeIdValueNode extends MVRValueNode<int> {
  FixtureTypeIdValueNode(super.value) : super(tagName: "FixtureTypeID");

  factory FixtureTypeIdValueNode.from(XmlElement element) {
    return FixtureTypeIdValueNode(int.parse(element.innerText.trim()));
  }
}
