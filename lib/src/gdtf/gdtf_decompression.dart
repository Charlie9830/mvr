import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:mvr/errors/gdtf_errors.dart';
import 'package:mvr/src/classes/gdtf/gdtf_fixture_type.dart';
import 'package:mvr/src/gdtf/parse_gdtf_description.dart';
import 'package:path/path.dart' as p;

/// Parses the bytes of a `.gdtf` archive (a zip containing description.xml)
/// into a [GDTFFixtureType].
///
/// Throws [MissingGdtfDescriptionError] when the archive has no
/// description.xml, [MalformedGdtfDescriptionError] when it is empty or not
/// valid GDTF XML, and [ArchiveException] when [bytes] is not a zip archive.
GDTFFixtureType parseGdtfArchive(Uint8List bytes) {
  final archive = ZipDecoder().decodeBytes(bytes);

  final descriptionFile = archive.files.firstWhereOrNull(
    (file) => p.basename(file.name).toLowerCase() == 'description.xml',
  );

  if (descriptionFile == null) {
    throw MissingGdtfDescriptionError();
  }

  final contentBytes = descriptionFile.readBytes();
  final contents =
      contentBytes == null ? '' : utf8.decode(contentBytes, allowMalformed: true);

  if (contents.trim().isEmpty) {
    throw MalformedGdtfDescriptionError();
  }

  return parseGdtfDescription(contents);
}
