import 'package:biconcept_in/content/copy.dart';
import 'package:biconcept_in/content/seo.dart';
import 'package:biconcept_in/content/services.dart';
import 'package:biconcept_in/core/layout/max_width.dart';
import 'package:biconcept_in/core/layout/site_scaffold.dart';
import 'package:biconcept_in/core/theme/breakpoints.dart';
import 'package:biconcept_in/core/theme/colors.dart';
import 'package:biconcept_in/core/widgets/cta_band.dart';
import 'package:biconcept_in/core/widgets/ken_burns.dart';
import 'package:biconcept_in/core/widgets/reveal.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
              const PhotoScrim(),
              PageInset(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      const Kicker('Studio', color: BcColors.brassHover),
                      const SizedBox(height: 16),
                      Text(
                        SiteSeo.studio.h1,
                        style: (compact
                                ? Theme.of(context).textTheme.displaySmall
                                : Theme.of(context).textTheme.displayMedium)
                            ?.copyWith(color: BcColors.photoInk),
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
                            color: BcColors.espresso,
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
        PageInset(
          child: Padding(
            padding: EdgeInsets.only(bottom: compact ? 56 : 88),
            child: Reveal(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Kicker(SiteCopy.studioPracticesKicker),
                  const SizedBox(height: 12),
                  Text(
                    SiteCopy.studioPracticesTitle,
                    style: compact
                        ? Theme.of(context).textTheme.displaySmall
                        : Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Text(
                      SiteCopy.studioPracticesBody,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: BcColors.muted),
                    ),
                  ),
                  const SizedBox(height: 36),
                  if (compact)
                    Column(
                      children: [
                        for (final practice in Practices.all) ...[
                          _StudioPracticeCard(
                            key: Key('studio-card-${practice.kind.slug}'),
                            practice: practice,
                          ),
                          const SizedBox(height: 18),
                        ],
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < Practices.all.length; i++) ...[
                          if (i > 0) const SizedBox(width: 18),
                          Expanded(
                            child: _StudioPracticeCard(
                              key: Key('studio-card-${Practices.all[i].kind.slug}'),
                              practice: Practices.all[i],
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
          color: BcColors.cream,
          border: Border.all(color: BcColors.line),
          borderRadius: BorderRadius.circular(BcColors.radius),
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

class _StudioPracticeCard extends StatefulWidget {
  const _StudioPracticeCard({super.key, required this.practice});

  final Practice practice;

  @override
  State<_StudioPracticeCard> createState() => _StudioPracticeCardState();
}

class _StudioPracticeCardState extends State<_StudioPracticeCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.go('/studio/${widget.practice.kind.slug}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _hover ? -6 : 0, 0),
          height: 420,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BcColors.radius),
            boxShadow: _hover
                ? [
                    BoxShadow(
                      color: BcColors.espresso.withValues(alpha: 0.16),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ]
                : const [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(BcColors.radius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  scale: _hover ? 1.06 : 1,
                  child: NetworkCover(url: widget.practice.imageUrl),
                ),
                const PhotoScrim(soft: true),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Kicker(widget.practice.kicker, color: BcColors.brassHover),
                      const Spacer(),
                      Text(
                        widget.practice.label,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: BcColors.photoInk,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.practice.kind == PracticeKind.realEstate
                            ? 'NCR listings, with photography and a short brief on each card.'
                            : widget.practice.headline,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: BcColors.photoInk.withValues(alpha: 0.82),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
