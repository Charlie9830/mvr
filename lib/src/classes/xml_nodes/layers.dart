import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:xml/xml.dart';

class LayersNode extends MVRNode {
  List<MVRNode> children;

  LayersNode({this.children = const []}) : super("Layers");

  factory LayersNode.from(XmlElement element) {
    return LayersNode(children: MVRNode.mapChildren(element.childElements));
  }
}
