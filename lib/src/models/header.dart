class Header {
  final String name;
  final String? publicId;
  final String? systemId;
  final String? internalSubset;
  final Map<String, String> htmlAttributes;
  final String title;
  final List<Map<String, String>> meta;
  Header(
      {required this.name,
      this.publicId,
      this.systemId,
      this.internalSubset,
      required this.htmlAttributes,
      required this.title,
      required this.meta});
}
