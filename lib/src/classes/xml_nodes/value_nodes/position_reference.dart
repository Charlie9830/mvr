import 'package:mvr/src/classes/xml_nodes/base/mvr_value_node.dart';

class PositionValueNode extends MVRValueNode<String> {
  PositionValueNode(super.value) : super(tagName: "Position");
}
