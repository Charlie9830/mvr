/// The type of connector on a GDTF `WiringObject`.
///
/// GDTF defines a list of predefined connector types (Annex D of the spec)
/// but also allows manufacturers to write any custom name, e.g. "Loose End"
/// or "etherCON". This sealed hierarchy models both cases type-safely:
///
/// * [GDTFPredefinedConnectorType]: an enum of every Annex D type.
/// * [GDTFCustomConnectorType]: any other value, preserved verbatim.
///
/// Because the hierarchy is sealed, a `switch` over a [GDTFConnectorType] is
/// checked for exhaustiveness, including each individual predefined value:
///
/// ```dart
/// final label = switch (wiringObject.connectorType) {
///   GDTFPredefinedConnectorType.xlr5 => '5-pin DMX',
///   GDTFPredefinedConnectorType() => 'Other predefined connector',
///   GDTFCustomConnectorType(:final xmlValue) => 'Custom: $xmlValue',
///   null => 'No connector',
/// };
/// ```
sealed class GDTFConnectorType {
  /// The connector type as written in description.xml.
  String get xmlValue;

  /// Parses a `ConnectorType` attribute value.
  ///
  /// Predefined types are matched case-insensitively (ignoring surrounding
  /// whitespace), since fixture files are inconsistent about casing, e.g.
  /// "powerCONTRUE1TOP" vs "PowerconTRUE1" in the spec itself. Any other
  /// non-blank value becomes a [GDTFCustomConnectorType]. Returns null when
  /// [value] is null or blank (the attribute does not apply to fuses).
  static GDTFConnectorType? fromXmlValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return GDTFPredefinedConnectorType.fromXmlValue(value) ??
        GDTFCustomConnectorType(value);
  }
}

