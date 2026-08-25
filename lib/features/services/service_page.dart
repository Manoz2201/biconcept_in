import 'package:biconcept_in/content/projects.dart';
import 'package:biconcept_in/content/seo.dart';
import 'package:biconcept_in/content/services.dart';
import 'package:biconcept_in/core/layout/max_width.dart';
import 'package:biconcept_in/core/layout/site_scaffold.dart';
import 'package:biconcept_in/core/theme/breakpoints.dart';
import 'package:biconcept_in/core/theme/colors.dart';
import 'package:biconcept_in/core/widgets/cta_band.dart';
import 'package:biconcept_in/core/widgets/faq_section.dart';
import 'package:biconcept_in/core/widgets/gold_button.dart';
import 'package:biconcept_in/core/widgets/ken_burns.dart';
import 'package:biconcept_in/core/widgets/reveal.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ServicePage extends StatelessWidget {
  const ServicePage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final practice = Practices.bySlug(slug);
    if (practice == null) {
      return const PageFrame(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 160, bottom: 80),
            child: Center(child: Text('Practice not found.')),
          ),
        ],
      );
    }

    final seo = SiteSeo.forPath(practice.route);
    final related = Projects.byKind(practice.kind).take(3).toList();
    final compact = BcBreakpoints.isCompact(context);

    return PageFrame(
      children: [
        _ServiceHero(practice: practice, h1: seo.h1),
        PageInset(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: compact ? 56 : 88),
            child: Reveal(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Text(
                  practice.lede,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: BcColors.goldSoft,
                        fontSize: 20,
                      ),
                ),
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
                  const Kicker('Process'),
                  const SizedBox(height: 12),
                  Text('How a brief becomes a place.', style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 40),
                  for (final step in practice.process)
                    _ProcessRow(step: step, compact: compact),
                ],
              ),
            ),
          ),
        ),
        PageInset(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: compact ? 64 : 96),
            child: Reveal(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Kicker('Deliverables'),
                  const SizedBox(height: 12),
                  Text('What you receive.', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 28),
                  for (final item in practice.deliverables)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 28,
                            child: Divider(color: BcColors.gold, endIndent: 12),
                          ),
                          Expanded(
                            child: Text(
                              item,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 36),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      GoldButton(
                        label: 'Start a concept',
                        onPressed: () => context.go('/inquire'),
                      ),
                      if (practice.kind == PracticeKind.realEstate)
                        GoldButton(
                          label: 'NCR listings',
                          variant: GoldButtonVariant.outline,
                          onPressed: () => context.go('/listings'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (related.isNotEmpty)
          ColoredBox(
            color: BcColors.panel,
            child: PageInset(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: compact ? 64 : 88),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Kicker('Related work'),
                    const SizedBox(height: 12),
                    Text('From this practice.', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 32),
                    _RelatedGrid(projects: related),
                  ],
                ),
              ),
            ),
          ),
        if (seo.faqs.isNotEmpty) FaqSection(items: seo.faqs),
        const CtaBand(),
      ],
    );
  }
}

class _ServiceHero extends StatelessWidget {
  const _ServiceHero({required this.practice, required this.h1});

  final Practice practice;
  final String h1;

  @override
  Widget build(BuildContext context) {
    final compact = BcBreakpoints.isCompact(context);
    return SizedBox(
      height: compact ? 520 : 640,
      child: Stack(
        fit: StackFit.expand,
        children: [
          KenBurnsImage(url: practice.imageUrl),
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
                  Kicker(practice.kicker),
                  const SizedBox(height: 16),
                  Text(
                    h1,
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
    );
  }
}

class _ProcessRow extends StatelessWidget {
  const _ProcessRow({required this.step, required this.compact});

  final ProcessStep step;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Reveal(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.index, style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 8),
                  Text(step.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(step.body, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  const Divider(color: BcColors.line),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 72,
                    child: Text(step.index, style: Theme.of(context).textTheme.labelSmall),
                  ),
                  Expanded(
                    child: Text(step.title, style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  Expanded(
                    child: Text(step.body, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ],
              ),
      ),
    );
  }
}

class _RelatedGrid extends StatelessWidget {
  const _RelatedGrid({required this.projects});

  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    final compact = BcBreakpoints.isCompact(context);
    if (compact) {
      return Column(
        children: [
          for (final project in projects) ...[
            _RelatedCard(project: project),
            const SizedBox(height: 16),
          ],
        ],
      );
    }
    return Row(
      children: [
        for (var i = 0; i < projects.length; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          Expanded(child: _RelatedCard(project: projects[i])),
        ],
      ],
    );
  }
}

class _RelatedCard extends StatefulWidget {
  const _RelatedCard({required this.project});

  final Project project;

  @override
  State<_RelatedCard> createState() => _RelatedCardState();
}

class _RelatedCardState extends State<_RelatedCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(widget.project.route),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRect(
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 600),
                  scale: _hover ? 1.05 : 1,
                  child: NetworkCover(url: widget.project.heroUrl),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(widget.project.title, style: Theme.of(context).textTheme.headlineSmall),
            Text(widget.project.location, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
