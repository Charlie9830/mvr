import 'package:mvr/src/classes/xml_nodes/value_nodes/data_value_node.dart';

class MVRData {
  final String provider;
  final String ver;
  final String value;

  MVRData({this.provider = '', this.value = '', this.ver = ''});

  factory MVRData.fromNode(DataValueNode node) {
    return MVRData(provider: node.provider, ver: node.ver, value: node.value);
  }
}
