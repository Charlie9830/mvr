import 'package:mvr/src/classes/xml_nodes/base/mvr_value_node.dart';
import 'package:mvr/src/value_parsers.dart';
import 'package:xml/xml.dart';

class CastShadowValueNode extends MVRValueNode<bool> {
  CastShadowValueNode(super.value) : super(tagName: "CastShadow");

  factory CastShadowValueNode.from(XmlElement element) {
    return CastShadowValueNode(parseBool(element.innerText, defaultValue: false));
  }
}
