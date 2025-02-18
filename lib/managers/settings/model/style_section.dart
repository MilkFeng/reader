import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

String _toHex(double value) {
  final newValue = clampDouble(value * 255, 0, 255).round();
  return newValue.toRadixString(16).padLeft(2, '0');
}

String _toCssColor(Color color) {
  final hexR = _toHex(color.r);
  final hexG = _toHex(color.g);
  final hexB = _toHex(color.b);
  final hexA = _toHex(color.a);

  final res = '#$hexR$hexG$hexB$hexA';
  return res;
}

int _fromHex(String hex) {
  return (int.parse(hex, radix: 16) / 255).round();
}

Color _fromCssColor(String color) {
  final r = _fromHex(color.substring(1, 3));
  final g = _fromHex(color.substring(3, 5));
  final b = _fromHex(color.substring(5, 7));
  final a = _fromHex(color.substring(7, 9));

  return Color.fromARGB(a, r, g, b);
}

final _mapEquality = MapEquality<String, String>();

class StyleSection {
  final String selector;
  final Map<String, String> _styles = {};

  StyleSection(this.selector);

  void operator []=(String key, String? value) {
    if (value == null || value.isEmpty) {
      remove(key);
    } else {
      _styles[key] = value;
    }
  }

  void remove(String key) {
    _styles.remove(key);
  }

  void clear() {
    _styles.clear();
  }

  String operator [](String key) {
    if (!_styles.containsKey(key)) {
      return '';
    }
    return _styles[key]!;
  }

  String toCss() {
    final buffer = StringBuffer();
    writeCss(buffer);
    return buffer.toString();
  }

  void writeCss(StringBuffer buffer) {
    if (_styles.isEmpty) {
      return;
    }
    buffer.write('$selector {');
    _styles.forEach((key, value) {
      buffer.write('$key: $value;');
    });
    buffer.write('}');
  }

  StyleSection copy() {
    final section = StyleSection(selector);
    section._styles.addAll(_styles);
    return section;
  }

  @override
  bool operator ==(Object other) {
    if (other is! StyleSection) {
      return false;
    }
    return other.selector == selector &&
        _mapEquality.equals(other._styles, _styles);
  }

  @override
  int get hashCode => hashObjects([selector, _styles]);

  double get fontSize => double.parse(this['font-size']);
  set fontSize(double value) => this['font-size'] = '$value';

  Color get color => _fromCssColor(this['color']);
  set color(Color value) => this['color'] = _toCssColor(value);

  Color get backgroundColor => _fromCssColor(this['background-color']);
  set backgroundColor(Color value) => this['background-color'] = _toCssColor(value);

  double get fontWeight => double.parse(this['font-weight']);
  set fontWeight(double value) => this['font-weight'] = '$value';

  double get letterSpacing => double.parse(this['letter-spacing']);
  set letterSpacing(double value) => this['letter-spacing'] = '${value}em';
}