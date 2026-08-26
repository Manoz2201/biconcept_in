import 'package:biconcept_in/content/seo.dart';
import 'package:biconcept_in/core/layout/max_width.dart';
import 'package:biconcept_in/core/theme/breakpoints.dart';
import 'package:biconcept_in/core/theme/colors.dart';
import 'package:biconcept_in/core/widgets/reveal.dart';
import 'package:flutter/material.dart';

class FaqSection extends StatelessWidget {
  const FaqSection({super.key, required this.items});

  final List<FaqItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final compact = BcBreakpoints.isCompact(context);

    return PageInset(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: compact ? 56 : 88),
        child: Reveal(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Kicker('Questions'),
              const SizedBox(height: 12),
              Text('Asked before the brief.', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 28),
              for (var i = 0; i < items.length; i++) ...[
                _FaqTile(item: items[i]),
                if (i < items.length - 1) const Divider(color: BcColors.line, height: 1),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.item});

  final FaqItem item;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(vertical: 8),
        childrenPadding: const EdgeInsets.only(bottom: 20),
        iconColor: BcColors.brass,
        collapsedIconColor: BcColors.muted,
        title: Text(item.question, style: Theme.of(context).textTheme.headlineSmall),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item.answer,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: BcColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}
