import 'package:archive/archive.dart';

class GdtfInvalidFilePathError extends Error {
  final String path;

  GdtfInvalidFilePathError(this.path);
}

class GdtfFileNotFoundError implements Exception {
  final String path;
  GdtfFileNotFoundError(this.path);
}

class MissingGdtfDescriptionError implements Exception {
  MissingGdtfDescriptionError();
}

class MalformedGdtfDescriptionError implements Exception {
  MalformedGdtfDescriptionError();
}

class GdtfInvalidFileError extends ArchiveException {
  GdtfInvalidFileError(super.message);
}
