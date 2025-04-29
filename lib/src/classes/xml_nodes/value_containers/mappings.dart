import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:mvr/src/classes/xml_nodes/base/mvr_value_container.dart';
import 'package:xml/xml.dart';

class Mappings<Mapping> extends MVRValueContainer {
  Mappings(super.values) : super(tagName: 'Mappings');

  factory Mappings.from(XmlElement element) {
    return Mappings(MVRNode.mapChildren(element.childElements));
  }
}
