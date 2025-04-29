import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';

abstract class MVRValueContainer<T> extends MVRNode {
  List<T> values;

  MVRValueContainer(this.values, {required String tagName}) : super(tagName);
}
