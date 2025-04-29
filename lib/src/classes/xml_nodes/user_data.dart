import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:xml/xml.dart';

class UserDataNode extends MVRNode {
  List<MVRNode> children;

  UserDataNode({this.children = const []}) : super("UserData");

  factory UserDataNode.from(XmlElement element) {
    return UserDataNode(children: MVRNode.mapChildren(element.childElements));
  }
}
