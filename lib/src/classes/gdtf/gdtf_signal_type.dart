/// The type of signal carried by a GDTF `WiringObject`.
///
/// Like `GDTFConnectorType`, the spec lists a few
/// predefined values but allows custom ones (e.g. "Ethernet"), so this is a
/// sealed hierarchy of [GDTFPredefinedSignalType] and [GDTFCustomSignalType]
/// that can be switched over exhaustively.
sealed class GDTFSignalType {
  /// The signal type as written in description.xml.
  String get xmlValue;

  /// Parses a `SignalType` attribute value.
  ///
  /// Predefined types are matched case-insensitively (ignoring surrounding
  /// whitespace); any other non-blank value becomes a [GDTFCustomSignalType].
  /// Returns null when [value] is null or blank.
  static GDTFSignalType? fromXmlValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return GDTFPredefinedSignalType.fromXmlValue(value) ??
        GDTFCustomSignalType(value);
  }
}

/// The predefined signal types of the GDTF `WiringObject` `SignalType`
/// attribute.
enum GDTFPredefinedSignalType implements GDTFSignalType {
  power('Power'),
  dmx512('DMX512'),
  protocol('Protocol'),
  aes('AES'),
  analogVideo('AnalogVideo'),
  analogAudio('AnalogAudio');

  @override
  final String xmlValue;

  const GDTFPredefinedSignalType(this.xmlValue);

  static final Map<String, GDTFPredefinedSignalType> _byNormalisedValue = {
    for (final type in values) type.xmlValue.toLowerCase(): type,
  };

  /// The predefined type matching [value] (case-insensitive, ignoring
  /// surrounding whitespace), or null when [value] is not predefined.
  static GDTFPredefinedSignalType? fromXmlValue(String? value) =>
      _byNormalisedValue[value?.trim().toLowerCase()];
}

/// A signal type that is not one of the predefined types, e.g. "Ethernet".
final class GDTFCustomSignalType implements GDTFSignalType {
  /// The signal type exactly as written in description.xml.
  @override
  final String xmlValue;

  const GDTFCustomSignalType(this.xmlValue);

  @override
  bool operator ==(Object other) =>
      other is GDTFCustomSignalType && other.xmlValue == xmlValue;

  @override
  int get hashCode => xmlValue.hashCode;

  @override
  String toString() => 'GDTFCustomSignalType($xmlValue)';
}
