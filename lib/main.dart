import 'package:biconcept_in/app.dart';
import 'package:biconcept_in/content/seo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SiteSeo.load();
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  runApp(const BiConceptApp());
}
