import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive.dart';
import 'package:mvr/errors/gdtf_errors.dart';
import 'package:mvr/src/classes/gdtf/gdtf_fixture_type.dart';
import 'package:mvr/src/gdtf/gdtf_decompression.dart';

/// Reads a standalone `.gdtf` file and exposes its [GDTFFixtureType].
///
/// GDTF files embedded in an `.mvr` archive are parsed automatically by
/// `MVR.read()` and exposed via `MVR.gdtfFixtureTypes`; this class is for
/// fixture type files obtained on their own (e.g. from GDTF Share).
class GDTF {
  final String filePath;
  late GDTFFixtureType _fixtureType;
  bool _initialized = false;

  GDTFFixtureType get fixtureType =>
      _initialized == false
          ? throw 'You must call read() before accessing fixtureType'
          : _fixtureType;

  GDTF({required this.filePath});

  Future<bool> read() async {
    if (filePath.isEmpty) {
      throw GdtfInvalidFilePathError(filePath);
    }

    final file = File(filePath);

    if (await file.exists() == false) {
      throw GdtfFileNotFoundError(file.path);
    }

    try {
      _fixtureType = await Isolate.run(() async {
        final bytes = await file.readAsBytes();
        return parseGdtfArchive(bytes);
      });
      _initialized = true;

      return true;
    } on GdtfInvalidFileError {
      rethrow;
    } on MissingGdtfDescriptionError {
      throw GdtfInvalidFileError(
        'The archive does not contain a description.xml file.',
      );
    } on MalformedGdtfDescriptionError {
      throw GdtfInvalidFileError(
        'The description.xml file is empty or malformed.',
      );
    } on ArchiveException catch (error) {
      throw GdtfInvalidFileError(error.message);
    }
  }
}
