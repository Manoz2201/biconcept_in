import 'package:biconcept_in/content/projects.dart';
import 'package:biconcept_in/content/seo.dart';
import 'package:biconcept_in/content/services.dart';
import 'package:biconcept_in/core/layout/max_width.dart';
import 'package:biconcept_in/core/layout/site_scaffold.dart';
import 'package:biconcept_in/core/theme/breakpoints.dart';
import 'package:biconcept_in/core/theme/colors.dart';
import 'package:biconcept_in/core/widgets/cta_band.dart';
import 'package:biconcept_in/core/widgets/gold_button.dart';
import 'package:biconcept_in/core/widgets/ken_burns.dart';
import 'package:biconcept_in/core/widgets/reveal.dart';
import 'package:biconcept_in/data/models.dart';
import 'package:biconcept_in/data/repositories.dart';
import 'package:biconcept_in/features/studio/studio_interest.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudioPracticePage extends StatefulWidget {
  const StudioPracticePage({super.key, required this.practiceSlug});

  final String practiceSlug;

  @override
  State<StudioPracticePage> createState() => _StudioPracticePageState();
}

class _StudioPracticePageState extends State<StudioPracticePage> {
  late Future<_Gallery> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant StudioPracticePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.practiceSlug != widget.practiceSlug) {
      setState(() {
        _future = _load();
      });
    }
  }

  Future<_Gallery> _load() async {
    final practice = Practices.bySlug(widget.practiceSlug);
    if (practice == null) {
      return const _Gallery(practice: null, items: []);
    }
    if (practice.kind == PracticeKind.realEstate) {
      final listings = await ListingsRepository().listPublished();
      if (listings.isNotEmpty) {
        return _Gallery(
          practice: practice,
          items: [for (final listing in listings) _GalleryItem.listing(listing)],
        );
      }
    }
    final projects = await ShowcaseRepository().publishedProjects();
    return _Gallery(
      practice: practice,
      items: [
        for (final project in projects)
          if (project.kind == practice.kind) _GalleryItem.project(project),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final compact = BcBreakpoints.isCompact(context);
    final practice = Practices.bySlug(widget.practiceSlug);

    return PageFrame(
      children: [
        PageInset(
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, compact ? 120 : 140, 0, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () => context.go('/studio'),
                  child: Text(
                    '← STUDIO',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: BcColors.brass,
                          letterSpacing: 1.8,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                Kicker(practice?.kicker ?? 'Studio'),
                const SizedBox(height: 14),
                Text(
                  practice?.label ?? 'Studio',
                  style: compact
                      ? Theme.of(context).textTheme.displaySmall
                      : Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Text(
                    practice == null
                        ? SiteSeo.studio.description
                        : practice.kind == PracticeKind.realEstate
                            ? 'Researched NCR projects. Open a card for the brief, then leave your details if you would like a site conversation.'
                            : 'Selected ${practice.label.toLowerCase()} from the studio. Open a card for the full story, then leave your details if the work should continue.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: BcColors.muted),
                  ),
                ),
              ],
            ),
          ),
        ),
        PageInset(
          child: Padding(
            padding: EdgeInsets.only(bottom: compact ? 64 : 96),
            child: FutureBuilder<_Gallery>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 64),
                    child: Center(child: CircularProgressIndicator(color: BcColors.brass)),
                  );
                }
                final gallery = snapshot.data;
                if (gallery == null || gallery.practice == null) {
                  return Text(
                    'This practice is not on the studio floor.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  );
                }
                if (gallery.items.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Projects for this practice will appear here shortly.',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 20),
                      GoldButton(
                        label: gallery.practice!.ctaLabel,
                        onPressed: () => context.go(gallery.practice!.inquirePath),
                      ),
                    ],
                  );
                }
                return _GalleryGrid(items: gallery.items);
              },
            ),
          ),
        ),
        CtaBand(practice: practice?.kind),
      ],
    );
  }
}

class _Gallery {
  const _Gallery({required this.practice, required this.items});

  final Practice? practice;
  final List<_GalleryItem> items;
}

class _GalleryItem {
  const _GalleryItem({
    required this.id,
    required this.title,
    required this.kicker,
    required this.imageUrl,
    required this.subtitle,
    required this.target,
  });

  final String id;
  final String title;
  final String kicker;
  final String imageUrl;
  final String subtitle;
  final StudioInterestTarget target;

  factory _GalleryItem.listing(MarketListing listing) {
    return _GalleryItem(
      id: listing.id,
      title: listing.title,
      kicker: '${listing.placeLabel}  ·  ${listing.status}',
      imageUrl: listing.coverUrl,
      subtitle: listing.developer.isNotEmpty ? listing.developer : listing.placeLabel,
      target: StudioInterestTarget.fromListing(listing),
    );
  }

  factory _GalleryItem.project(Project project) {
    return _GalleryItem(
      id: project.slug,
      title: project.title,
      kicker: '${project.practiceLabel}  ·  ${project.year}',
      imageUrl: project.heroUrl,
      subtitle: project.location,
      target: StudioInterestTarget.fromProject(project),
    );
  }
}

class _GalleryGrid extends StatelessWidget {
  const _GalleryGrid({required this.items});

  final List<_GalleryItem> items;

  @override
  Widget build(BuildContext context) {
    final compact = BcBreakpoints.isCompact(context);
    final width = MediaQuery.sizeOf(context).width;
    final columns = compact
        ? 1
        : width >= 1180
            ? 3
            : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 20,
        mainAxisSpacing: 22,
        mainAxisExtent: compact ? 430 : 460,
      ),
      itemBuilder: (context, index) => _ProjectCard(item: items[index]),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  const _ProjectCard({required this.item});

  final _GalleryItem item;

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        key: Key('studio-item-${item.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => showStudioInterestDialog(context, item.target),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(BcColors.radius),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  scale: _hover ? 1.05 : 1,
                  child: NetworkCover(url: item.imageUrl),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Kicker(item.kicker),
            const SizedBox(height: 6),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              item.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
