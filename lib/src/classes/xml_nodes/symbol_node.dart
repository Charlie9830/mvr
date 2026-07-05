import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:xml/xml.dart';

class SymbolNode extends MVRNode {
  String uuid;
  String symdef;

  SymbolNode({required this.uuid, required this.symdef}) : super("Symbol");

  factory SymbolNode.from(XmlElement element) {
    return SymbolNode(
      uuid: element.getAttribute('uuid') ?? '',
      symdef: element.getAttribute('symdef') ?? '',
    );
  }
}
