import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../utils.dart';

class OCRImage {
  static const int ocrImageMaxWidth = 1200;
  static const int thumbnailHeight = 120;
  int? id;
  final String? title;
  final img.Image? image;
  final img.Image? thumbnail;
  final double width;
  final double height;
  final String lang1;
  final String? lang2;
  final String xml;
  final bool edittable;
  OCRImage(
      {this.id,
      this.title,
      this.image,
      required this.thumbnail,
      required this.width,
      required this.height,
      required this.lang1,
      this.lang2,
      required this.xml,
      this.edittable = true});

  OCRImage copyWith({
    int? id,
    String? title,
    img.Image? image,
    img.Image? thumbnail,
    double? width,
    double? height,
    String? lang1,
    String? lang2,
    String? xml,
    bool? edittable,
  }) {
    return OCRImage(
        id: id ?? this.id,
        title: title ?? this.title,
        image: image ?? this.image,
        thumbnail: thumbnail ?? this.thumbnail,
        width: width ?? this.width,
        height: height ?? this.height,
        lang1: lang1 ?? this.lang1,
        lang2: lang2 ?? this.lang2,
        xml: xml ?? this.xml,
        edittable: edittable ?? this.edittable);
  }

  static img.Image? decodeImage(Uint8List imageData,
      {bool optimalSize = false}) {
    final decodedImage = img.decodeImage(imageData);
    if (decodedImage == null ||
        (optimalSize && decodedImage.width <= ocrImageMaxWidth)) {
      return decodedImage;
    }

    double scale = ocrImageMaxWidth / decodedImage.width;

    return img.copyResize(decodedImage,
        width: (decodedImage.width * scale).toInt(),
        height: (decodedImage.height * scale).toInt());
  }

  //Important: This is an inplace process
  static img.Image binarize(img.Image src, int threshold) {
    final p = src.getBytes();
    for (var i = 0, len = p.length; i < len; i += 4) {
      final l = img.getLuminanceRgb(p[i], p[i + 1], p[i + 2]);
      final b = l > 150 ? 255 : 0;
      p[i] = b;
      p[i + 1] = b;
      p[i + 2] = b;
    }
    return src;
  }

  static img.Image getThumbnail(img.Image image) {
    double scale = thumbnailHeight / image.height;
    if (image.width * scale > thumbnailHeight) {
      scale = thumbnailHeight / image.width;
    }
    return img.copyResize(image,
        width: (image.width * scale).toInt(),
        height: (image.height * scale).toInt());
  }

  static Future<OCRImage> fromOCRData(
      {required Uint8List? image,
      required String lang1,
      int? id,
      String? title,
      String? lang2,
      Uint8List? thumbnail,
      double? width,
      double? height,
      required String xmlString}) async {
    if (image == null && width == null && height == null) {
      throw Exception(
          "You must either provide image or size parameters (width and height");
    }
    final rawImage =
        (image != null) ? decodeImage(image, optimalSize: false) : null;

    final tImage = (thumbnail != null)
        ? decodeImage(
            thumbnail,
            optimalSize: false,
          )
        : (rawImage != null)
            ? getThumbnail(rawImage)
            : null;

    return OCRImage(
      id: id,
      title: title,
      image: rawImage,
      thumbnail: tImage!,
      lang1: lang1,
      lang2: lang2,
      xml: xmlString,
      width: width ?? rawImage!.width.toDouble(),
      height: height ?? rawImage!.height.toDouble(),
    );
  }

  static Future<OCRImage> fromImageData(
      {required Uint8List image,
      required String lang1,
      int? id,
      String? title,
      String? lang2,
      required Future<String?> Function(
              {required Uint8List imageData,
              required String lang1,
              String? lang2})
          ocrProcessAPI}) async {
    final rawImage = decodeImage(image, optimalSize: true);

    if (rawImage == null) {
      // Failed to decode the image
      throw Exception(" Image decoding failed");
    }
    // Must get thumbnail before binarizing
    final thumbnail = getThumbnail(rawImage);
    //Important: This is an inplace process
    // final binarizedImage = OCRImage.binarize(rawImage, 150);
    try {
      final xml = await ocrProcessAPI(
        imageData: Uint8List.fromList(img.encodeJpg(rawImage, quality: 100)),
        lang1: lang1,
        lang2: lang2,
      );

      if (xml == null) throw Exception("OCR failed");

      return OCRImage(
        id: id,
        title: title,
        image: rawImage,
        thumbnail: thumbnail,
        lang1: lang1,
        lang2: lang2,
        xml: xml,
        width: rawImage.width.toDouble(),
        height: rawImage.height.toDouble(),
      );
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  String get langString => "$lang1${(lang2 == null) ? "" : ",$lang2"}";
  bool get hasId => (id != null);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'lang': lang1,
      'content': toContentMap()
    };
  }

  Map<String, dynamic> toContentMap() {
    return {
      'width': width,
      'height': height,
      'lang2': lang2,
      'xml': xml,
      'thumbnail': (thumbnail == null)
          ? null
          : Uint8List.fromList(img.encodePng(thumbnail!)).toList(),
      "contentType": 'ocr_image',
    };
  }

  static bool isOCRImage(String content) {
    try {
      final Map<String, dynamic> map = jsonDecode(content);
      return map['content']['contentType'] == 'ocr_image';
    } on Exception {
      return false;
    }
  }

  factory OCRImage.fromMap(Map<String, dynamic> map) {
    if (map['content']['contentType'] != 'ocr_image') {
      throw Exception("invalid image");
    }
    return OCRImage(
      id: map['id'] != null ? map['id'] as int : null,
      title: map['title'] != null ? map['title'] as String : null,
      lang1: map['lang'] as String,
      // From content

      width: map['content']['width'] as double,
      height: map['content']['height'] as double,
      lang2: map['content']['lang2'] != null ? map['lang2'] as String : null,
      xml: map['content']['xml'] as String,
      thumbnail: (map['content']['thumbnail'] != null)
          ? decodeImage(map['content']['thumbnail']!, optimalSize: false)!
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory OCRImage.fromJson(String source) =>
      OCRImage.fromMap(json.decode(source) as Map<String, dynamic>);

  String get text => getRawText(xmlString: xml);
}
