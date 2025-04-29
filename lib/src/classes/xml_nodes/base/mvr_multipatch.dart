import 'package:mvr/src/classes/xml_nodes/base/mvr_relationship.dart';

abstract class MultiPatch extends Relationship {
  final String multiPatch;

  MultiPatch({
    required super.uuid,
    super.name,
    this.multiPatch = '',
    required super.tagName,
  });
}
