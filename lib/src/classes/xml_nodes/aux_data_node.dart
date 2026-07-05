import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:xml/xml.dart';

class AUXDataNode extends MVRNode {
  final List<MVRNode> children;

  AUXDataNode({this.children = const []}) : super("AUXData");

  factory AUXDataNode.from(XmlElement element) {
    return AUXDataNode(children: MVRNode.mapChildren(element.childElements));
  }
}
