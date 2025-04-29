import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:mvr/src/classes/xml_nodes/base/mvr_relationship.dart';

class MappingDefinitionNode extends Relationship {
  List<MVRNode> children;

  MappingDefinitionNode({
    required super.uuid,
    super.name,
    this.children = const [],
  }) : super(tagName: 'MappingDefinition');
}
