import 'package:mvr/src/classes/xml_nodes/base/mvr_value_node.dart';
import 'package:xml/xml.dart';

class ColorValueNode extends MVRValueNode<CIEColor> {
  ColorValueNode(super.value) : super(tagName: "Color");

  factory ColorValueNode.from(XmlElement element) {
    return ColorValueNode(CIEColor.fromString(element.innerText.trim()));
  }
}

class CIEColor {
  final double x;
  final double y;
  final double bigY;

  CIEColor(this.x, this.y, this.bigY);

  factory CIEColor.fromString(String value) {
    final values = value.split(',').map((s) => double.parse(s.trim())).toList();
    return CIEColor(values[0], values[1], values[2]);
  }

  @override
  String toString() {
    return '$x, $y, $bigY';
  }
}
