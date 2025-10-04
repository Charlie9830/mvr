import 'package:mvr/src/classes/xml_nodes/aux_data.dart';
import 'package:mvr/src/classes/xml_nodes/base/unsupported_node.dart';
import 'package:mvr/src/classes/xml_nodes/child_list.dart';
import 'package:mvr/src/classes/xml_nodes/classing.dart';
import 'package:mvr/src/classes/xml_nodes/fixture.dart';
import 'package:mvr/src/classes/xml_nodes/general_scene_description.dart';
import 'package:mvr/src/classes/xml_nodes/group_object.dart';
import 'package:mvr/src/classes/xml_nodes/layer.dart';
import 'package:mvr/src/classes/xml_nodes/layers.dart';
import 'package:mvr/src/classes/xml_nodes/scene.dart';
import 'package:mvr/src/classes/xml_nodes/scene_object.dart';
import 'package:mvr/src/classes/xml_nodes/user_data.dart';
import 'package:mvr/src/classes/xml_nodes/value_containers/mappings.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/addesses.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/address_value.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/cast_shadow.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/color_value_node.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/custom_id.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/fixture_id.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/fixture_id_numeric.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/fixture_type_id.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/gdtf_mode.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/gdtf_spec.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/matrix.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/unit_number.dart';
import 'package:xml/xml.dart';

abstract class MVRNode {
  String tagName;
  MVRNode(this.tagName);

  factory MVRNode.from(XmlElement element) {
    return switch (element.name.local) {
      'GeneralSceneDescription' => GeneralSceneDescriptionNode.from(element),
      'Scene' => SceneNode.from(element),
      'Layers' => LayersNode.from(element),
      'ChildList' => ChildListNode.from(element),
      'Fixture' => FixtureNode.from(element),
      'GroupObject' => GroupObjectNode.from(element),
      'UserData' => UserDataNode.from(element),
      'Layer' => LayerNode.from(element),
      'GDTFSpec' => GDTFSpecValueNode.from(element),
      'GDTFMode' => GDTFModeValueNode.from(element),
      'Addresses' => AddressesValueContainer.from(element),
      'Address' => AddressValueNode.from(element),
      'FixtureID' => FixtureIdNodeValue.from(element),
      'FixtureIDNumeric' => FixtureIdNumericValueNode.from(element),
      'UnitNumber' => UnitNumberValueNode.from(element),
      'FixtureTypeId' => FixtureTypeIdValueNode.from(element),
      'CustomId' => CustomIdValueNode.from(element),
      'CastShadow' => CastShadowValueNode.from(element),
      'Mappings' => Mappings.from(element),
      'AUXData' => AUXDataNode.from(element),
      'Matrix' => MatrixValueNode.from(element),
      'Classing' => ClassingNode.from(element),
      'Color' => ColorValueNode.from(element),
      'SceneObject' => SceneObjectNode.from(element),
      _ => UnsupportedNode.from(element),
    };
  }

  static List<MVRNode> mapChildren(Iterable<XmlElement> children) {
    return children.map((element) => MVRNode.from(element)).toList();
  }
}
