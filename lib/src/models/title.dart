// ignore_for_file: public_member_api_docs, sort_constructors_first
class Title {
  late final Map<String, dynamic> properties;

  Title._(this.properties);

  updateBBox(List<double> ltrb) {
    Map<String, dynamic> prop = Map.from(properties);
    prop['bbox'] = ltrb;
    Title._(prop);
  }

  Title(String title) {
    Map<String, dynamic> properties = {};

    List<String> propertiesRaw = title.split(';');
    for (String propertyRaw in propertiesRaw) {
      List<String> tmp = propertyRaw.trim().split(' ');
      String key = tmp[0].trim();
      List<String> values = tmp.sublist(1);

      switch (key) {
        case 'scan_res':
        case 'bbox':
        case 'x_wconf':
        case 'baseline':
        case "x_size":
        case "x_descenders":
        case "x_ascenders":
          properties[key] = values.length == 1
              ? double.parse(values[0])
              : values
                  .map(
                    (e) => double.parse(e),
                  )
                  .toList();

          break;

        case 'ppageno':
          properties[key] = values.length == 1
              ? int.parse(values[0])
              : values
                  .map(
                    (e) => int.parse(e),
                  )
                  .toList();

          break;
        case 'image':
          properties[key] = (values.length == 1) ? values[0] : values;
          break;
        default:
          properties[key] = values;
        // ignore: todo
        // TODO: Check if anything missed
      }
    }

    this.properties = properties;
  }
  pack() {
    return properties.entries
        .where((element) => element.value != null)
        .map((e) => "${e.key} ${packProperty(e.key, e.value)}")
        .join('; ')
        .replaceAll('"', "'");
  }

  packProperty(String key, dynamic value) {
    switch (key) {
      case 'scan_res':
      case 'bbox':
      case 'x_wconf':
        if (value.runtimeType == List<double>) {
          return (value as List<double>)
              .map((e) => e.toStringAsFixed(0))
              .join(' ');
        }
        return (value as double).toStringAsFixed(0);
      case 'baseline':
      case "x_size":
      case "x_descenders":
      case "x_ascenders":
        if (value.runtimeType == List<double>) {
          return (value as List<double>)
              .map((e) => e.toString().replaceAll(RegExp(r"\.0*$"), ""))
              .join(' ');
        }
        return (value as double).toString().replaceAll(RegExp(r"\.0*$"), "");
      case "ppageno":
        if (value.runtimeType == List<int>) {
          return (value as List<int>).map((e) => e.toString()).join(' ');
        }
        return (value as int).toString();

      case 'image':
        if (value.runtimeType == List<String>) {
          return (value as List<String>).join(' ');
        }
        return value as String;
      default:
        return value as String;
    }
  }

  @override
  String toString() => 'Title(properties: $properties)';
}
