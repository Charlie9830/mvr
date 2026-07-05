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
  invalidFilePath: p.join(
    Directory.current.path,
    'test_files',
    'not_a_proper_mvr_file.mvr',
  ),
  gdtfFileCount: 8,
  layerCount: 12,
  totalFixtureCount: 283,
);

final groupingGsdTestParams = GroupingTestParameters(
  filePath: p.join(Directory.current.path, 'test_files', 'grouping.mvr'),
  groupCount: 3,
  totalFixtureCount: 24,
  groupFixtureCount: 8,
);

final matrixTestParams = MatrixTestParameters(
  filePath: p.join(Directory.current.path, 'test_files', 'matrix_test.mvr'),
);

final trussTestParams = TrussTestParameters(
  filePath: p.join(Directory.current.path, 'test_files', 'truss.mvr'),
  layerCount: 2,
  trussCount: 2,
  trussName: 'BAT Truss 24" 8\'',
  trussUuids: const [
    '58988FB5-1579-4376-B320-946DDAFFC957',
    '2E4D5C5E-5D63-4840-8A04-357F08E56B4B',
  ],
  // Both trusses reference the same symdef; its largest glb measures
  // width 2.4892, height 0.3810, depth 0.6098 (metres).
  expectedLength: 2.4891990423202515,
  expectedWidth: 0.6097999811172485,
  expectedHeight: 0.38099971413612366,
);
