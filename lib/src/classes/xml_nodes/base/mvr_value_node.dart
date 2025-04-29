import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';

abstract class MVRValueNode<T extends Object> extends MVRNode {
  T value;

  MVRValueNode(this.value, {required String tagName}) : super(tagName);
}
