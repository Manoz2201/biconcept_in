import 'package:biconcept_in/content/projects.dart';
import 'package:biconcept_in/content/seo.dart';
import 'package:biconcept_in/content/services.dart';
import 'package:biconcept_in/core/layout/max_width.dart';
import 'package:biconcept_in/core/layout/site_scaffold.dart';
import 'package:biconcept_in/core/theme/breakpoints.dart';
import 'package:biconcept_in/core/theme/colors.dart';
import 'package:biconcept_in/core/widgets/cta_band.dart';
import 'package:biconcept_in/core/widgets/ken_burns.dart';
import 'package:biconcept_in/core/widgets/reveal.dart';
import 'package:biconcept_in/data/repositories.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WorkPage extends StatefulWidget {
  const WorkPage({super.key});

  @override
  State<WorkPage> createState() => _WorkPageState();
}

class _WorkPageState extends State<WorkPage> {
  PracticeKind? _filter;
  late Future<List<Project>> _future;

  @override
  void initState() {
    super.initState();
    _future = ShowcaseRepository().publishedProjects();
  }

  @override
  Widget build(BuildContext context) {
    final compact = BcBreakpoints.isCompact(context);

    return PageFrame(
      children: [
        PageInset(
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, compact ? 120 : 140, 0, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Kicker('Portfolio'),
                const SizedBox(height: 14),
                Text(
                  SiteSeo.work.h1,
                  style: compact
                      ? Theme.of(context).textTheme.displaySmall
                      : Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Text(
                    SiteSeo.work.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: BcColors.muted,
                        ),
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: _filter == null,
                      onTap: () => setState(() => _filter = null),
                    ),
                    for (final kind in PracticeKind.values)
                      _FilterChip(
                        label: kind.label,
                        selected: _filter == kind,
                        onTap: () => setState(() => _filter = kind),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        PageInset(
          child: Padding(
            padding: EdgeInsets.only(bottom: compact ? 64 : 96),
            child: FutureBuilder<List<Project>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 64),
                    child: Center(child: CircularProgressIndicator(color: BcColors.gold)),
                  );
                }
                final all = snapshot.data ?? Projects.all;
                final projects =
                    _filter == null ? all : all.where((project) => project.kind == _filter).toList();
                return _WorkGrid(projects: projects);
              },
            ),
          ),
        ),
        const CtaBand(),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? BcColors.gold : Colors.transparent,
            border: Border.all(color: selected ? BcColors.gold : BcColors.line),
          ),
          child: Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: selected ? BcColors.ink : BcColors.goldSoft,
                  letterSpacing: 1.8,
                ),
          ),
        ),
      ),
    );
  }
}

class _WorkGrid extends StatelessWidget {
  const _WorkGrid({required this.projects});

  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    final compact = BcBreakpoints.isCompact(context);
    if (compact) {
      return Column(
        children: [
          for (final project in projects) ...[
            _WorkCard(project: project, tall: false),
            const SizedBox(height: 22),
          ],
        ],
      );
    }

    final left = <Project>[];
    final right = <Project>[];
    for (var i = 0; i < projects.length; i++) {
      (i.isEven ? left : right).add(projects[i]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              for (var i = 0; i < left.length; i++) ...[
                _WorkCard(project: left[i], tall: i.isOdd),
                const SizedBox(height: 22),
              ],
            ],
          ),
        ),
        const SizedBox(width: 22),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 72),
            child: Column(
              children: [
                for (var i = 0; i < right.length; i++) ...[
                  _WorkCard(project: right[i], tall: i.isEven),
                  const SizedBox(height: 22),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkCard extends StatefulWidget {
  const _WorkCard({required this.project, required this.tall});

  final Project project;
  final bool tall;

  @override
  State<_WorkCard> createState() => _WorkCardState();
}

class _WorkCardState extends State<_WorkCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        key: Key('project-${widget.project.slug}'),
        onTap: () => context.go(widget.project.route),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: widget.tall ? 3 / 4 : 4 / 3,
              child: ClipRect(
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  scale: _hover ? 1.05 : 1,
                  child: NetworkCover(url: widget.project.heroUrl),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Kicker('${widget.project.practiceLabel}  ·  ${widget.project.year}'),
            const SizedBox(height: 8),
            Text(widget.project.title, style: Theme.of(context).textTheme.headlineSmall),
            Text(widget.project.location, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
