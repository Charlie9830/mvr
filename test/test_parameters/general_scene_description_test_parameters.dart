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
