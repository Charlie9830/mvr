import 'package:mvr/src/classes/mvr_data.dart';
import 'package:mvr/src/classes/xml_nodes/user_data.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/data_value_node.dart';

class MVRUserData {
  final List<MVRData> data;
  MVRUserData({this.data = const []});

  factory MVRUserData.fromNode(UserDataNode node) {
    return MVRUserData(
      data:
          node.children
              .whereType<DataValueNode>()
              .map((dataNode) => MVRData.fromNode(dataNode))
              .toList(),
    );
  }
}
