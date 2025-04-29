import 'package:mvr/src/classes/xml_nodes/base/mvr_value_node.dart';

class FocusReferenceValueNode extends MVRValueNode<String> {
  FocusReferenceValueNode(super.value) : super(tagName: "Focus");
}
