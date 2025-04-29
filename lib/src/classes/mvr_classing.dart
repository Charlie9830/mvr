import 'package:mvr/src/classes/xml_nodes/classing.dart';

class MVRClassing {
  final String uuid;
  final String name;

  MVRClassing({required this.uuid, this.name = ''});

  factory MVRClassing.fromNode(ClassingNode node) {
    return MVRClassing(uuid: node.uuid, name: node.name);
  }
}
