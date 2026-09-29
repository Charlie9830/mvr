import 'package:mvr/src/classes/xml_nodes/classing.dart';
import 'package:mvr/src/classes/xml_nodes/position.dart';
import 'package:mvr/src/classes/xml_nodes/symdef_node.dart';

sealed class MVRMetaObject {
  final String uuid;
  final String name;

  MVRMetaObject({required this.uuid, required this.name});
}

class MVRSymdef extends MVRMetaObject {
  MVRSymdef({required super.uuid, required super.name});

  factory MVRSymdef.fromNode(SymdefNode node) {
    return MVRSymdef(uuid: node.uuid, name: node.name);
  }
}

class MVRPosition extends MVRMetaObject {
  MVRPosition({required super.uuid, required super.name});

  factory MVRPosition.fromNode(PositionNode node) {
    return MVRPosition(uuid: node.uuid, name: node.name);
  }
}

class MVRClass extends MVRMetaObject {
  MVRClass({required super.uuid, required super.name});

  factory MVRClass.fromNode(ClassNode node) {
    return MVRClass(uuid: node.uuid, name: node.name);
  }
}

class UnknownMetaObject extends MVRMetaObject {
  UnknownMetaObject() : super(name: 'Unknown', uuid: '');
}
