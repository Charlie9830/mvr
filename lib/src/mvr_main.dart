import 'dart:io';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:mvr/src/classes/gdtf/gdtf_fixture_type.dart';
import 'package:mvr/src/classes/glb.dart';
import 'package:mvr/src/classes/mvr_graphic_objects.dart';
import 'package:mvr/src/classes/xml_nodes/aux_data_node.dart';
import 'package:mvr/src/context.dart';
import 'package:mvr/src/decompression.dart';
import 'package:mvr/errors/file_not_found_error.dart';
import 'package:mvr/errors/malformed_general_scene_description_errror.dart';
import 'package:mvr/errors/missing_general_scene_description_error.dart';
import 'package:mvr/src/mvr_general_scene_description.dart';
import 'package:mvr/src/parse_general_scene_description.dart';

class MVR {
  final String filePath;

  /// The GDTF fixture types embedded in the archive, keyed by their file name
  /// (e.g. 'Clay Paky@Sharpy.gdtf'). Populated by [read] unless
  /// `parseGdtfFiles` is false.
  ///
  /// An MVR `Fixture` refers to its fixture type by file name — usually
  /// without the extension — so prefer [fixtureTypeOf] or [fixtureTypeByName]
  /// over indexing this map directly.
  Map<String, GDTFFixtureType> gdtfFixtureTypes = {};
  Map<String, GLB> glbs = {};
  Map<String, GDTFFixtureType> _fixtureTypesByNormalizedName = {};
  late MVRGeneralSceneDescription _generalSceneDescription;
  bool _initialized = false;

  MVRGeneralSceneDescription get generalSceneDescription =>
      _initialized == false
          ? throw 'You must call read() before accessing generalSceneDescription'
          : _generalSceneDescription;

  MVR({required this.filePath});

  /// The GDTF fixture type referenced by [fixture]'s `GDTFSpec` value, or
  /// null when the archive does not contain a matching (parseable) GDTF file.
  GDTFFixtureType? fixtureTypeOf(MVRFixture fixture) =>
      fixtureTypeByName(fixture.gdtfSpec);

  /// Looks up a fixture type by GDTF spec name, tolerating the `.gdtf`
  /// extension being present or absent and case differences — MVR files in
  /// the wild write `GDTFSpec` values both ways.
  GDTFFixtureType? fixtureTypeByName(String gdtfSpec) =>
      _fixtureTypesByNormalizedName[_normalizeGdtfSpecName(gdtfSpec)];

  static String _normalizeGdtfSpecName(String name) {
    var normalized = name.trim().toLowerCase();

    if (normalized.endsWith('.gdtf')) {
      normalized = normalized.substring(0, normalized.length - '.gdtf'.length);
    }

    return normalized;
  }

  Future<bool> read({bool parseGdtfFiles = true}) async {
    if (filePath.isEmpty) {
      throw MvrInvalidFilePathError(filePath);
    }

    final file = File(filePath);

    if (await file.exists() == false) {
      throw MVRFileNotFoundError(file.path);
    }

    try {
      final decompressionResult = await expandMvrFile(
        file,
        parseGdtfFiles: parseGdtfFiles,
      );
      gdtfFixtureTypes = decompressionResult.gdtfFixtureTypes;
      _fixtureTypesByNormalizedName = {
        for (final entry in gdtfFixtureTypes.entries)
          _normalizeGdtfSpecName(entry.key): entry.value,
      };
      glbs = decompressionResult.glbs;
      final intermediateGsd = parseGeneralSceneDescription(
        decompressionResult.generalSceneDescription,
      );

      _generalSceneDescription = MVRGeneralSceneDescription.build(
        Context(glbs: glbs, gsdNode: intermediateGsd),
      );
      _initialized = true;

      return true;
    } on ArchiveException catch (error) {
      throw MvrInvalidFileError(error.message);
    } on MissingGeneralSceneDescriptionError {
      throw MvrInvalidFileError(
        'The archive does not contain a GeneralSceneDescription.xml file.',
      );
    } on MalformedGeneralSceneDescriptionErrror {
      throw MvrInvalidFileError(
        'The GeneralSceneDescription.xml file is empty or malformed.',
      );
    }
  }
}

class MvrInvalidFilePathError extends Error {
  final String path;

  MvrInvalidFilePathError(this.path);
}

class MvrInvalidFileError extends ArchiveException {
  MvrInvalidFileError(super.message);
}
