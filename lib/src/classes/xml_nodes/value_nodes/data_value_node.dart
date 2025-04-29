import 'package:mvr/src/classes/xml_nodes/base/mvr_value_node.dart';
import 'package:xml/xml.dart';

class DataValueNode extends MVRValueNode<String> {
  final String provider;
  final String ver;

  DataValueNode(super.value, {this.provider = '', this.ver = ''})
    : super(tagName: 'Data');

  factory DataValueNode.from(XmlElement element) {
    return DataValueNode(
      provider: element.getAttribute('provider') ?? '',
      ver: element.getAttribute('ver') ?? '',
      element.innerText,
    );
  }
}
