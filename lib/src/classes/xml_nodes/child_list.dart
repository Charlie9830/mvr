import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:xml/xml.dart';

class ChildListNode extends MVRNode {
  List<MVRNode> children;

  ChildListNode({this.children = const []}) : super("ChildList");

  factory ChildListNode.from(XmlElement element) {
    return ChildListNode(children: MVRNode.mapChildren(element.childElements));
  }
}
