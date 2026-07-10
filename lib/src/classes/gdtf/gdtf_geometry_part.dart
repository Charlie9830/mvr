import 'package:mvr/src/classes/gdtf/gdtf_geometry.dart';
import 'package:mvr/src/classes/gdtf/gdtf_model.dart';
import 'package:mvr/src/classes/mvr_bounding_box.dart';
import 'package:mvr/src/classes/mvr_vector3.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/matrix.dart';

/// One physical part of a fixture, flattened out of the GDTF geometry tree.
///
/// A part pairs a [geometry] node that carries a model with the node's
/// accumulated fixture-local [transform] (the composition of every `Position`
/// matrix from the tree root down to the node, with `GeometryReference`
/// nodes resolved). This is the render-ready form of the geometry tree:
/// consumers can draw each part without re-walking the tree themselves.
///
/// All coordinates follow the MVR convention: right-handed, Z-up, mm,
/// relative to the fixture's origin (the centre of its base). To place a part
/// in world space, combine [transform] with the owning `MVRFixture.matrix`.
class GDTFGeometryPart {
  final GDTFGeometry geometry;
  final GDTFModel model;

  /// The part's transform in fixture-local space (translation in mm).
  final MVRMatrix transform;

  GDTFGeometryPart({
    required this.geometry,
    required this.model,
    required this.transform,
  });

  /// The eight corners of the part's box in fixture-local space (mm).
  ///
  /// GDTF meshes are drawn around their own suspension point, so the model's
  /// box is approximated as centred on the geometry node's origin before
  /// being transformed. The corners stay oriented with the part, so they can
  /// be used to draw a rotated outline; use [boundingBox] for axis-aligned
  /// extents.
  List<MVRVector3> get corners {
    final hl = model.length / 2;
    final hw = model.width / 2;
    final hh = model.height / 2;

    return [
      for (final x in [-hl, hl])
        for (final y in [-hw, hw])
          for (final z in [-hh, hh])
            transform.transform(MVRVector3(x, y, z)),
    ];
  }

  /// The part's axis-aligned bounding box in fixture-local space (mm).
  MVRBoundingBox get boundingBox => MVRBoundingBox.fromWorldPoints(corners);
}
