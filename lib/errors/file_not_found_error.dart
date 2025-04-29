class MVRFileNotFoundError implements Exception {
  final String path;
  MVRFileNotFoundError(this.path);
}
