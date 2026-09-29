import 'package:mvr/src/classes/xml_nodes/base/mvr_value_node.dart';
import 'package:xml/xml.dart';

class ClassingValueNode extends MVRValueNode<String> {
  ClassingValueNode(super.value, {super.tagName = "Classing"});

  factory ClassingValueNode.from(XmlElement element) {
    return ClassingValueNode(element.innerText);
  }
}
