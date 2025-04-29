import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:xml/xml.dart';

class SceneNode extends MVRNode {
  final List<MVRNode> children;

  SceneNode({this.children = const []}) : super("Scene");

  factory SceneNode.from(XmlElement element) {
    return SceneNode(children: MVRNode.mapChildren(element.childElements));
  }
}
