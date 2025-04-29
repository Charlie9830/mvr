import 'package:mvr/src/classes/xml_nodes/base/mvr_value_node.dart';
import 'package:xml/xml.dart';

class FixtureIdNumericValueNode extends MVRValueNode<int> {
  FixtureIdNumericValueNode(super.value) : super(tagName: "FixtureIDNumeric");

  factory FixtureIdNumericValueNode.from(XmlElement element) {
    return FixtureIdNumericValueNode(
      int.tryParse(element.innerText.trim()) ?? 0,
    );
  }
}
