import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:mvr/errors/mvr_format_error.dart';
import 'package:xml/xml.dart';

class GeneralSceneDescriptionNode extends MVRNode {
  int verMajor;
  int verMinor;
  String provider;
  String providerVersion;
  List<MVRNode> children;

  GeneralSceneDescriptionNode({
    required this.verMajor,
    required this.verMinor,
    required this.provider,
    required this.providerVersion,
    this.children = const [],
  }) : super("GeneralSceneDescription");

  factory GeneralSceneDescriptionNode.from(XmlElement element) {
    if (validateNode(element) == false) {
      throw MVRNodeMissingAttributeError(
        nodeName: 'GeneralSceneDescription',
        missingAttributes: 'Some Nodes',
      );
    }

    return GeneralSceneDescriptionNode(
      verMajor: int.parse(element.getAttribute('verMajor')!),
      verMinor: int.parse(element.getAttribute('verMinor')!),
      provider: element.getAttribute('provider') ?? '',
      providerVersion: element.getAttribute('providerVersion') ?? '',
      children: MVRNode.mapChildren(element.childElements),
    );
  }

  static bool validateNode(XmlElement element) {
    return element.name.local == 'GeneralSceneDescription' &&
        element.getAttribute('verMajor') != null &&
        element.getAttribute('verMinor') != null;
  }
}
