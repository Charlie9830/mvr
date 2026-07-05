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

  /// Name shared by both trusses in the file.
  final String trussName;

  /// UUIDs of the two trusses, in document order.
  final List<String> trussUuids;

  /// Expected resolved size of each truss (the union bounding box of all
  /// referenced glb geometry). Length maps from the union's X extent, width
  /// from Z, height from Y.
  final double expectedLength;
  final double expectedWidth;
  final double expectedHeight;

  TrussTestParameters({
    required this.filePath,
    required this.layerCount,
    required this.trussCount,
    required this.trussName,
    required this.trussUuids,
    required this.expectedLength,
    required this.expectedWidth,
    required this.expectedHeight,
  });
}
