import 'package:mvr/src/classes/xml_nodes/general_scene_description.dart';
import 'package:xml/xml.dart';

GeneralSceneDescriptionNode parseGeneralSceneDescription(String gsdContents) {
  final document = XmlDocument.parse(gsdContents);

  return GeneralSceneDescriptionNode.from(document.rootElement);
}
