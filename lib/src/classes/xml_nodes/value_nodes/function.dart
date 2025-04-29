import 'package:mvr/src/classes/xml_nodes/base/mvr_value_node.dart';

class FunctionValueNode extends MVRValueNode<String> {
  FunctionValueNode(super.value) : super(tagName: "Function");
}
