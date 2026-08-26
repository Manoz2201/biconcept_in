import 'package:biconcept_in/core/layout/max_width.dart';
import 'package:biconcept_in/core/theme/breakpoints.dart';
import 'package:biconcept_in/core/theme/colors.dart';
import 'package:biconcept_in/core/widgets/gold_button.dart';
import 'package:biconcept_in/data/models.dart';
import 'package:biconcept_in/data/repositories.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OfferStrip extends StatefulWidget {
  const OfferStrip({super.key, this.practice});

  final String? practice;

  @override
  State<OfferStrip> createState() => _OfferStripState();
}

class _OfferStripState extends State<OfferStrip> {
  late Future<List<StudioOffer>> _future;

  @override
  void initState() {
    super.initState();
    _future = OffersRepository().listPublished(practice: widget.practice);
  }

  String _href(StudioOffer offer) {
    if (offer.href.trim().isNotEmpty) return offer.href.trim();
    final practice = offer.practice.isNotEmpty ? offer.practice : widget.practice ?? '';
    return Uri(
      path: '/inquire',
      queryParameters: {
        if (practice.isNotEmpty) 'practice': practice,
        'offer': offer.title,
      },
    ).toString();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StudioOffer>>(
      future: _future,
      builder: (context, snapshot) {
        final offers = snapshot.data ?? const <StudioOffer>[];
        if (offers.isEmpty) return const SizedBox.shrink();
        final compact = BcBreakpoints.isCompact(context);
        return ColoredBox(
          color: BcColors.cream,
          child: PageInset(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: compact ? 20 : 28),
              child: Column(
                children: [
                  for (final offer in offers.take(2))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: BcColors.paper,
                          border: Border.all(color: BcColors.line),
                          borderRadius: BorderRadius.circular(BcColors.radius),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                          child: compact
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      offer.title,
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                    if (offer.summary.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        offer.summary,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                    const SizedBox(height: 14),
                                    GoldButton(
                                      label: offer.ctaLabel.isEmpty ? 'Inquire' : offer.ctaLabel,
                                      onPressed: () => context.go(_href(offer)),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            offer.title,
                                            style: Theme.of(context).textTheme.headlineSmall,
                                          ),
                                          if (offer.summary.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              offer.summary,
                                              style: Theme.of(context).textTheme.bodyMedium,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    GoldButton(
                                      label: offer.ctaLabel.isEmpty ? 'Inquire' : offer.ctaLabel,
                                      onPressed: () => context.go(_href(offer)),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
