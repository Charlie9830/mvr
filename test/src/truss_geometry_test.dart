import 'dart:math' as math;

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
    test('Returns a zero box when the truss has no <Geometries/> node', () {
      final ctx = buildContext();
      final truss = MVRTruss.fromNode(
        ctx,
        trussNode(includeGeometries: false),
      );

      expect(truss.boundingBox.length, 0);
      expect(truss.boundingBox.width, 0);
      expect(truss.boundingBox.height, 0);
    });

    test('Returns a zero box when the referenced symdef is not in the lookup', () {
      final ctx = buildContext(); // No symdefs registered.
      final truss = MVRTruss.fromNode(
        ctx,
        trussNode(symdefIds: ['unknown-symdef']),
      );

      expect(truss.boundingBox.length, 0);
      expect(truss.boundingBox.width, 0);
      expect(truss.boundingBox.height, 0);
    });

    test('Returns a zero box when the glb for the geometry is missing', () {
      final ctx = buildContext(
        symdefs: {
          'symdef-a': ['truss.glb'],
        },
        glbs: {}, // The glb file itself was never decompressed/registered.
      );
      final truss = MVRTruss.fromNode(ctx, trussNode(symdefIds: ['symdef-a']));

      expect(truss.boundingBox.length, 0);
      expect(truss.boundingBox.width, 0);
      expect(truss.boundingBox.height, 0);
    });

    test('Maps glb axes to (length: X, width: Z, height: Y) and mm', () {
      final ctx = buildContext(
        symdefs: {
          'symdef-a': ['truss.glb'],
        },
        glbs: {
          // glb metres: X -> length, Z -> width, Y -> height. Values are
          // converted to mm (x1000) to match the MVR specification.
          'truss': GLB.sized(fileId: 'truss', width: 3, height: 0.29, depth: 0.29),
        },
      );

      final truss = MVRTruss.fromNode(ctx, trussNode(symdefIds: ['symdef-a']));

      expect(truss.boundingBox.length, closeTo(3000, 1e-6),
          reason: 'length should map from glb X, in mm');
      expect(truss.boundingBox.width, closeTo(290, 1e-6),
          reason: 'width should map from glb Z, in mm');
      expect(truss.boundingBox.height, closeTo(290, 1e-6),
          reason: 'height should map from glb Y, in mm');
    });

    test('Resolves the glb by the geometry file basename without extension', () {
      final ctx = buildContext(
        symdefs: {
          'symdef-a': ['models/nested/truss_2m.glb'],
        },
        glbs: {
          'truss_2m':
              GLB.sized(fileId: 'truss_2m', width: 2, height: 0.2, depth: 0.2),
        },
      );

      final truss = MVRTruss.fromNode(ctx, trussNode(symdefIds: ['symdef-a']));

      expect(truss.boundingBox.length, closeTo(2000, 1e-6));
    });

    test('Combines several glbs into the union of their bounds', () {
      // A larger glb that fully contains a smaller one: the union equals the
      // outer extent.
      final ctx = buildContext(
        symdefs: {
          'symdef-a': ['small.glb', 'large.glb'],
        },
        glbs: {
          'small': GLB.sized(fileId: 'small', width: 0.01, height: 0.01, depth: 0.01),
          'large': GLB.sized(fileId: 'large', width: 0.1, height: 0.1, depth: 0.1),
        },
      );

      final truss = MVRTruss.fromNode(ctx, trussNode(symdefIds: ['symdef-a']));

      expect(truss.boundingBox.length, closeTo(100, 1e-6));
      expect(truss.boundingBox.width, closeTo(100, 1e-6));
      expect(truss.boundingBox.height, closeTo(100, 1e-6));
    });

    test('Union spans beyond any single glb when geometry is offset', () {
      // Two 1m boxes sitting end to end along X (X in [0,1] and [2,3]). The
      // union spans X in [0,3] -> length 3 m = 3000 mm, larger than either
      // piece alone.
      final ctx = buildContext(
        symdefs: {
          'symdef-a': ['left.glb', 'right.glb'],
        },
        glbs: {
          'left': GLB(
            fileId: 'left',
            minX: 0, minY: 0, minZ: 0,
            maxX: 1, maxY: 1, maxZ: 1,
          ),
          'right': GLB(
            fileId: 'right',
            minX: 2, minY: 0, minZ: 0,
            maxX: 3, maxY: 1, maxZ: 1,
          ),
        },
      );

      final truss = MVRTruss.fromNode(ctx, trussNode(symdefIds: ['symdef-a']));

      expect(truss.boundingBox.length, closeTo(3000, 1e-6),
          reason: 'Union along X should span [0, 3] m');
      expect(truss.boundingBox.width, closeTo(1000, 1e-6));
      expect(truss.boundingBox.height, closeTo(1000, 1e-6));
    });

    test('Unions geometry across multiple symbols/symdefs', () {
      final ctx = buildContext(
        symdefs: {
          'symdef-a': ['a.glb'],
          'symdef-b': ['b.glb'],
        },
        glbs: {
          'a': GLB.sized(fileId: 'a', width: 0.01, height: 0.01, depth: 0.01),
          'b': GLB.sized(fileId: 'b', width: 0.5, height: 0.02, depth: 0.02),
        },
      );

      final truss = MVRTruss.fromNode(
        ctx,
        trussNode(symdefIds: ['symdef-a', 'symdef-b']),
      );

      expect(truss.boundingBox.length, closeTo(500, 1e-6),
          reason: 'Union length across both symdefs');
      expect(truss.boundingBox.width, closeTo(20, 1e-6));
      expect(truss.boundingBox.height, closeTo(20, 1e-6));
    });

    test('Ignores invalid glbs when computing the union', () {
      final ctx = buildContext(
        symdefs: {
          'symdef-a': ['broken.glb', 'good.glb'],
        },
        glbs: {
          'broken': GLB.invalid(fileId: 'broken'),
          'good': GLB.sized(fileId: 'good', width: 0.04, height: 0.05, depth: 0.06),
        },
      );

      final truss = MVRTruss.fromNode(ctx, trussNode(symdefIds: ['symdef-a']));

      expect(truss.boundingBox.length, closeTo(40, 1e-6));
      expect(truss.boundingBox.width, closeTo(60, 1e-6));
      expect(truss.boundingBox.height, closeTo(50, 1e-6));
    });

    test('Returns a zero box when every referenced glb is invalid', () {
      final ctx = buildContext(
        symdefs: {
          'symdef-a': ['broken.glb'],
        },
        glbs: {
          'broken': GLB.invalid(fileId: 'broken'),
        },
      );

      final truss = MVRTruss.fromNode(ctx, trussNode(symdefIds: ['symdef-a']));

      expect(truss.boundingBox.length, 0);
      expect(truss.boundingBox.width, 0);
      expect(truss.boundingBox.height, 0);
    });
  });

  group('MVRTruss world-space bounding box', () {
    // A 2 m x 0.2 m x 0.2 m glb whose geometry origin is at a corner: X in
    // [0, 2], Y (height) in [0, 0.2], Z (depth) in [0, 0.2] metres.
    GLB beam() => GLB(
          fileId: 'beam',
          minX: 0, minY: 0, minZ: 0,
          maxX: 2, maxY: 0.2, maxZ: 0.2,
        );

    Context beamContext() => buildContext(
          symdefs: {
            'symdef-a': ['beam.glb'],
          },
          glbs: {'beam': beam()},
        );

    test('With an identity matrix, corners sit in truss-local mm space', () {
      final truss =
          MVRTruss.fromNode(beamContext(), trussNode(symdefIds: ['symdef-a']));
      final box = truss.boundingBox;

      // (x, y, z)_gltf -> (x, -z, y) * 1000. Depth [0, 0.2] m -> Y [-200, 0] mm.
      expect(box.min.x, closeTo(0, 1e-6));
      expect(box.max.x, closeTo(2000, 1e-6));
      expect(box.min.y, closeTo(-200, 1e-6));
      expect(box.max.y, closeTo(0, 1e-6));
      expect(box.min.z, closeTo(0, 1e-6));
      expect(box.max.z, closeTo(200, 1e-6));
      expect(box.corners.length, 8);
    });

    test('center is the midpoint of the world box, and shifts with translation',
        () {
      final matrix = MVRMatrix([
        [1, 0, 0],
        [0, 1, 0],
        [0, 0, 1],
        [1000, 2000, 3000],
      ]);

      final truss = MVRTruss.fromNode(
        beamContext(),
        trussNode(
          symdefIds: ['symdef-a'],
          extraChildren: [MatrixValueNode(matrix)],
        ),
      );

      // Local centre: X 1000, Y -100, Z 100. Plus translation.
      expect(truss.center.x, closeTo(1000 + 1000, 1e-6));
      expect(truss.center.y, closeTo(-100 + 2000, 1e-6));
      expect(truss.center.z, closeTo(100 + 3000, 1e-6));
      expect(truss.center, equals(truss.boundingBox.center));
    });

    test('A 90-degree rotation about Z swaps the world length and width', () {
      // Rotating the long (X) axis onto Y makes the world-aligned box's X
      // extent equal the old width and its Y extent equal the old length.
      final matrix = MVRMatrix([
        [0, 1, 0],
        [-1, 0, 0],
        [0, 0, 1],
        [0, 0, 0],
      ]);

      final truss = MVRTruss.fromNode(
        beamContext(),
        trussNode(
          symdefIds: ['symdef-a'],
          extraChildren: [MatrixValueNode(matrix)],
        ),
      );
      final box = truss.boundingBox;

      // Local extents were length 2000 (X), width 200 (Y). After the rotation
      // they are swapped on the world axes; height (Z) is unchanged.
      expect(box.length, closeTo(200, 1e-6));
      expect(box.width, closeTo(2000, 1e-6));
      expect(box.height, closeTo(200, 1e-6));
    });

    test('objectBoundingBox keeps true local extents regardless of rotation',
        () {
      // A 45-degree rotation about Z grows the world-aligned box on X and Y,
      // but the object-space box must still report the truss's real dimensions.
      final c = math.cos(math.pi / 4);
      final s = math.sin(math.pi / 4);
      final matrix = MVRMatrix([
        [c, s, 0],
        [-s, c, 0],
        [0, 0, 1],
        [0, 0, 0],
      ]);

      final truss = MVRTruss.fromNode(
        beamContext(),
        trussNode(
          symdefIds: ['symdef-a'],
          extraChildren: [MatrixValueNode(matrix)],
        ),
      );

      // The world box has grown on at least one horizontal axis...
      expect(truss.boundingBox.length, greaterThan(200 + 1e-3));

      // ...but the object box still reports the true 2000 x 200 x 200 truss.
      expect(truss.objectBoundingBox.length, closeTo(2000, 1e-6));
      expect(truss.objectBoundingBox.width, closeTo(200, 1e-6));
      expect(truss.objectBoundingBox.height, closeTo(200, 1e-6));
    });

    test('objectBoundingBox is zero when no geometry resolves', () {
      final truss = MVRTruss.fromNode(
        buildContext(),
        trussNode(includeGeometries: false),
      );

      expect(truss.objectBoundingBox.length, 0);
      expect(truss.objectBoundingBox.width, 0);
      expect(truss.objectBoundingBox.height, 0);
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
