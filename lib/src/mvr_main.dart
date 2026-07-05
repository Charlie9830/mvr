import 'dart:io';

import 'package:archive/archive.dart';
import 'package:mvr/src/classes/glb.dart';
import 'package:mvr/src/context.dart';
import 'package:mvr/src/decompression.dart';
import 'package:mvr/errors/file_not_found_error.dart';
import 'package:mvr/errors/malformed_general_scene_description_errror.dart';
import 'package:mvr/errors/missing_general_scene_description_error.dart';
import 'package:mvr/src/mvr_general_scene_description.dart';
import 'package:mvr/src/parse_general_scene_description.dart';

class MVR {
  final String filePath;
  Map<String, String> gdtfContents = {};
  Map<String, GLB> glbs = {};
  late MVRGeneralSceneDescription _generalSceneDescription;
  bool _initialized = false;

  MVRGeneralSceneDescription get generalSceneDescription =>
      _initialized == false
          ? throw 'You must call read() before accessing generalSceneDescription'
          : _generalSceneDescription;

  MVR({required this.filePath});

  Future<bool> read({bool expandGdtfFiles = true}) async {
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
        expandGdtfFiles: expandGdtfFiles,
      );
      gdtfContents = decompressionResult.gdtfFiles;
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
