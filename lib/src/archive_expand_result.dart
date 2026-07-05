import 'package:mvr/src/classes/glb.dart';

class ArchiveExpandResult {
  final String generalSceneDescription;
  final Map<String, String> gdtfFiles;
  final Map<String, GLB> glbs;

  ArchiveExpandResult({
    required this.generalSceneDescription,
    required this.gdtfFiles,
    required this.glbs,
  });
}
