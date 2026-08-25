import 'package:biconcept_in/content/copy.dart';
import 'package:biconcept_in/content/seo.dart';
import 'package:biconcept_in/core/layout/max_width.dart';
import 'package:biconcept_in/core/layout/site_scaffold.dart';
import 'package:biconcept_in/core/theme/breakpoints.dart';
import 'package:biconcept_in/core/theme/colors.dart';
import 'package:biconcept_in/core/widgets/cta_band.dart';
import 'package:biconcept_in/core/widgets/ken_burns.dart';
import 'package:biconcept_in/core/widgets/reveal.dart';
import 'package:flutter/material.dart';

class StudioPage extends StatelessWidget {
  const StudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final compact = BcBreakpoints.isCompact(context);
    return PageFrame(
      children: [
        SizedBox(
          height: compact ? 480 : 560,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const KenBurnsImage(
                url:
                    'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?auto=format&fit=crop&w=1800&q=80',
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x660A0A0A), Color(0xE60A0A0A)],
                  ),
                ),
              ),
              PageInset(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      const Kicker('Studio'),
                      const SizedBox(height: 16),
                      Text(
                        SiteSeo.studio.h1,
                        style: compact
                            ? Theme.of(context).textTheme.displaySmall
                            : Theme.of(context).textTheme.displayMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        PageInset(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: compact ? 56 : 88),
            child: Reveal(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Text(
                      SiteCopy.studioLede,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: BcColors.goldSoft,
                          ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Text(
                      SiteCopy.studioStory,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: BcColors.muted,
                            fontSize: 18,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ColoredBox(
          color: BcColors.charcoal,
          child: PageInset(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: compact ? 64 : 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Kicker('Approach'),
                  const SizedBox(height: 12),
                  Text('How we hold a brief.', style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 40),
                  if (compact)
                    Column(
                      children: [
                        for (final item in SiteCopy.approach) ...[
                          _ApproachCard(title: item.title, body: item.body),
                          const SizedBox(height: 16),
                        ],
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < SiteCopy.approach.length; i++) ...[
                          if (i > 0) const SizedBox(width: 20),
                          Expanded(
                            child: _ApproachCard(
                              title: SiteCopy.approach[i].title,
                              body: SiteCopy.approach[i].body,
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        const CtaBand(),
      ],
    );
  }
}

class _ApproachCard extends StatelessWidget {
  const _ApproachCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Reveal(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          border: Border.all(color: BcColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
