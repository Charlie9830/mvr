import 'package:mvr/src/classes/gdtf/gdtf_fixture_type.dart';
import 'package:mvr/src/classes/glb.dart';

class ArchiveExpandResult {
  final String generalSceneDescription;

  /// The parsed GDTF fixture types keyed by their file name within the
  /// archive (e.g. 'Clay Paky@Sharpy.gdtf').
  final Map<String, GDTFFixtureType> gdtfFixtureTypes;
  final Map<String, GLB> glbs;

  ArchiveExpandResult({
    required this.generalSceneDescription,
    required this.gdtfFixtureTypes,
    required this.glbs,
  });
}
