import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';

enum ScaleKeepRatio {
  scaleKeepRatio("ScaleKeepRatio"),
  scaleIgnoreRatio("ScaleIgnoreRatio"),
  keepSizeCenter("KeepSizeCenter");

  final String value;

  const ScaleKeepRatio(this.value);
}

class ScaleHandlingNode extends MVRNode {
  ScaleKeepRatio value;

  ScaleHandlingNode({required this.value}) : super('ScaleHandling');
}
