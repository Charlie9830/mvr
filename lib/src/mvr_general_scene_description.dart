import 'dart:io';
import 'package:mvr/src/classes/mvr_layer.dart';
import 'package:mvr/src/classes/mvr_user_data.dart';
import 'package:mvr/src/classes/xml_nodes/general_scene_description.dart';
import 'package:mvr/src/classes/xml_nodes/layer.dart';
import 'package:mvr/src/classes/xml_nodes/layers.dart';
import 'package:mvr/src/classes/xml_nodes/scene.dart';

import 'package:xml/xml.dart';

class MVRGeneralSceneDescription {
  final int mvrMajorVersion;
  final int mvrMinorVersion;
  final String provider;
  final String providerVersion;

  List<MVRLayer> layers;
  MVRUserData? userData;

  MVRGeneralSceneDescription({
    required this.layers,
    required this.mvrMajorVersion,
    required this.mvrMinorVersion,
    this.provider = '',
    this.providerVersion = '',
  });

  static MVRGeneralSceneDescription fromNode(GeneralSceneDescriptionNode gsd) {
    final layersNode =
        gsd.children
            .whereType<SceneNode>()
            .first
            .children
            .whereType<LayersNode>()
            .first;

    return MVRGeneralSceneDescription(
      mvrMajorVersion: gsd.verMajor,
      mvrMinorVersion: gsd.verMinor,
      provider: gsd.provider,
      providerVersion: gsd.providerVersion,
      layers:
          layersNode.children
              .whereType<LayerNode>()
              .map((layerNode) => MVRLayer.fromNode(layerNode))
              .toList(),
    );
  }
}
