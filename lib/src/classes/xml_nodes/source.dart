import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';

enum SourceType {
  ndi("NDI"),
  file("File"),
  citp("CITP"),
  captureDevice("CaptureDevice");

  const SourceType(this.value);

  final String value;
}

class SourceNode extends MVRNode {
  String linkedGeometry;
  SourceType type;

  SourceNode({required this.linkedGeometry, required this.type}) : super("Source");
}
