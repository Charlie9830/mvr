import 'dart:io';

class GeneralSceneDescriptionTestParameters {
  final String testFilePath;
  final int majorVersion;
  final int minorVersion;

  final int userDataNodeCount = 1;
  final int sceneNodeCount = 1;
  final int layersNodeCount = 1;

  final int totalFixtureCount;
  final int layerNodeCount;

  GeneralSceneDescriptionTestParameters({
    required this.testFilePath,
    required this.majorVersion,
    required this.minorVersion,
    required this.layerNodeCount,
    required this.totalFixtureCount,
  });

  Future<String> getTestFileContents() async {
    return await File(testFilePath).readAsString();
  }
}

class GroupingTestParameters {
  final int groupCount;
  final int totalFixtureCount;
  final int groupFixtureCount;
  final String filePath;

  GroupingTestParameters({
    required this.filePath,
    required this.groupCount,
    required this.totalFixtureCount,
    required this.groupFixtureCount,
  });
}

class MatrixTestParameters {
  final String filePath;

  MatrixTestParameters({required this.filePath});
}

class TrussTestParameters {
  final String filePath;

  /// Total number of layers in the scene.
  final int layerCount;

  /// Number of `Truss` graphic objects across all layers.
  final int trussCount;

  /// Expected data for each truss in the scene, keyed by UUID.
  final List<ExpectedTruss> trusses;

  TrussTestParameters({
    required this.filePath,
    required this.layerCount,
    required this.trussCount,
    required this.trusses,
  });

  ExpectedTruss trussByUuid(String uuid) =>
      trusses.firstWhere((t) => t.uuid == uuid);
}

/// Expected properties of a single truss, used by the end-to-end tests.
///
/// Sizes and centre are the world-space, axis-aligned bounding box (MVR
/// convention: right-handed, Z-up, mm) resolved from the referenced glb
/// geometry and transformed by the truss matrix.
class ExpectedTruss {
  final String uuid;
  final String name;

  /// Matrix translation (mm).
  final double matrixX;
  final double matrixY;
  final double matrixZ;

  /// World-aligned bounding box extents (mm).
  final double length;
  final double width;
  final double height;

  /// World-space bounding box centre (mm).
  final double centerX;
  final double centerY;
  final double centerZ;

  const ExpectedTruss({
    required this.uuid,
    required this.name,
    required this.matrixX,
    required this.matrixY,
    required this.matrixZ,
    required this.length,
    required this.width,
    required this.height,
    required this.centerX,
    required this.centerY,
    required this.centerZ,
  });
}
