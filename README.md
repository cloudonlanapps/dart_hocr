
# DART HOCR

A DART model to read and write HOCR in DART/Flutter projects. The objective of this project is to come up with a flexibile model for HOCR XML files for CRUD operations in it. 

This project is under development  and I am open to any suggestions. 

## HOCR
HOCR is a representation of various aspects of OCR output in an XML-like format. 
Refer [HOCR Specifications](https://kba.github.io/hocr-spec/1.2/) for more details

## Models:
This package contains a model that imports/exports HOCR XML into/from a Dart object. This model also supports few functionality required to implement a HOCR Viewer, as follows:
    
* element - the hocr element class enum
* node - An element with unique id
* doc - A set of HOCR nodes interconnected to form a tree
        note, this is equivalent of a HOCR xml file

### Features Planned: (X - currently supported)
```
[X] Import XML as `Doc` object
[X] Export a 'Doc' object into XML
[X] Soft Delete/Disable a node (mark as deleted | recoverable)
[ ] Hard Delete a node (permanently delete |  not recoverable)
[X] Edit text from a ocrx_word node.
[ ] JSON Support
[ ] Associate with an image
[ ] Merge Nodes of same class
```

### Supported Elements
```
ocr_page,
ocr_carea,
ocr_par,
ocr_line,
ocrx_word,
ocr_textfloat,
ocr_header,
ocr_photo,
ocr_separator,
ocr_caption
```

## How to use it:
* To read a HOCR XML string into object, use HOCRImport.fromXMLString(xmlString: xmlString).
* To write back the object into a XML string, use doc.xmlDocument.toXmlString()
* To extract the raw text from the XML string, getRawText(xmlString)

# Processing:
While, importing the data is processed for cleaning up to correct the alignment,
order etc, all are experimental now. Hoping to improve slowly. If any text misses, first disable the experimental features.

TODO: Provide an option to programatially disalble/enable processinng

# example:
a very simple application is provided to understand this package. This package 
is used in another flutter package that helps editing hocr files. 
Refer it for more details.

TODO: Provide a link to flutter HOCR Editor
