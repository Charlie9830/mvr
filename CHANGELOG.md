## 0.1.0

* Added GDTF fixture type support.
  * `.gdtf` files embedded in an MVR archive are now unzipped and their
    description.xml parsed into `GDTFFixtureType` objects, exposed via
    `MVR.gdtfFixtureTypes` and resolvable from a fixture with
    `MVR.fixtureTypeOf` / `MVR.fixtureTypeByName` (tolerant of the `.gdtf`
    extension and case differences in `GDTFSpec` values).
  * `GDTFFixtureType` exposes identity metadata, `Models`, the `Geometries`
    tree (including `GeometryReference` resolution) and the DMX mode ->
    geometry binding, plus render-ready flattened `parts` and fixture-local
    bounding boxes (`boundingBox`, `boundingBoxForMode`, `partsForMode`).
  * All GDTF geometry is converted to MVR conventions on parse: right-handed,
    Z-up, mm, origin at the centre of the fixture's base.
  * New `GDTF` class for reading standalone `.gdtf` files.
  * `MVRMatrix` gains `multiply` and `transformDirection`, and is now
    exported.
* Breaking: `MVR.gdtfContents` (raw archive contents as strings) has been
  replaced by `MVR.gdtfFixtureTypes`, and the `expandGdtfFiles` parameter of
  `MVR.read()` is now `parseGdtfFiles`.

## 0.0.1

* Initial release: MVR archive reading, GeneralSceneDescription parsing,
  fixtures, groups and truss geometry.
