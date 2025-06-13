import 'dart:convert';

import 'package:flutter/services.dart';

class Resourceloader {
  static Future<T> load<T>(
    String filename,
    T Function(dynamic decoded)? parser,
  ) async {
    final raw = await rootBundle.loadString("resources/$filename");

    if (T == String) {
      return raw as T;
    }

    final decoded = json.decode(raw);

    if (parser != null) {
      return parser(decoded);
    }

    return decoded as T;
  }
}
