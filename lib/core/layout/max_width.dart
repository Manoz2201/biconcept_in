import 'package:biconcept_in/core/theme/breakpoints.dart';
import 'package:flutter/widgets.dart';

class PageInset extends StatelessWidget {
  const PageInset({super.key, required this.child, this.maxWidth});

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final compact = BcBreakpoints.isCompact(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? BcBreakpoints.pageMax),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 22 : 40),
          child: child,
        ),
      ),
    );
  }
}
