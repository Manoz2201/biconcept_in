import 'package:biconcept_in/content/copy.dart';
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      children: const [
        _Hero(),
        _Practices(),
        _SelectedWork(),
        _Philosophy(),
        _HomeFaqs(),
        CtaBand(),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final compact = BcBreakpoints.isCompact(context);
    final height = MediaQuery.sizeOf(context).height;
    final display = compact
        ? Theme.of(context).textTheme.displaySmall
        : Theme.of(context).textTheme.displayLarge;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const KenBurnsImage(
            url:
                'https://images.unsplash.com/photo-1600585154526-990dced4db0d?auto=format&fit=crop&w=2000&q=80',
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x660A0A0A),
                  Color(0x990A0A0A),
                  Color(0xE60A0A0A),
                ],
              ),
            ),
          ),
          PageInset(
            child: Padding(
              padding: EdgeInsets.only(
                top: compact ? 120 : 140,
                bottom: compact ? 48 : 72,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  const Kicker(SiteCopy.heroKicker),
                  const SizedBox(height: 20),
                  Text(SiteSeo.home.h1, style: display),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Text(
                      SiteCopy.philosophyBody,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: BcColors.goldSoft,
                          ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Wrap(
                    spacing: 14,
                    runSpacing: 12,
                    children: [
                      GoldButton(
                        label: SiteCopy.heroCtaPrimary,
                        onPressed: () => context.go('/inquire'),
                      ),
                      GoldButton(
                        label: SiteCopy.heroCtaSecondary,
                        variant: GoldButtonVariant.outline,
                        onPressed: () => context.go('/work'),
                      ),
                    ],
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

class _Practices extends StatelessWidget {
  const _Practices();

  @override
  Widget build(BuildContext context) {
    final compact = BcBreakpoints.isCompact(context);
    return PageInset(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: compact ? 72 : 112),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Reveal(child: Kicker(SiteCopy.practicesKicker)),
            const SizedBox(height: 14),
            Reveal(
              delay: const Duration(milliseconds: 80),
              child: Text(
                SiteCopy.practicesTitle,
                style: compact
                    ? Theme.of(context).textTheme.displaySmall
                    : Theme.of(context).textTheme.displayMedium,
              ),
            ),
            const SizedBox(height: 16),
            Reveal(
              delay: const Duration(milliseconds: 140),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Text(
                  SiteCopy.practicesBody,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: BcColors.muted,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            if (compact)
              Column(
                children: [
                  for (final practice in Practices.all) ...[
                    _PracticeCard(practice: practice, tall: true),
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
                      child: _PracticeCard(
                        practice: Practices.all[i],
                        tall: i == 1,
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _PracticeCard extends StatefulWidget {
  const _PracticeCard({required this.practice, required this.tall});

  final Practice practice;
  final bool tall;

  @override
  State<_PracticeCard> createState() => _PracticeCardState();
}

class _PracticeCardState extends State<_PracticeCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final height = widget.tall ? 460.0 : 400.0;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(widget.practice.route),
        child: SizedBox(
          height: height,
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  scale: _hover ? 1.06 : 1,
                  child: NetworkCover(url: widget.practice.imageUrl),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xE60A0A0A)],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Kicker(widget.practice.kicker),
                      const Spacer(),
                      Text(
                        widget.practice.label,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.practice.headline,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: BcColors.goldSoft,
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

class _SelectedWork extends StatelessWidget {
  const _SelectedWork();

  @override
  Widget build(BuildContext context) {
    final compact = BcBreakpoints.isCompact(context);
    final featured = Projects.featured;
    return ColoredBox(
      color: BcColors.charcoal,
      child: PageInset(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: compact ? 72 : 112),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Kicker(SiteCopy.workKicker),
              const SizedBox(height: 14),
              Text(
                SiteCopy.workTitle,
                style: compact
                    ? Theme.of(context).textTheme.displaySmall
                    : Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 16),
              Text(
                SiteCopy.workBody,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: BcColors.muted),
              ),
              const SizedBox(height: 40),
              for (var i = 0; i < featured.length; i++) ...[
                _FeaturedTile(project: featured[i], reverse: !compact && i.isOdd),
                SizedBox(height: compact ? 28 : 40),
              ],
              GoldButton(
                label: SiteCopy.workAll,
                variant: GoldButtonVariant.outline,
                onPressed: () => context.go('/work'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedTile extends StatefulWidget {
  const _FeaturedTile({required this.project, required this.reverse});

  final Project project;
  final bool reverse;

  @override
  State<_FeaturedTile> createState() => _FeaturedTileState();
}

class _FeaturedTileState extends State<_FeaturedTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final compact = BcBreakpoints.isCompact(context);
    final image = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(widget.project.route),
        child: AspectRatio(
          aspectRatio: compact ? 4 / 3 : 16 / 11,
          child: ClipRect(
            child: AnimatedScale(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              scale: _hover ? 1.05 : 1,
              child: NetworkCover(url: widget.project.heroUrl),
            ),
          ),
        ),
      ),
    );

    final copy = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 0 : 36,
        vertical: compact ? 18 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Kicker('${widget.project.practiceLabel}  ·  ${widget.project.year}'),
          const SizedBox(height: 12),
          Text(widget.project.title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            widget.project.location,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          Text(
            widget.project.lede,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: BcColors.muted),
          ),
        ],
      ),
    );

    if (compact) {
      return Reveal(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [image, copy],
        ),
      );
    }

    final children = widget.reverse ? [copy, image] : [image, copy];
    return Reveal(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: widget.reverse ? 2 : 3, child: children[0]),
          Expanded(flex: widget.reverse ? 3 : 2, child: children[1]),
        ],
      ),
    );
  }
}

class _Philosophy extends StatelessWidget {
  const _Philosophy();

  @override
  Widget build(BuildContext context) {
    final compact = BcBreakpoints.isCompact(context);
    return PageInset(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: compact ? 72 : 120),
        child: Reveal(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Kicker(SiteCopy.philosophyKicker),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: Text(
                  SiteCopy.philosophyTitle,
                  style: compact
                      ? Theme.of(context).textTheme.displaySmall
                      : Theme.of(context).textTheme.displayMedium,
                ),
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Text(
                  SiteCopy.philosophyBody,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: BcColors.muted,
                        fontSize: 19,
                      ),
                ),
              ),
              const SizedBox(height: 28),
              GoldButton(
                label: 'The studio',
                variant: GoldButtonVariant.ghost,
                onPressed: () => context.go('/studio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeFaqs extends StatelessWidget {
  const _HomeFaqs();

  @override
  Widget build(BuildContext context) {
    return FaqSection(items: SiteSeo.home.faqs);
  }
}
