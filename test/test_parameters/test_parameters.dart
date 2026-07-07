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
  layerCount: 1,
  trussCount: 4,
  // Sizes/centres are the world-aligned bounding box (mm) resolved from the
  // referenced glb geometry and transformed by each truss's matrix. The two
  // "3m Angled" trusses share their geometry with "3m Straight" but are rotated
  // (45 deg about Z, and 20 deg about Y respectively), which grows their
  // world-aligned extents accordingly.
  trusses: const [
    ExpectedTruss(
      uuid: '4700A71F-0121-45DF-A710-708F65D02191',
      name: '3m Straight',
      matrixX: -1000.0,
      matrixY: 2000.0,
      matrixZ: 0.0,
      length: 3006.3605825416744,
      width: 356.9999933242798,
      height: 406.99999034404755,
      centerX: 499.1802910808474,
      centerY: 2000.0,
      centerZ: 153.499998152256,
    ),
    ExpectedTruss(
      uuid: '222DF3E7-B26F-44D0-84DD-929B28187FF4',
      name: '2m Straight',
      matrixX: 1000.0,
      matrixY: 4000.0,
      matrixZ: 0.0,
      length: 2004.007629584521,
      width: 356.9999933242798,
      height: 406.99999034404755,
      centerX: 1998.0038146022707,
      centerY: 4000.0,
      centerZ: 153.499998152256,
    ),
    ExpectedTruss(
      uuid: '67D7A683-2834-4017-A770-393F11382287',
      name: '3m Angled',
      matrixX: -3000.0,
      matrixY: -2000.0,
      matrixZ: 0.0,
      length: 2378.2558067188475,
      width: 2378.2558067188475,
      height: 406.99999034404755,
      centerX: -1939.919121914695,
      centerY: -939.9191219146951,
      centerZ: 153.499998152256,
    ),
    ExpectedTruss(
      uuid: '61EE5930-9A45-41D7-BB8B-A29B7B1F6425',
      name: '3m Angled',
      matrixX: -5561.270664,
      matrixY: -4621.270664,
      matrixZ: 0.0,
      length: 2964.258131587804,
      width: 356.9999933242798,
      height: 1410.6904883672726,
      centerX: -4205.001508101399,
      centerY: -4621.270664,
      centerZ: 656.9925169191594,
    ),
  ],
);