/// The predefined connector types listed in Annex D (Table D.1) of the GDTF
/// specification.
enum GDTFPredefinedConnectorType implements GDTFConnectorType {
  bnc('BNC', 'BNC connector'),
  tblk('TBLK', 'Tag block'),
  tag('TAG', 'Solder tag'),
  krn('KRN', 'Krone block'),
  stj('STJ', 'Stereo jack'),
  mstj('MSTJ', 'Mini stereo jack'),
  rca('RCA', 'Phono connector'),
  scart('SCART', 'SCART connector'),
  sVideo('SVIDEO', '4-pin mini-DIN'),
  mdin4('MDIN4', '4-pin mini-DIN'),
  mdin5('MDIN5', '5-pin mini-DIN'),
  mdin6('MDIN6', '6-pin mini-DIN'),
  xlr3('XLR3', '3-pin XLR'),
  xlr4('XLR4', '4-pin XLR'),
  xlr5('XLR5', '5-pin XLR'),
  rj45('RJ45', '10/100 BaseT ethernet type'),
  rj11('RJ11', 'Telephone type'),
  db9('DB9', '9-pin D-type'),
  db15('DB15', '15-pin D-type'),
  db25('DB25', '25-pin D-type'),
  db37('DB37', '37-pin D-type'),
  db50('DB50', '50-pin D-type'),
  hd15('HD15', '15-pin D-type hi-density'),
  hd25('HD25', '25-pin D-type hi-density'),
  din3('DIN3', '3-pin DIN'),
  din5('DIN5', '5-pin DIN'),
  edac20('EDAC20', 'EDAC 20-pin'),
  edac38('EDAC38', 'EDAC 38-pin'),
  edac56('EDAC56', 'EDAC 56-pin'),
  edac90('EDAC90', 'EDAC 90-pin'),
  edac120('EDAC120', 'EDAC 120-pin'),
  dl96('DL96', 'DL 96-pin'),
  scsi68('SCSI68', 'SCSI connector 68-pin'),
  iee488('IEE488', 'IEE488 connector 36-pin'),
  cent50('CENT50', 'Centronics 50-pin'),
  cent36('CENT36', 'Centronics 36-pin'),
  cent24('CENT24', 'Centronics 24-pin'),
  displayPort('DisplayPort', 'DisplayPort connector'),
  dvi('DVI', 'DVI connector'),
  hdmi('HDMI', 'HDMI connector'),
  ps2('PS2', 'PS2 connector'),
  tlSt('TL-ST', 'TosLink connector'),
  lcDup('LCDUP', 'Fiber optic LC DUPLEX-type'),
  scDup('SCDUP', 'Fiber optic SC DUPLEX-type'),
  sc('SC', 'Fiber optic SC-type'),
  st('ST', 'Fiber optic ST-type'),
  nl4('NL4', 'Speakon'),
  cacom('CACOM', '8-pin LS conn'),
  usb('USB', 'USB connector'),
  nCon('N_CON', 'N connector'),
  fCon('F_CON', 'F connector'),
  iec60320C7C8('IEC 60320-C7/C8', 'Eurostecker'),
  cee7_7('CEE 7/7', 'Schutzkontakt'),
  iec60320C13C14('IEC 60320-C13/14', 'IEC 60320'),
  edison('Edison', 'Edison'),
  wieland('Wieland', 'Wieland'),
  cee16A2P('16A-CEE-2P', '16A-Blue'),
  cee16A2P110('16A-CEE-2P-110', '16A-Yellow'),
  cee16A('16A-CEE', '16A-CEE'),
  cee32A('32A-CEE', '32A-CEE'),
  cee32A2P('32A-CEE-2P', '32A-Blue'),
  cee32A2P110('32A-CEE-2P-110', '32A-Yellow'),
  cee63A('63A-CEE', '63A-CEE'),
  cee125A('125A-CEE', '125A-CEE'),
  powerlock('Powerlock', 'Powerlock'),
  powerlock120A('Powerlock 120A', 'Powerlock 120A'),
  powerlock400A('Powerlock 400A', 'Powerlock 400A'),
  powerlock660A('Powerlock 660A', 'Powerlock 660A'),
  powerlock800A('Powerlock 800A', 'Powerlock 800A'),
  camlock('Camlock', 'Camlock'),
  nac3fca('NAC3FCA', 'Powercon Blue'),
  nac3fcb('NAC3FCB', 'Powercon Grey'),
  powerconTrue1('PowerconTRUE1', 'Powercon TRUE1'),
  powerconTrue1Top('powerCONTRUE1TOP', 'powerCON TRUE1 TOP'),
  socapex16('Socapex-16', 'Socapex-16'),
  socapex7('Socapex-7', 'Socapex-7'),
  socapex9('Socapex-9', 'Socapex-9'),
  han16('HAN-16', 'HAN-16'),
  han4('HAN-4', 'HAN-4'),
  l6_20('L6-20', 'L6-20'),
  l15_30('L15-30', 'L15-30'),
  stagepin('Stagepin', 'Stagepin'),
  hubbell6_4('HUBBELL-6-4', 'HUBBELL 6-4'),
  din56905('DIN 56905', 'Eberl');

  @override
  final String xmlValue;

  /// The human readable description from Table D.1.
  final String description;

  const GDTFPredefinedConnectorType(this.xmlValue, this.description);

  static final Map<String, GDTFPredefinedConnectorType> _byNormalisedValue = {
    for (final type in values) type.xmlValue.toLowerCase(): type,
  };

  /// The predefined type matching [value] (case-insensitive, ignoring
  /// surrounding whitespace), or null when [value] is not an Annex D type.
  static GDTFPredefinedConnectorType? fromXmlValue(String? value) =>
      _byNormalisedValue[value?.trim().toLowerCase()];
}

/// A connector type that is not one of the Annex D predefined types, e.g.
/// "Loose End" or "etherCON".
final class GDTFCustomConnectorType implements GDTFConnectorType {
  /// The connector type exactly as written in description.xml.
  @override
  final String xmlValue;

  const GDTFCustomConnectorType(this.xmlValue);

  @override
  bool operator ==(Object other) =>
      other is GDTFCustomConnectorType && other.xmlValue == xmlValue;

  @override
  int get hashCode => xmlValue.hashCode;

  @override
  String toString() => 'GDTFCustomConnectorType($xmlValue)';
}
