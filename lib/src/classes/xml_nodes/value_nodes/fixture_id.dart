import 'package:mvr/src/classes/xml_nodes/base/mvr_value_node.dart';
import 'package:xml/xml.dart';

class FixtureIdNodeValue extends MVRValueNode<String> {
  FixtureIdNodeValue(super.value) : super(tagName: "FixtureID");

  factory FixtureIdNodeValue.from(XmlElement element) {
    return FixtureIdNodeValue(element.innerText);
  }
}
