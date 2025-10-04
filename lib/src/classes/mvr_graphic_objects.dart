import 'package:collection/collection.dart';
import 'package:mvr/src/classes/mvr_addresses.dart';
import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:mvr/src/classes/xml_nodes/base/mvr_value_container.dart';
import 'package:mvr/src/classes/xml_nodes/base/mvr_value_node.dart';
import 'package:mvr/src/classes/xml_nodes/child_list.dart';
import 'package:mvr/src/classes/xml_nodes/fixture.dart';
import 'package:mvr/src/classes/xml_nodes/group_object.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/addesses.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/cast_shadow.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/child_position.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/dmx_invert_pan.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/dmx_invert_tilt.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/fixture_id.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/fixture_id_numeric.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/focus_reference.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/function.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/gdtf_mode.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/gdtf_spec.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/matrix.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/position_reference.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/unit_number.dart';

sealed class MVRGraphicObject {}

class MVRFixture extends MVRGraphicObject {
  final String uuid;
  final String name;
  final String multipatch;

  final MVRMatrix matrix;
  final String classing;
  final String gdtfSpec;
  final String gdtfMode;
  final String focus;
  final bool castShadow;
  final bool dmxInvertPan;
  final bool dmxInvertTilt;
  final String position;
  final String function;
  final int fixtureIdNumeric;
  final int unitNumber;
  final String childPosition;
  final MVRAddresses addresses;
  final String fixtureId;

  /* TODO:
  Protocols,
  Alignments,
  CustomCommands,
  Overwrites,
  Connections,
  Color,
  CustomIdType,
  CustomId,
  Mappings,
  Gobo
  ChildList,
  */

  MVRFixture({
    required this.uuid,
    required this.fixtureIdNumeric,
    required this.fixtureId,
    required this.unitNumber,
    required this.addresses,
    this.name = '',
    this.multipatch = '',
    this.matrix = const MVRMatrix.identity(),
    this.classing = '',
    this.gdtfSpec = '',
    this.gdtfMode = '',
    this.focus = '',
    this.castShadow = false,
    this.dmxInvertPan = false,
    this.dmxInvertTilt = false,
    this.position = '',
    this.function = '',
    this.childPosition = '',
  });

  factory MVRFixture.fromNode(FixtureNode node) {
    return MVRFixture(
      uuid: node.uuid,
      name: node.name,
      multipatch: node.multiPatch,
      fixtureId: extractValueNodeData<FixtureIdNodeValue, String>(
        node.children,
        "",
      ),
      castShadow: extractValueNodeData<CastShadowValueNode, bool>(
        node.children,
        false,
      ),
      unitNumber: extractValueNodeData<UnitNumberValueNode, int>(
        node.children,
        0,
      ),
      fixtureIdNumeric: extractValueNodeData<FixtureIdNumericValueNode, int>(
        node.children,
        0,
      ),
      childPosition: extractValueNodeData<ChildPositionValueNode, String>(
        node.children,
        '',
      ),
      dmxInvertPan: extractValueNodeData<DMXInvertPanValueNode, bool>(
        node.children,
        false,
      ),
      dmxInvertTilt: extractValueNodeData<DMXInvertTiltValueNode, bool>(
        node.children,
        false,
      ),
      focus: extractValueNodeData<FocusReferenceValueNode, String>(
        node.children,
        '',
      ),
      function: extractValueNodeData<FunctionValueNode, String>(
        node.children,
        '',
      ),
      gdtfSpec: extractValueNodeData<GDTFSpecValueNode, String>(
        node.children,
        '',
      ),
      gdtfMode: extractValueNodeData<GDTFModeValueNode, String>(
        node.children,
        '',
      ),
      matrix: extractValueNodeData<MatrixValueNode, MVRMatrix>(
        node.children,
        const MVRMatrix.identity(),
      ),
      position: extractValueNodeData<PositionValueNode, String>(
        node.children,
        '',
      ),
      addresses:
          node.children.whereType<AddressesValueContainer>().isNotEmpty
              ? MVRAddresses.fromNode(
                node.children.whereType<AddressesValueContainer>().first,
              )
              : MVRAddresses.empty(),
    );
  }

  static List<V> extractValueContainerData<
    T extends MVRValueContainer,
    V extends Object
  >(List<MVRNode> nodes, List<V> defaultValue) {
    final dirtyValue = nodes.whereType<T>().firstOrNull?.values;

    if (dirtyValue is List<V>) {
      return dirtyValue;
    }

    return defaultValue;
  }

  static V extractValueNodeData<T extends MVRValueNode, V extends Object>(
    List<MVRNode> nodes,
    V defaultValue,
  ) {
    final dirtyValue = nodes.whereType<T>().firstOrNull?.value;

    if (dirtyValue is V) {
      return dirtyValue;
    }

    return defaultValue;
  }

  MVRFixture copyWith({
    String? uuid,
    String? name,
    String? multipatch,
    MVRMatrix? matrix,
    String? classing,
    String? gdtfSpec,
    String? gdtfMode,
    String? focus,
    bool? castShadow,
    bool? dmxInvertPan,
    bool? dmxInvertTilt,
    String? position,
    String? function,
    int? fixtureIdNumeric,
    String? fixtureId,
    int? unitNumber,
    String? childPosition,
    MVRAddresses? addresses,
  }) {
    return MVRFixture(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      fixtureId: fixtureId ?? this.fixtureId,
      multipatch: multipatch ?? this.multipatch,
      matrix: matrix ?? this.matrix,
      classing: classing ?? this.classing,
      gdtfSpec: gdtfSpec ?? this.gdtfSpec,
      gdtfMode: gdtfMode ?? this.gdtfMode,
      focus: focus ?? this.focus,
      castShadow: castShadow ?? this.castShadow,
      dmxInvertPan: dmxInvertPan ?? this.dmxInvertPan,
      dmxInvertTilt: dmxInvertTilt ?? this.dmxInvertTilt,
      position: position ?? this.position,
      function: function ?? this.function,
      fixtureIdNumeric: fixtureIdNumeric ?? this.fixtureIdNumeric,
      unitNumber: unitNumber ?? this.unitNumber,
      childPosition: childPosition ?? this.childPosition,
      addresses: addresses ?? this.addresses,
    );
  }
}

class MVRGroupObject extends MVRGraphicObject {
  final String uuid;
  final String name;

  final List<MVRFixture> fixtures;

  MVRGroupObject({
    required this.uuid,
    required this.name,
    required this.fixtures,
  });

  factory MVRGroupObject.fromNode(GroupObjectNode node) {
    final childListNode = node.children.whereType<ChildListNode>().firstOrNull;

    return MVRGroupObject(
      uuid: node.uuid,
      name: node.name,
      fixtures:
          childListNode == null
              ? []
              : childListNode.children
                  .whereType<FixtureNode>()
                  .map((fixtureNode) => MVRFixture.fromNode(fixtureNode))
                  .toList(),
    );
  }
}
