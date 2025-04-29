import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';

abstract class Relationship extends MVRNode {
  String uuid;
  String name;

  Relationship({required this.uuid, this.name = '', required String tagName})
    : super(tagName);
}
