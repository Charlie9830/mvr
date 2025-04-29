class MVRNodeMissingAttributeError implements Exception {
  final String nodeName;
  final String missingAttributes;

  MVRNodeMissingAttributeError({
    required this.nodeName,
    required this.missingAttributes,
  });
}
