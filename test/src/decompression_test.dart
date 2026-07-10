import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mvr/src/decompression.dart';
import '../test_parameters/test_parameters.dart';

void main() async {
  test('MVR File Decompression', () async {
    final result = await expandMvrFile(
      File(generalMvrTestParameters.filePath),
      parseGdtfFiles: true,
    );
    expect(
      result.gdtfFixtureTypes.length,
      8,
      reason: 'Unexpected number of GDTF fixture types parsed',
    );
    expect(
      result.generalSceneDescription.isNotEmpty,
      true,
      reason: 'Contents of General Scene Description were empty',
    );
  });
}
