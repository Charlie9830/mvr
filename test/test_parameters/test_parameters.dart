import 'dart:io';

import 'general_scene_description_test_parameters.dart';
import 'package:path/path.dart' as p;

import 'mvr_file_test_parameters.dart';

final generalGsdTestParams = GeneralSceneDescriptionTestParameters(
  testFilePath: p.join(
    Directory.current.path,
    'test_files',
    'GeneralSceneDescription_general.xml',
  ),
  layerNodeCount: 12,
  totalFixtureCount: 283,
  majorVersion: 1,
  minorVersion: 5,
);

final generalMvrTestParameters = MVRFileTestParameters(
  filePath: p.join(Directory.current.path, 'test_files', 'general.mvr'),
  invalidFilePath: p.join(Directory.current.path, 'test_files', 'not_a_proper_mvr_file.mvr'),
  gdtfFileCount: 8,
  layerCount: 12,
  totalFixtureCount: 283,
);
