import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:mvr/src/classes/mvr_addresses.dart';
import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:mvr/src/classes/xml_nodes/base/mvr_value_container.dart';
import 'package:mvr/src/classes/xml_nodes/base/mvr_value_node.dart';
import 'package:mvr/src/classes/xml_nodes/child_list.dart';
import 'package:mvr/src/classes/xml_nodes/fixture.dart';
import 'package:mvr/src/classes/xml_nodes/geometries_node.dart';
import 'package:mvr/src/classes/xml_nodes/group_object.dart';
import 'package:mvr/src/classes/xml_nodes/symbol_node.dart';
import 'package:mvr/src/classes/xml_nodes/truss_node.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/addesses.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/cast_shadow.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/child_position.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/classing_value_node.dart';
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
import 'package:mvr/src/context.dart';
import 'package:path/path.dart' as p;

sealed class MVRGraphicObject {
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
}

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
      fixtureId:
          MVRGraphicObject.extractValueNodeData<FixtureIdNodeValue, String>(
            node.children,
            "",
          ),
      classing:
          MVRGraphicObject.extractValueNodeData<ClassingValueNode, String>(
            node.children,
            "",
          ),
      castShadow:
          MVRGraphicObject.extractValueNodeData<CastShadowValueNode, bool>(
            node.children,
            false,
          ),
      unitNumber:
          MVRGraphicObject.extractValueNodeData<UnitNumberValueNode, int>(
            node.children,
            0,
          ),
      fixtureIdNumeric:
          MVRGraphicObject.extractValueNodeData<FixtureIdNumericValueNode, int>(
            node.children,
            0,
          ),
      childPosition:
          MVRGraphicObject.extractValueNodeData<ChildPositionValueNode, String>(
            node.children,
            '',
          ),
      dmxInvertPan:
          MVRGraphicObject.extractValueNodeData<DMXInvertPanValueNode, bool>(
            node.children,
            false,
          ),
      dmxInvertTilt:
          MVRGraphicObject.extractValueNodeData<DMXInvertTiltValueNode, bool>(
            node.children,
            false,
          ),
      focus: MVRGraphicObject.extractValueNodeData<
        FocusReferenceValueNode,
        String
      >(node.children, ''),
      function:
          MVRGraphicObject.extractValueNodeData<FunctionValueNode, String>(
            node.children,
            '',
          ),
      gdtfSpec:
          MVRGraphicObject.extractValueNodeData<GDTFSpecValueNode, String>(
            node.children,
            '',
          ),
      gdtfMode:
          MVRGraphicObject.extractValueNodeData<GDTFModeValueNode, String>(
            node.children,
            '',
          ),
      matrix: MVRGraphicObject.extractValueNodeData<MatrixValueNode, MVRMatrix>(
        node.children,
        const MVRMatrix.identity(),
      ),
      position:
          MVRGraphicObject.extractValueNodeData<PositionValueNode, String>(
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

class MVRTruss extends MVRGraphicObject {
  final String uuid;
  final String name;
  final String multipatch;

  final MVRMatrix matrix;
  final String classing;
  final double length;
  final double width;
  final double height;

  /// Offset of the geometry's bounding-box centre from the matrix origin, along
  /// the truss length, width and height axes respectively. Add these (rotated by
  /// the matrix) to the translation to obtain the geometric centre.
  final double offsetLength;
  final double offsetWidth;
  final double offsetHeight;

  MVRTruss({
    required this.uuid,
    required this.name,
    required this.multipatch,
    required this.matrix,
    required this.classing,
    required this.width,
    required this.height,
    required this.length,
    this.offsetLength = 0,
    this.offsetWidth = 0,
    this.offsetHeight = 0,
  });

  factory MVRTruss.fromNode(Context ctx, TrussNode node) {
    final size = _lookupSize(ctx, node);

    return MVRTruss(
      uuid: node.uuid,
      name: node.name,
      multipatch: node.multiPatch,
      classing:
          MVRGraphicObject.extractValueNodeData<ClassingValueNode, String>(
            node.children,
            "",
          ),
      matrix: MVRGraphicObject.extractValueNodeData<MatrixValueNode, MVRMatrix>(
        node.children,
        const MVRMatrix.identity(),
      ),
      length: size.length,
      width: size.width,
      height: size.height,
      offsetLength: size.offsetLength,
      offsetWidth: size.offsetWidth,
      offsetHeight: size.offsetHeight,
    );
  }

  static _TrussSize _lookupSize(Context ctx, TrussNode truss) {
    final geometriesNode =
        truss.children.whereType<GeometriesNode>().firstOrNull;

    if (geometriesNode == null) {
      return _TrussSize.zero;
    }

    final symDefIds = geometriesNode.children.whereType<SymbolNode>().map(
      (symbol) => symbol.symdef,
    );

    final glbFileNames =
        symDefIds
            .map((id) => ctx.symdefGeometryLookup[id])
            .nonNulls
            .map((geometryList) => geometryList.map((geom) => geom.fileName))
            .flattened
            .toList();

    if (glbFileNames.isEmpty) {
      return _TrussSize.zero;
    }

    final glbs =
        glbFileNames
            .map((fileName) => ctx.glbs[p.basenameWithoutExtension(fileName)])
            .nonNulls
            .where((glb) => glb.valid)
            .toList();

    if (glbs.isEmpty) {
      return _TrussSize.zero;
    }

    // A truss can reference several geometry files (e.g. a main beam plus end
    // connectors). Combine them into a single axis-aligned bounding box so the
    // reported size represents the union of all geometry, not just one piece.
    final minX = glbs.map((glb) => glb.minX).reduce(math.min);
    final minY = glbs.map((glb) => glb.minY).reduce(math.min);
    final minZ = glbs.map((glb) => glb.minZ).reduce(math.min);
    final maxX = glbs.map((glb) => glb.maxX).reduce(math.max);
    final maxY = glbs.map((glb) => glb.maxY).reduce(math.max);
    final maxZ = glbs.map((glb) => glb.maxZ).reduce(math.max);

    // The glb bounds are in glTF space (right-handed, Y-up); MVR is right-handed
    // Z-up. Map the extents to Length (glTF X), Width (glTF Z) and Height
    // (glTF Y). The matrix translation locates the geometry's local origin,
    // which is not generally the bounding-box centre, so also report the centre
    // offset in MVR truss-local axes for callers to re-anchor to the centre.
    //
    // The Y-up -> Z-up conversion is (x, y, z) -> (x, -z, y), so the width axis
    // (glTF Z) maps to MVR -Y: negate the width offset accordingly.
    return _TrussSize(
      length: maxX - minX,
      width: maxZ - minZ,
      height: maxY - minY,
      offsetLength: (minX + maxX) / 2,
      offsetWidth: -(minZ + maxZ) / 2,
      offsetHeight: (minY + maxY) / 2,
    );
  }
}

/// Resolved physical size of a truss and the offset of its geometry centre from
/// the matrix origin, both in the (length, width, height) axis convention.
class _TrussSize {
  final double length;
  final double width;
  final double height;
  final double offsetLength;
  final double offsetWidth;
  final double offsetHeight;

  const _TrussSize({
    required this.length,
    required this.width,
    required this.height,
    required this.offsetLength,
    required this.offsetWidth,
    required this.offsetHeight,
  });

  static const zero = _TrussSize(
    length: 0,
    width: 0,
    height: 0,
    offsetLength: 0,
    offsetWidth: 0,
    offsetHeight: 0,
  );
}
