enum FieldType {
  text,
  multiline,
  code,
  number,
  boolean,
  dropdown,
  color,
  imagePath,
  group,
  list,
  nestedBlocks;

  static FieldType fromString(String value) {
    return FieldType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => FieldType.text,
    );
  }
}
