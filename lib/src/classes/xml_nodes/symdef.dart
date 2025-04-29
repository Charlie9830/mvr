import 'package:mvr/src/classes/xml_nodes/base/mvr_relationship.dart';

class SymdefNode extends Relationship {
  SymdefNode({required super.uuid, super.name}) : super(tagName: 'Symdef');
}
