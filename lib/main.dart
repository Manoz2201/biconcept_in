import 'package:biconcept_in/app.dart';
import 'package:biconcept_in/content/seo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  runApp(const BiConceptApp());
  SiteSeo.load();
}
