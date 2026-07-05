import 'package:flutter_test/flutter_test.dart';
import 'package:mvr/src/classes/glb.dart';
import 'package:mvr/src/classes/mvr_graphic_objects.dart';
import 'package:mvr/src/classes/xml_nodes/aux_data_node.dart';
import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:mvr/src/classes/xml_nodes/general_scene_description.dart';
import 'package:mvr/src/classes/xml_nodes/geometries_node.dart';
import 'package:mvr/src/classes/xml_nodes/geometry_3d.dart';
import 'package:mvr/src/classes/xml_nodes/scene.dart';
import 'package:mvr/src/classes/xml_nodes/symbol_node.dart';
import 'package:mvr/src/classes/xml_nodes/symdef_node.dart';
import 'package:mvr/src/classes/xml_nodes/truss_node.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/classing_value_node.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/matrix.dart';
import 'package:mvr/src/context.dart';

/// Builds a [Context] whose [Context.symdefGeometryLookup] is populated from
/// the given map of `symdef uuid -> glb file names`, alongside a set of glbs.
Context buildContext({
  Map<String, List<String>> symdefs = const {},
  Map<String, GLB> glbs = const {},
}) {
  final symdefNodes = symdefs.entries
      .map(
        (entry) => SymdefNode(
          uuid: entry.key,
          children:
              entry.value.map((fileName) => Geometry3dNode(fileName: fileName)).toList(),
        ),
      )
      .toList();

  return Context(
    glbs: glbs,
    gsdNode: GeneralSceneDescriptionNode(
      verMajor: 1,
      verMinor: 5,
      provider: 'test',
      providerVersion: '1.0',
      children: [
        SceneNode(children: [AUXDataNode(children: symdefNodes)]),
      ],
    ),
  );
}

/// Builds a [TrussNode] that references [symdefIds] via `Symbol` nodes nested
/// inside a `Geometries` node, plus any additional [extraChildren].
TrussNode trussNode({
  String uuid = 'truss-uuid',
  String name = 'Truss 1',
  List<String> symdefIds = const [],
  bool includeGeometries = true,
  List<MVRNode> extraChildren = const [],
}) {
  final symbols = symdefIds
      .map((id) => SymbolNode(uuid: 'symbol-$id', symdef: id))
      .toList();

  return TrussNode(
    uuid: uuid,
    tagName: 'Truss',
    name: name,
    multiPatch: '',
    children: [
      if (includeGeometries) GeometriesNode(children: symbols),
      ...extraChildren,
    ],
  );
}

void main() {
  group('MVRTruss size lookup', () {
    test('Returns zero size when the truss has no <Geometries/> node', () {
      final ctx = buildContext();
      final truss = MVRTruss.fromNode(
        ctx,
        trussNode(includeGeometries: false),
      );

      expect(truss.length, 0);
      expect(truss.width, 0);
      expect(truss.height, 0);
    });

    test('Returns zero size when the referenced symdef is not in the lookup', () {
      final ctx = buildContext(); // No symdefs registered.
      final truss = MVRTruss.fromNode(
        ctx,
        trussNode(symdefIds: ['unknown-symdef']),
      );

      expect(truss.length, 0);
      expect(truss.width, 0);
      expect(truss.height, 0);
    });

    test('Returns zero size when the glb for the geometry is missing', () {
      final ctx = buildContext(
        symdefs: {
          'symdef-a': ['truss.glb'],
        },
        glbs: {}, // The glb file itself was never decompressed/registered.
      );
      final truss = MVRTruss.fromNode(ctx, trussNode(symdefIds: ['symdef-a']));

      expect(truss.length, 0);
      expect(truss.width, 0);
      expect(truss.height, 0);
    });

    test('Maps glb axes to (length: width, width: depth, height: height)', () {
      final ctx = buildContext(
        symdefs: {
          'symdef-a': ['truss.glb'],
        },
        glbs: {
          // width -> length, depth -> width, height -> height.
          'truss': GLB(fileId: 'truss', width: 3000, height: 290, depth: 290),
        },
      );

      final truss = MVRTruss.fromNode(ctx, trussNode(symdefIds: ['symdef-a']));

      expect(truss.length, 3000, reason: 'length should map from glb.width');
      expect(truss.width, 290, reason: 'width should map from glb.depth');
      expect(truss.height, 290, reason: 'height should map from glb.height');
    });

    test('Resolves the glb by the geometry file basename without extension', () {
      final ctx = buildContext(
        symdefs: {
          'symdef-a': ['models/nested/truss_2m.glb'],
        },
        glbs: {
          'truss_2m': GLB(fileId: 'truss_2m', width: 2000, height: 200, depth: 200),
        },
      );

      final truss = MVRTruss.fromNode(ctx, trussNode(symdefIds: ['symdef-a']));

      expect(truss.length, 2000);
    });

    test('Picks the largest glb by volume when several are referenced', () {
      final ctx = buildContext(
        symdefs: {
          'symdef-a': ['small.glb', 'large.glb'],
        },
        glbs: {
          'small': GLB(fileId: 'small', width: 10, height: 10, depth: 10),
          'large': GLB(fileId: 'large', width: 100, height: 100, depth: 100),
        },
      );

      final truss = MVRTruss.fromNode(ctx, trussNode(symdefIds: ['symdef-a']));

      expect(truss.length, 100, reason: 'The largest-volume glb should win');
      expect(truss.width, 100);
      expect(truss.height, 100);
    });

    test('Aggregates geometry across multiple symbols/symdefs', () {
      final ctx = buildContext(
        symdefs: {
          'symdef-a': ['a.glb'],
          'symdef-b': ['b.glb'],
        },
        glbs: {
          'a': GLB(fileId: 'a', width: 10, height: 10, depth: 10),
          'b': GLB(fileId: 'b', width: 500, height: 20, depth: 20),
        },
      );

      final truss = MVRTruss.fromNode(
        ctx,
        trussNode(symdefIds: ['symdef-a', 'symdef-b']),
      );

      expect(truss.length, 500, reason: 'Largest glb across both symdefs');
    });
  });

  group('MVRTruss.fromNode passthrough properties', () {
    test('Copies identity and classing from the truss node', () {
      final ctx = buildContext();
      final node = trussNode(
        uuid: 'my-truss',
        name: 'Downstage Truss',
        includeGeometries: false,
        extraChildren: [ClassingValueNode('rig-class')],
      );

      final truss = MVRTruss.fromNode(ctx, node);

      expect(truss.uuid, 'my-truss');
      expect(truss.name, 'Downstage Truss');
      expect(truss.classing, 'rig-class');
    });

    test('Defaults to an identity matrix when no <Matrix/> is present', () {
      final ctx = buildContext();
      final truss = MVRTruss.fromNode(
        ctx,
        trussNode(includeGeometries: false),
      );

      expect(truss.matrix.x, 0);
      expect(truss.matrix.y, 0);
      expect(truss.matrix.z, 0);
    });

    test('Reads translation from a supplied <Matrix/> node', () {
      final ctx = buildContext();
      final matrix = MVRMatrix([
        [1, 0, 0],
        [0, 1, 0],
        [0, 0, 1],
        [1000, 2000, 3000],
      ]);

      final truss = MVRTruss.fromNode(
        ctx,
        trussNode(
          includeGeometries: false,
          extraChildren: [MatrixValueNode(matrix)],
        ),
      );

      expect(truss.matrix.x, 1000);
      expect(truss.matrix.y, 2000);
      expect(truss.matrix.z, 3000);
    });
  });
}
