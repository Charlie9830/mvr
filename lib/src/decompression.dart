import 'dart:io';
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:mvr/src/archive_expand_result.dart';
import 'package:archive/archive.dart';
import 'package:mvr/errors/malformed_general_scene_description_errror.dart';
import 'package:mvr/errors/missing_general_scene_description_error.dart';

Future<ArchiveExpandResult> expandMvrFile(
  File file, {
  bool expandGdtfFiles = true,
}) {
  return Isolate.run<ArchiveExpandResult>(() async {
    final decoder = ZipDecoder();
    final fileBytes = await file.readAsBytes();

    final archive = decoder.decodeBytes(fileBytes);

    final gsd = archive.files.firstWhereOrNull(
      (file) => file.name.toLowerCase() == "generalscenedescription.xml",
    );

    if (gsd == null) {
      throw MissingGeneralSceneDescriptionError();
    }

    final gsdContents = String.fromCharCodes(gsd.content ?? []);

    if (gsdContents.isEmpty) {
      throw MalformedGeneralSceneDescriptionErrror();
    }

    final Map<String, String> gdtfFileContents = {};
    if (expandGdtfFiles) {
      final gdtfFiles = archive.files.where(
        (file) => file.name.contains('.gdtf'),
      );

      gdtfFileContents.addEntries(
        gdtfFiles.map(
          (file) =>
              MapEntry(file.name, String.fromCharCodes(file.content ?? [])),
        ),
      );
    }

    return ArchiveExpandResult(
      generalSceneDescription: gsdContents,
      gdtfFiles: gdtfFileContents,
    );
  });
}
