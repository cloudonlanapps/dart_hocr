enum HOCRElementType {
  none,
  page,
  carea,
  par,
  line,
  word,
  textfloat,
  header,
  photo,
  separator,
  caption;

  factory HOCRElementType.fromTag(String tag) =>
      typeDict.keys.firstWhere((k) => typeDict[k]!["tag"]! == tag);

  static Map<HOCRElementType, Map<String, String>> typeDict = {
    none: {"name": "None", "tag": "", "sep": ''},
    page: {"name": "Page", "tag": "ocr_page", "sep": '\n\n'},
    carea: {"name": "Capture Area", "tag": "ocr_carea", "sep": '\n\n'},
    par: {"name": "Paragraph", "tag": "ocr_par", "sep": ' '},
    line: {"name": "Line", "tag": "ocr_line", "sep": ' '},
    word: {"name": "Word", "tag": "ocrx_word", "sep": ''},
    textfloat: {"name": 'Text Float', "tag": "ocr_textfloat", "sep": '\n\n'},
    header: {"name": 'Header', "tag": "ocr_header", "sep": '\n\n'},
    photo: {"name": 'Photo', "tag": "ocr_photo", "sep": '\n\n'},
    separator: {"name": 'Seperator', "tag": "ocr_separator", "sep": '\n\n'},
    caption: {"name": 'Caption', "tag": "ocr_caption", "sep": '\n\n'}
  };

  String get name => typeDict[this]!["name"]!;

  String get tag => typeDict[this]!["tag"]!;

  String get seperator => typeDict[this]!["sep"]!;

  static List<String> get tags =>
      HOCRElementType.values.map((e) => e.tag).toList();

  static List<HOCRElementType> boxTypeSupported = <HOCRElementType>[
    none,
    carea,
    page,
    par,
    line,
    word
  ];
}
