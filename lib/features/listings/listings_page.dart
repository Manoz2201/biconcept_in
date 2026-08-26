import 'package:biconcept_in/content/ncr_locations.dart';
import 'package:biconcept_in/content/seo.dart';
import 'package:biconcept_in/content/services.dart';
import 'package:biconcept_in/core/layout/max_width.dart';
import 'package:biconcept_in/core/layout/site_scaffold.dart';
import 'package:biconcept_in/core/theme/breakpoints.dart';
import 'package:biconcept_in/core/theme/colors.dart';
import 'package:biconcept_in/core/widgets/cta_band.dart';
import 'package:biconcept_in/core/widgets/faq_section.dart';
import 'package:biconcept_in/core/widgets/gold_button.dart';
import 'package:biconcept_in/core/widgets/reveal.dart';
import 'package:biconcept_in/data/models.dart';
import 'package:biconcept_in/data/repositories.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class ListingsPage extends StatefulWidget {
  const ListingsPage({super.key, this.citySlug, this.sectorSlug});

  final String? citySlug;
  final String? sectorSlug;

  @override
  State<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
  final _repo = ListingsRepository();
  late Future<List<MarketListing>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant ListingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.citySlug != widget.citySlug || oldWidget.sectorSlug != widget.sectorSlug) {
      setState(() => _future = _load());
    }
  }

  Future<List<MarketListing>> _load() {
    return _repo.listPublished(city: widget.citySlug, sector: widget.sectorSlug);
  }

  void _go({String? city, String? sector}) {
    if (city == null) {
      context.go('/listings');
      return;
    }
    if (sector == null || sector.isEmpty) {
      context.go('/listings/$city');
      return;
    }
    context.go('/listings/$city/$sector');
  }

  @override
  Widget build(BuildContext context) {
    final compact = BcBreakpoints.isCompact(context);
    final city = widget.citySlug == null ? null : NcrLocations.bySlug(widget.citySlug!);
    final sector = city?.sectorBySlug(widget.sectorSlug ?? '');
    final seo = SiteSeo.forPath('/listings');

    return PageFrame(
      children: [
        PageInset(
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, compact ? 120 : 140, 0, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Kicker('NCR research'),
                const SizedBox(height: 14),
                Text(
                  seo.h1,
                  style: compact
                      ? Theme.of(context).textTheme.displaySmall
                      : Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Text(
                    city == null
                        ? seo.description
                        : sector == null
                            ? 'Upcoming and newly launched projects in ${city.label}, researched for BiConcept clients.'
                            : 'Upcoming and newly launched projects in ${city.label} · ${sector.label}.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: BcColors.muted),
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _Chip(
                      label: 'All NCR',
                      selected: city == null,
                      onTap: () => _go(),
                    ),
                    for (final item in NcrLocations.all)
                      _Chip(
                        label: item.label,
                        selected: city?.slug == item.slug,
                        onTap: () => _go(city: item.slug),
                      ),
                  ],
                ),
                if (city != null) ...[
                  const SizedBox(height: 18),
                  Text(
                    city.sectorNoun.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Chip(
                        label: 'All',
                        selected: sector == null,
                        onTap: () => _go(city: city.slug),
                      ),
                      for (final item in city.sectors)
                        _Chip(
                          label: item.label,
                          selected: sector?.slug == item.slug,
                          onTap: () => _go(city: city.slug, sector: item.slug),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        PageInset(
          child: Padding(
            padding: EdgeInsets.only(bottom: compact ? 64 : 96),
            child: FutureBuilder<List<MarketListing>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 64),
                    child: Center(child: CircularProgressIndicator(color: BcColors.brass)),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Text(
                      'Listings are briefly unavailable. Write to the studio and we will send the current NCR shortlist.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: BcColors.muted),
                    ),
                  );
                }
                final listings = snapshot.data ?? const <MarketListing>[];
                if (listings.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'The studio is researching new launches in this pocket.',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'A first shortlist will appear here as the daily research agent publishes it. You can still start a concept.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: BcColors.muted),
                        ),
                        const SizedBox(height: 24),
                        GoldButton(
                          label: PracticeKind.realEstate.ctaLabel,
                          onPressed: () => context.go(PracticeKind.realEstate.inquirePath()),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final listing in listings) ...[
                      _ListingCard(listing: listing),
                      const SizedBox(height: 18),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
        FaqSection(items: seo.faqs),
        const CtaBand(practice: PracticeKind.realEstate),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});

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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? BcColors.brass : Colors.transparent,
            border: Border.all(color: selected ? BcColors.brass : BcColors.line),
            borderRadius: BorderRadius.circular(BcColors.radius),
          ),
          child: Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: selected ? BcColors.espresso : BcColors.muted,
                  letterSpacing: 1.6,
                  fontSize: 10,
                ),
          ),
        ),
      ),
    );
  }
}

class _ListingCard extends StatefulWidget {
  const _ListingCard({required this.listing});

  final MarketListing listing;

  @override
  State<_ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<_ListingCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _hover ? BcColors.cream : BcColors.stone,
          border: Border.all(color: _hover ? BcColors.brass : BcColors.line),
          borderRadius: BorderRadius.circular(BcColors.radius),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: BcColors.espresso.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : const [],
        ),
        child: Reveal(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Kicker('${listing.placeLabel}  ·  ${listing.status}'),
              const SizedBox(height: 10),
              Text(listing.title, style: Theme.of(context).textTheme.headlineSmall),
              if (listing.developer.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(listing.developer, style: Theme.of(context).textTheme.bodyMedium),
              ],
              if (listing.summary.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(listing.summary, style: Theme.of(context).textTheme.bodyLarge),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (listing.typology.isNotEmpty) _Meta(listing.typology),
                  if (listing.priceBand.isNotEmpty) _Meta(listing.priceBand),
                  if (listing.locality.isNotEmpty) _Meta(listing.locality),
                ],
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  GoldButton(
                    label: 'Inquire on this',
                    onPressed: () => context.go(listing.inquirePath),
                  ),
                  if (listing.sourceUrl.isNotEmpty)
                    GoldButton(
                      label: listing.sourceName.isEmpty ? 'Source' : listing.sourceName,
                      variant: GoldButtonVariant.outline,
                      onPressed: () => launchUrl(Uri.parse(listing.sourceUrl)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: BcColors.muted,
            letterSpacing: 1.6,
            fontSize: 10,
          ),
    );
  }
}
