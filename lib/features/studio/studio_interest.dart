import 'package:biconcept_in/content/copy.dart';
import 'package:biconcept_in/content/projects.dart';
import 'package:biconcept_in/content/services.dart';
import 'package:biconcept_in/core/theme/breakpoints.dart';
import 'package:biconcept_in/core/theme/colors.dart';
import 'package:biconcept_in/core/widgets/gold_button.dart';
import 'package:biconcept_in/core/widgets/ken_burns.dart';
import 'package:biconcept_in/core/widgets/reveal.dart';
import 'package:biconcept_in/data/models.dart';
import 'package:biconcept_in/features/inquire/inquiry_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StudioInterestTarget {
  const StudioInterestTarget({
    required this.practice,
    required this.title,
    required this.kicker,
    required this.imageUrl,
    required this.body,
    required this.listingId,
    required this.city,
    required this.sector,
    required this.projectType,
    this.developer = '',
    this.meta = const [],
  });

  final PracticeKind practice;
  final String title;
  final String kicker;
  final String imageUrl;
  final String body;
  final String listingId;
  final String city;
  final String sector;
  final String projectType;
  final String developer;
  final List<(String, String)> meta;

  factory StudioInterestTarget.fromListing(MarketListing listing) {
    return StudioInterestTarget(
      practice: PracticeKind.realEstate,
      title: listing.title,
      kicker: '${listing.placeLabel}  ·  ${listing.status}',
      imageUrl: listing.coverUrl,
      body: listing.summary,
      listingId: listing.id,
      city: listing.city,
      sector: listing.sector,
      projectType: listing.typology.isEmpty ? 'Land / plot' : listing.typology,
      developer: listing.developer,
      meta: [
        if (listing.developer.isNotEmpty) ('Developer', listing.developer),
        if (listing.typology.isNotEmpty) ('Typology', listing.typology),
        if (listing.priceBand.isNotEmpty) ('Price', listing.priceBand),
        if (listing.locality.isNotEmpty) ('Locality', listing.locality),
        if (listing.status.isNotEmpty) ('Status', listing.status),
      ],
    );
  }

  factory StudioInterestTarget.fromProject(Project project) {
    return StudioInterestTarget(
      practice: project.kind,
      title: project.title,
      kicker: '${project.practiceLabel}  ·  ${project.location}  ·  ${project.year}',
      imageUrl: project.heroUrl,
      body: project.story.isNotEmpty ? project.story : project.lede,
      listingId: project.slug,
      city: project.location,
      sector: '',
      projectType: project.kind == PracticeKind.realEstate ? 'Land / plot' : 'Residence',
      meta: [
        ('Practice', project.practiceLabel),
        ('Location', project.location),
        ('Year', project.year),
      ],
    );
  }
}

Future<void> showStudioInterestDialog(BuildContext context, StudioInterestTarget target) {
  return showDialog<void>(
    context: context,
    barrierColor: BcColors.espresso.withValues(alpha: 0.55),
    builder: (context) => StudioInterestDialog(target: target),
  );
}

class StudioInterestDialog extends StatefulWidget {
  const StudioInterestDialog({super.key, required this.target});

  final StudioInterestTarget target;

  @override
  State<StudioInterestDialog> createState() => _StudioInterestDialogState();
}

class _StudioInterestDialogState extends State<StudioInterestDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _repo = InquiryRepository();
  bool _submitting = false;
  bool _done = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final target = widget.target;
      await _repo.submit(
        Inquiry(
          practice: target.practice,
          projectType: target.projectType,
          city: target.city,
          sector: target.sector,
          budgetBand: 'To be discussed',
          name: _name.text.trim(),
          phone: _phone.text.trim(),
          email: _email.text.trim(),
          message: 'Interested in ${target.title}.',
          listingId: target.listingId,
        ),
      );
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _done = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = 'The brief could not be sent. Check your connection and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = BcBreakpoints.isCompact(context);
    final maxWidth = compact ? double.infinity : 980.0;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 28),
          child: Material(
            color: BcColors.cream,
            borderRadius: BorderRadius.circular(BcColors.radius),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: MediaQuery.sizeOf(context).height * (compact ? 0.96 : 0.9),
              ),
              child: Column(
                children: [
                  _DialogHeader(
                    title: widget.target.title,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: compact
                        ? ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              _ProjectVisual(target: widget.target, height: 220),
                              _ProjectCopy(target: widget.target),
                              _formPane(),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 5,
                                child: ListView(
                                  padding: EdgeInsets.zero,
                                  children: [
                                    _ProjectVisual(target: widget.target, height: 320),
                                    _ProjectCopy(target: widget.target),
                                  ],
                                ),
                              ),
                              Container(width: 1, color: BcColors.line),
                              Expanded(flex: 4, child: _formPane()),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formPane() {
    if (_done) {
      return Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Kicker('Studio'),
            const SizedBox(height: 14),
            Text(SiteCopy.inquireSuccessTitle, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(
              SiteCopy.inquireSuccessBody,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            GoldButton(label: 'Close', onPressed: () => Navigator.of(context).pop()),
          ],
        ),
      );
    }

    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          const Kicker('Call to action'),
          const SizedBox(height: 10),
          Text('Leave your details.', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Name and phone are enough. We will reply if this project is the right next step.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 22),
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'NAME'),
            validator: (value) =>
                (value == null || value.trim().length < 2) ? 'Your name, please.' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]'))],
            decoration: const InputDecoration(labelText: 'PHONE'),
            validator: (value) {
              final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
              if (digits.length < 10) return 'A valid phone number, please.';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'EMAIL (OPTIONAL)'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(_error!, style: const TextStyle(color: BcColors.danger)),
          ],
          const SizedBox(height: 24),
          GoldButton(
            label: _submitting ? 'Sending…' : 'Send to studio',
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: BcColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: BcColors.espresso),
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: onClose,
            icon: const Icon(Icons.close, color: BcColors.espresso),
          ),
        ],
      ),
    );
  }
}

class _ProjectVisual extends StatelessWidget {
  const _ProjectVisual({required this.target, required this.height});

  final StudioInterestTarget target;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: NetworkCover(url: target.imageUrl),
    );
  }
}

class _ProjectCopy extends StatelessWidget {
  const _ProjectCopy({required this.target});

  final StudioInterestTarget target;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Kicker(target.kicker),
          const SizedBox(height: 10),
          Text(target.title, style: Theme.of(context).textTheme.headlineSmall),
          if (target.developer.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(target.developer, style: Theme.of(context).textTheme.bodyMedium),
          ],
          if (target.body.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(target.body, style: Theme.of(context).textTheme.bodyLarge),
          ],
          if (target.meta.isNotEmpty) ...[
            const SizedBox(height: 18),
            Wrap(
              spacing: 18,
              runSpacing: 10,
              children: [
                for (final item in target.meta)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$1.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: BcColors.muted,
                              letterSpacing: 1.6,
                              fontSize: 10,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(item.$2, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
