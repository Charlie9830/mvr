import 'package:flutter_test/flutter_test.dart';
import 'package:mvr/src/classes/glb.dart';
import 'package:mvr/src/classes/xml_nodes/aux_data_node.dart';
import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:mvr/src/classes/xml_nodes/child_list.dart';
import 'package:mvr/src/classes/xml_nodes/general_scene_description.dart';
import 'package:mvr/src/classes/xml_nodes/geometry_3d.dart';
import 'package:mvr/src/classes/xml_nodes/scene.dart';
import 'package:mvr/src/classes/xml_nodes/symdef_node.dart';
import 'package:mvr/src/context.dart';

/// Builds a [GeneralSceneDescriptionNode] whose single [SceneNode] contains the
/// given [sceneChildren]. Version/provider values are irrelevant to [Context].
GeneralSceneDescriptionNode gsdWithScene(List<MVRNode> sceneChildren) {
  return GeneralSceneDescriptionNode(
    verMajor: 1,
    verMinor: 5,
    provider: 'test',
    providerVersion: '1.0',
    children: [SceneNode(children: sceneChildren)],
  );
}

/// Builds a [SymdefNode] whose [Geometry3dNode]s are nested inside a
/// `ChildList`, mirroring the real MVR schema layout.
SymdefNode symdefWithGeometry(String uuid, List<String> fileNames) {
  return SymdefNode(
    uuid: uuid,
    children: [
      ChildListNode(
        children:
            fileNames.map((f) => Geometry3dNode(fileName: f)).toList(),
      ),
    ],
  );
}

void main() {
  group('Context.symdefGeometryLookup construction', () {
    test('Is empty when the Scene has no <AUXData/> node', () {
      final ctx = Context(glbs: {}, gsdNode: gsdWithScene([]));

      expect(
        ctx.symdefGeometryLookup,
        isEmpty,
        reason: 'No AUXData node was present, lookup should be empty',
      );
    });

    test('Is empty when there is no <Scene/> node at all', () {
      final ctx = Context(
        glbs: {},
        gsdNode: GeneralSceneDescriptionNode(
          verMajor: 1,
          verMinor: 5,
          provider: 'test',
          providerVersion: '1.0',
          children: [],
        ),
      );

      expect(ctx.symdefGeometryLookup, isEmpty);
    });

    test('Is empty when <AUXData/> contains no <Symdef/> nodes', () {
      final ctx = Context(
        glbs: {},
        gsdNode: gsdWithScene([AUXDataNode(children: [])]),
      );

      expect(
        ctx.symdefGeometryLookup,
        isEmpty,
        reason: 'AUXData had no Symdef children, lookup should be empty',
      );
    });

    test('Maps a Symdef uuid to its nested <Geometry3D/> nodes', () {
      final ctx = Context(
        glbs: {},
        gsdNode: gsdWithScene([
          AUXDataNode(
            children: [symdefWithGeometry('symdef-a', ['models/truss.glb'])],
          ),
        ]),
      );

      expect(ctx.symdefGeometryLookup.keys, contains('symdef-a'));
      expect(ctx.symdefGeometryLookup['symdef-a'], hasLength(1));
      expect(
        ctx.symdefGeometryLookup['symdef-a']!.first.fileName,
        'models/truss.glb',
      );
    });

    test('Also accepts <Geometry3D/> declared directly under a Symdef', () {
      final ctx = Context(
        glbs: {},
        gsdNode: gsdWithScene([
          AUXDataNode(
            children: [
              SymdefNode(
                uuid: 'symdef-direct',
                children: [Geometry3dNode(fileName: 'direct.glb')],
              ),
            ],
          ),
        ]),
      );

      expect(ctx.symdefGeometryLookup['symdef-direct'], hasLength(1));
      expect(
        ctx.symdefGeometryLookup['symdef-direct']!.first.fileName,
        'direct.glb',
      );
    });

    test('Keys each Symdef separately by its uuid', () {
      final ctx = Context(
        glbs: {},
        gsdNode: gsdWithScene([
          AUXDataNode(
            children: [
              symdefWithGeometry('symdef-a', ['a.glb']),
              symdefWithGeometry('symdef-b', ['b1.glb', 'b2.glb']),
            ],
          ),
        ]),
      );

      expect(
        ctx.symdefGeometryLookup.keys,
        containsAll(['symdef-a', 'symdef-b']),
      );
      expect(ctx.symdefGeometryLookup['symdef-a'], hasLength(1));
      expect(ctx.symdefGeometryLookup['symdef-b'], hasLength(2));
    });

    test('Maps a Symdef with no geometry to an empty list', () {
      final ctx = Context(
        glbs: {},
        gsdNode: gsdWithScene([
          AUXDataNode(children: [symdefWithGeometry('symdef-empty', [])]),
        ]),
      );

      expect(ctx.symdefGeometryLookup.keys, contains('symdef-empty'));
      expect(ctx.symdefGeometryLookup['symdef-empty'], isEmpty);
    });

    test('Ignores non-Symdef children within <AUXData/>', () {
      final ctx = Context(
        glbs: {},
        gsdNode: gsdWithScene([
          AUXDataNode(
            children: [
              SceneNode(children: []), // Unrelated node, should be skipped.
              symdefWithGeometry('symdef-a', ['a.glb']),
            ],
          ),
        ]),
      );

      expect(ctx.symdefGeometryLookup.keys, ['symdef-a']);
    });

    test('Uses the first <AUXData/> node when several are present', () {
      final ctx = Context(
        glbs: {},
        gsdNode: gsdWithScene([
          AUXDataNode(children: [symdefWithGeometry('first', [])]),
          AUXDataNode(children: [symdefWithGeometry('second', [])]),
        ]),
      );

      expect(ctx.symdefGeometryLookup.keys, ['first']);
    });

    test('Retains the supplied glbs map', () {
      final glb = GLB.sized(fileId: 'truss', width: 1, height: 2, depth: 3);
      final ctx = Context(glbs: {'truss': glb}, gsdNode: gsdWithScene([]));

      expect(ctx.glbs['truss'], same(glb));
    });
  });
}
