import 'package:flutter/widgets.dart';

enum BcBreakpoint { compact, medium, expanded }

abstract final class BcBreakpoints {
  static const compactMax = 800.0;
  static const mediumMax = 1200.0;
  static const pageMax = 1280.0;
  static const wideMax = 1440.0;

  static BcBreakpoint of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < compactMax) return BcBreakpoint.compact;
    if (width < mediumMax) return BcBreakpoint.medium;
    return BcBreakpoint.expanded;
  }

  static bool isCompact(BuildContext context) =>
      of(context) == BcBreakpoint.compact;
}
