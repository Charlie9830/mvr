import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';

class SymbolNode extends MVRNode {
  String uuid;
  String symdef;

  SymbolNode({required this.uuid, required this.symdef}) : super("Symbol");
}
