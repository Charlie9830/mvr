import 'package:mvr/src/classes/mvr_meta_objects.dart';
import 'package:mvr/src/classes/xml_nodes/aux_data_node.dart';
import 'package:mvr/src/classes/xml_nodes/classing.dart';
import 'package:mvr/src/classes/xml_nodes/position.dart';
import 'package:mvr/src/classes/xml_nodes/symdef_node.dart';

class MVRAuxData {
  final List<MVRMetaObject> children;

  MVRAuxData({required this.children});

  factory MVRAuxData.fromNode(AUXDataNode node) {
    return MVRAuxData(
      children:
          node.children
              .map(
                (child) => switch (child) {
                  ClassNode n => MVRClass.fromNode(n),
                  PositionNode n => MVRPosition.fromNode(n),
                  SymdefNode n => MVRSymdef.fromNode(n),
                  _ => UnknownMetaObject(),
                },
              )
              .toList(),
    );
  }
}
