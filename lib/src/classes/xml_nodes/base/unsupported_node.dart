import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:xml/xml.dart';

class UnsupportedNode extends MVRNode {
  final List<MVRNode> children;

  UnsupportedNode({this.children = const []}) : super("AUXData");

  factory UnsupportedNode.from(XmlElement element) {
    print(
      "Warning creating Unsupported MVR Node. 'Tag = <${element.name.local}/>'",
    );
    return UnsupportedNode(
      children: MVRNode.mapChildren(element.childElements),
    );
  }
}
