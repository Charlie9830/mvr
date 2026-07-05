import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:mvr/src/archive_expand_result.dart';
import 'package:archive/archive.dart';
import 'package:mvr/errors/malformed_general_scene_description_errror.dart';
import 'package:mvr/errors/missing_general_scene_description_error.dart';
import 'package:mvr/src/classes/glb.dart';
import 'package:path/path.dart' as p;

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
      gdtfFiles: gdtfFileContents,
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

  // 4. Find the first mesh's position accessor
  // Usually: meshes[0] -> primitives[0] -> attributes['POSITION']
  try {
    final int positionAccessorIndex =
        gltf['meshes'][0]['primitives'][0]['attributes']['POSITION'];
    final accessor = gltf['accessors'][positionAccessorIndex];

    List<dynamic> min = accessor['min']; // [minX, minY, minZ]
    List<dynamic> max = accessor['max']; // [maxX, maxY, maxZ]

    double width = (max[0] - min[0]).toDouble();
    double height = (max[1] - min[1]).toDouble();
    double depth = (max[2] - min[2]).toDouble();

    return GLB(fileId: id, depth: depth, height: height, width: width);
  } catch (e) {
    return GLB.invalid(fileId: id);
  }
}
