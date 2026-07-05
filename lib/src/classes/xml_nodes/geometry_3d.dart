import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:xml/xml.dart';

class Geometry3dNode extends MVRNode {
  String fileName;
  List<MVRNode> children;

  Geometry3dNode({required this.fileName, this.children = const []})
    : super("Geometry3D");

  factory Geometry3dNode.from(XmlElement element) {
    return Geometry3dNode(
      fileName: element.getAttribute('fileName') ?? '',
      children: MVRNode.mapChildren(element.childElements),
    );
  }
}
