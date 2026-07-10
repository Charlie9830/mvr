import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:mvr/src/archive_expand_result.dart';
import 'package:archive/archive.dart';
import 'package:mvr/errors/malformed_general_scene_description_errror.dart';
import 'package:mvr/errors/missing_general_scene_description_error.dart';
import 'package:mvr/src/classes/gdtf/gdtf_fixture_type.dart';
import 'package:mvr/src/classes/glb.dart';
import 'package:mvr/src/gdtf/gdtf_decompression.dart';
import 'package:path/path.dart' as p;

Future<ArchiveExpandResult> expandMvrFile(
  File file, {
  bool parseGdtfFiles = true,
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

    final Map<String, GDTFFixtureType> gdtfFixtureTypes = {};
    if (parseGdtfFiles) {
      final gdtfFiles = archive.files.where(
        (file) => p.extension(file.name).toLowerCase() == '.gdtf',
      );

      for (final file in gdtfFiles) {
        final bytes = file.readBytes();

        if (bytes == null) {
          continue;
        }

        try {
          gdtfFixtureTypes[file.name] = parseGdtfArchive(bytes);
        } catch (e) {
          // A fixture type that fails to parse should not prevent the rest of
          // the MVR file from being read; its geometry is simply unavailable.
          continue;
        }
      }
    }

    final glbFiles = archive.files.where(
      (file) => p.extension(file.name) == '.glb',
    );

    final glbs = Map<String, GLB>.fromEntries(
      glbFiles.map((file) {
        final id = p.basenameWithoutExtension(file.name);
        final bytes = file.readBytes();

        if (bytes == null) {
          return MapEntry(id, GLB.invalid(fileId: id));
        }

        return MapEntry(id, _buildGLB(id, ByteData.view(bytes.buffer)));
      }),
    );

    return ArchiveExpandResult(
      generalSceneDescription: gsdContents,
      gdtfFixtureTypes: gdtfFixtureTypes,
      glbs: glbs,
    );
  });
}

GLB _buildGLB(String id, ByteData data) {
  // 1. Validate GLB Header (Magic must be 0x46546C67 - "glTF")
  if (data.getUint32(0, Endian.little) != 0x46546C67) {
    return GLB.invalid(fileId: id);
  }

  // 2. Get JSON Chunk Length and Type
  // Offset 12: Chunk Length
  // Offset 16: Chunk Type (0x4E4F534A = "JSON")
  int jsonChunkLength = data.getUint32(12, Endian.little);
  int jsonChunkType = data.getUint32(16, Endian.little);

  if (jsonChunkType != 0x4E4F534A) {
    return GLB.invalid(fileId: id);
  }

  // 3. Extract and Parse JSON
  Uint8List jsonBytes = data.buffer.asUint8List().sublist(
    20,
    20 + jsonChunkLength,
  );
  String jsonString = utf8.decode(jsonBytes);
  Map<String, dynamic> gltf = json.decode(jsonString);

  // 4. Union the POSITION bounds of every mesh primitive.
  // Each primitive's accessor exposes a pre-computed min/max
  // (attributes['POSITION'] -> accessors[i].min / .max).
  try {
    double? minX, minY, minZ, maxX, maxY, maxZ;

    for (final mesh in (gltf['meshes'] as List)) {
      for (final primitive in (mesh['primitives'] as List)) {
        final accessor =
            gltf['accessors'][primitive['attributes']['POSITION']];

        final List<dynamic> min = accessor['min']; // [minX, minY, minZ]
        final List<dynamic> max = accessor['max']; // [maxX, maxY, maxZ]

        minX = _min(minX, min[0].toDouble());
        minY = _min(minY, min[1].toDouble());
        minZ = _min(minZ, min[2].toDouble());
        maxX = _max(maxX, max[0].toDouble());
        maxY = _max(maxY, max[1].toDouble());
        maxZ = _max(maxZ, max[2].toDouble());
      }
    }

    if (minX == null) {
      // No mesh primitives with position data.
      return GLB.invalid(fileId: id);
    }

    return GLB(
      fileId: id,
      minX: minX,
      minY: minY!,
      minZ: minZ!,
      maxX: maxX!,
      maxY: maxY!,
      maxZ: maxZ!,
    );
  } catch (e) {
    return GLB.invalid(fileId: id);
  }
}

double _min(double? current, double value) =>
    current == null || value < current ? value : current;

double _max(double? current, double value) =>
    current == null || value > current ? value : current;
