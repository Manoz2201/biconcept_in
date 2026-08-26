import 'package:biconcept_in/content/copy.dart';
import 'package:biconcept_in/content/services.dart';
import 'package:biconcept_in/core/layout/max_width.dart';
import 'package:biconcept_in/core/theme/breakpoints.dart';
import 'package:biconcept_in/core/theme/colors.dart';
import 'package:biconcept_in/core/widgets/gold_button.dart';
import 'package:biconcept_in/core/widgets/reveal.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CtaBand extends StatelessWidget {
  const CtaBand({super.key, this.practice});

  final PracticeKind? practice;

  @override
  Widget build(BuildContext context) {
    final compact = BcBreakpoints.isCompact(context);
    final kind = practice;
    final label = kind?.ctaLabel ?? SiteCopy.ctaButton;
    final path = kind?.inquirePath() ?? '/inquire';
    return ColoredBox(
      color: BcColors.stone,
      child: PageInset(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: compact ? 64 : 96),
          child: Reveal(
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Kicker(SiteCopy.ctaKicker),
                      const SizedBox(height: 16),
                      Text(
                        SiteCopy.ctaTitle,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        SiteCopy.ctaBody,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: BcColors.muted,
                            ),
                      ),
                      const SizedBox(height: 28),
                      GoldButton(
                        label: label,
                        onPressed: () => context.go(path),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Kicker(SiteCopy.ctaKicker),
                            const SizedBox(height: 16),
                            Text(
                              SiteCopy.ctaTitle,
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              SiteCopy.ctaBody,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: BcColors.muted,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      GoldButton(
                        label: label,
                        onPressed: () => context.go(path),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
