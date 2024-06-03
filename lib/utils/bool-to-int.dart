int boolToInt(bool value) {
  return value ? 1 : 0;
}

bool toBool(dynamic value) {
  if (value == 1 || value == true || value == 'true') {
    return true;
  }
  return false;
}