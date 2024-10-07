
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class Env {
  static load() async {
    final file = await rootBundle.loadString("assets/.env");
    return jsonDecode(file.split("GOOGLE_SERVICE_ACCOUNT_KEY=")[1]) as Map;
  }
}