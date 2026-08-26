import 'package:biconcept_in/core/routing/app_router.dart';
import 'package:biconcept_in/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BiConceptApp extends StatefulWidget {
  const BiConceptApp({super.key, this.router});

  final GoRouter? router;

  @override
  State<BiConceptApp> createState() => _BiConceptAppState();
}

class _BiConceptAppState extends State<BiConceptApp> {
  late final GoRouter _router = widget.router ?? createRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BiConcept',
      debugShowCheckedModeBanner: false,
      theme: BcTheme.gallery,
      routerConfig: _router,
    );
  }
}
