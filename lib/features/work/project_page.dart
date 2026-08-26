import 'package:biconcept_in/content/projects.dart';
import 'package:biconcept_in/content/services.dart';
import 'package:biconcept_in/core/layout/max_width.dart';
import 'package:biconcept_in/core/layout/site_scaffold.dart';
import 'package:biconcept_in/core/theme/breakpoints.dart';
import 'package:biconcept_in/core/theme/colors.dart';
import 'package:biconcept_in/core/widgets/cta_band.dart';
import 'package:biconcept_in/core/widgets/gold_button.dart';
import 'package:biconcept_in/core/widgets/ken_burns.dart';
import 'package:biconcept_in/core/widgets/reveal.dart';
import 'package:biconcept_in/data/repositories.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key, required this.slug});

  final String slug;

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  late Future<Project?> _future;

  @override
  void initState() {
    super.initState();
    _future = ShowcaseRepository().bySlug(widget.slug);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Project?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const PageFrame(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(24, 200, 24, 80),
                child: Center(child: CircularProgressIndicator(color: BcColors.gold)),
              ),
            ],
          );
        }
        final project = snapshot.data;
        if (project == null) {
          return PageFrame(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 160, 24, 80),
                child: Column(
                  children: [
                    Text('Project not found.', style: Theme.of(context).textTheme.displaySmall),
                    const SizedBox(height: 20),
                    GoldButton(
                      label: 'View all work',
                      variant: GoldButtonVariant.outline,
                      onPressed: () => context.go('/work'),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return _ProjectBody(project: project);
      },
    );
  }
}

class _ProjectBody extends StatelessWidget {
  const _ProjectBody({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final compact = BcBreakpoints.isCompact(context);
    return PageFrame(
      children: [
        SizedBox(
          height: compact ? 520 : 720,
          child: Stack(
            fit: StackFit.expand,
            children: [
              KenBurnsImage(url: project.heroUrl),
              const PhotoScrim(),
              PageInset(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Kicker(
                        '${project.practiceLabel}  ·  ${project.location}  ·  ${project.year}',
                        color: BcColors.brassHover,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        project.title,
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
                      project.lede,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: BcColors.espresso,
                          ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Text(
                      project.story,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: BcColors.muted,
                            fontSize: 18,
                          ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      GoldButton(
                        label: project.kind.ctaLabel,
                        onPressed: () => context.go(project.kind.inquirePath()),
                      ),
                      GoldButton(
                        label: project.practiceLabel,
                        variant: GoldButtonVariant.outline,
                        onPressed: () => context.go(project.practiceRoute),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        PageInset(
          child: Padding(
            padding: EdgeInsets.only(bottom: compact ? 64 : 96),
            child: compact
                ? Column(
                    children: [
                      for (final url in project.gallery) ...[
                        AspectRatio(
                          aspectRatio: 4 / 3,
                          child: NetworkCover(url: url),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < project.gallery.length; i++) ...[
                        if (i > 0) const SizedBox(width: 16),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: i == 0 ? 3 / 4 : 4 / 5,
                            child: NetworkCover(url: project.gallery[i]),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
        CtaBand(practice: project.kind),
      ],
    );
  }
}
