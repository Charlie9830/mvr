import 'package:mvr/src/classes/mvr_layer.dart';
import 'package:mvr/src/classes/mvr_user_data.dart';
import 'package:mvr/src/classes/xml_nodes/layer.dart';
import 'package:mvr/src/classes/xml_nodes/layers.dart';
import 'package:mvr/src/classes/xml_nodes/scene.dart';
import 'package:mvr/src/context.dart';

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

  static MVRGeneralSceneDescription build(Context ctx) {
    final layersNode =
        ctx.gsdNode.children
            .whereType<SceneNode>()
            .first
            .children
            .whereType<LayersNode>()
            .first;

    return MVRGeneralSceneDescription(
      mvrMajorVersion: ctx.gsdNode.verMajor,
      mvrMinorVersion: ctx.gsdNode.verMinor,
      provider: ctx.gsdNode.provider,
      providerVersion: ctx.gsdNode.providerVersion,
      layers:
          layersNode.children
              .whereType<LayerNode>()
              .map((layerNode) => MVRLayer.fromNode(ctx, layerNode))
              .toList(),
    );
  }
}
