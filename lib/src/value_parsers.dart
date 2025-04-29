bool parseBool(String? value, {bool defaultValue = false}) {
  if (value == null) {
    return defaultValue;
  }

  if (value.toLowerCase() == "true") {
    return true;
  } else {
    return false;
  }
}
