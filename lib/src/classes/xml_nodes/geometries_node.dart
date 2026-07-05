import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:xml/xml.dart';

class GeometriesNode extends MVRNode {
  final List<MVRNode> children;
  GeometriesNode({this.children = const []}) : super("Geometries");

  factory GeometriesNode.from(XmlElement element) {
    return GeometriesNode(children: MVRNode.mapChildren(element.childElements));
  }
}
