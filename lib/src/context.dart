import 'package:mvr/src/classes/glb.dart';
import 'package:mvr/src/classes/xml_nodes/aux_data_node.dart';
import 'package:mvr/src/classes/xml_nodes/child_list.dart';
import 'package:mvr/src/classes/xml_nodes/general_scene_description.dart';
import 'package:mvr/src/classes/xml_nodes/geometry_3d.dart';
import 'package:mvr/src/classes/xml_nodes/scene.dart';
import 'package:mvr/src/classes/xml_nodes/symdef_node.dart';

class Context {
  Map<String, GLB> glbs;
  GeneralSceneDescriptionNode gsdNode;
  Map<String, List<Geometry3dNode>> symdefGeometryLookup = const {};

  Context({required this.glbs, required this.gsdNode}) {
    // Instantiate a Lookup of Geometry3D nodes, we will use these too lookup Truss sizes later.
    // In the MVR schema the AUXData node lives under the Scene node
    // (GeneralSceneDescription > Scene > AUXData), and each Symdef holds its
    // Geometry3D nodes inside a ChildList (Symdef > ChildList > Geometry3D).
    final auxDataNode = gsdNode.children
        .whereType<SceneNode>()
        .expand((scene) => scene.children)
        .whereType<AUXDataNode>()
        .firstOrNull;

    if (auxDataNode != null) {
      symdefGeometryLookup = Map<String, List<Geometry3dNode>>.fromEntries(
        auxDataNode.children.whereType<SymdefNode>().map(
          (symdef) => MapEntry(symdef.uuid, _geometryOf(symdef)),
        ),
      );
    }
  }

  /// Collects the [Geometry3dNode]s belonging to a [SymdefNode]. They are
  /// normally nested inside a ChildList, but direct children are also accepted
  /// so the lookup is resilient to either layout.
  static List<Geometry3dNode> _geometryOf(SymdefNode symdef) {
    return [
      ...symdef.children.whereType<Geometry3dNode>(),
      ...symdef.children
          .whereType<ChildListNode>()
          .expand((childList) => childList.children)
          .whereType<Geometry3dNode>(),
    ];
  }
}
