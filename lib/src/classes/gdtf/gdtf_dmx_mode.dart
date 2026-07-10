/// A GDTF `DMXMode` node, reduced to the information needed to resolve which
/// geometry tree a mode drives.
///
/// The mode name is what an MVR `Fixture` refers to via its `GDTFMode` value,
/// and [geometryName] names the top-level geometry tree that describes the
/// fixture in that mode.
class GDTFDmxMode {
  final String name;
  final String description;

  /// The name of the top-level geometry this mode is bound to.
  final String geometryName;

  GDTFDmxMode({
    required this.name,
    this.description = '',
    this.geometryName = '',
  });
}
