import 'package:biconcept_in/content/brand.dart';
import 'package:biconcept_in/content/copy.dart';
import 'package:biconcept_in/content/ncr_locations.dart';
import 'package:biconcept_in/content/seo.dart';
import 'package:biconcept_in/content/services.dart';
import 'package:biconcept_in/core/layout/max_width.dart';
import 'package:biconcept_in/core/layout/site_scaffold.dart';
import 'package:biconcept_in/core/theme/breakpoints.dart';
import 'package:biconcept_in/core/theme/colors.dart';
import 'package:biconcept_in/core/widgets/gold_button.dart';
import 'package:biconcept_in/core/widgets/reveal.dart';
import 'package:biconcept_in/features/inquire/inquiry_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class InquirePage extends StatefulWidget {
  const InquirePage({
    super.key,
    this.listingId,
    this.city,
    this.sector,
  });

  final String? listingId;
  final String? city;
  final String? sector;

  @override
  State<InquirePage> createState() => _InquirePageState();
}

class _InquirePageState extends State<InquirePage> {
  final _repo = InquiryRepository();
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _city = TextEditingController();
  final _message = TextEditingController();

  int _step = 0;
  PracticeKind _practice = PracticeKind.architecture;
  String _projectType = 'Residence';
  String _budget = 'To be discussed';
  bool _submitting = false;
  bool _done = false;
  String? _error;

  static const _types = [
    'Residence',
    'Villa',
    'Apartment interiors',
    'Hospitality',
    'Development',
    'Land / plot',
    'Other',
  ];

  static const _budgets = [
    'To be discussed',
    'Under ₹50L',
    '₹50L – ₹2Cr',
    '₹2Cr – ₹8Cr',
    '₹8Cr+',
  ];

  @override
  void initState() {
    super.initState();
    final citySlug = widget.city ?? '';
    final city = NcrLocations.bySlug(citySlug);
    if (city != null) {
      _city.text = city.label;
    } else if (citySlug.isNotEmpty) {
      _city.text = citySlug;
    }
    if ((widget.listingId ?? '').isNotEmpty) {
      _practice = PracticeKind.realEstate;
      _projectType = 'Land / plot';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _city.dispose();
    _message.dispose();
    super.dispose();
  }

  String get _cityValue {
    final typed = _city.text.trim();
    final slug = widget.city ?? '';
    final known = NcrLocations.bySlug(slug);
    if (known != null && (typed.isEmpty || typed == known.label)) return known.slug;
    return typed;
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await _repo.submit(
        Inquiry(
          practice: _practice,
          projectType: _projectType,
          city: _cityValue,
          sector: widget.sector ?? '',
          budgetBand: _budget,
          name: _name.text.trim(),
          phone: _phone.text.trim(),
          email: _email.text.trim(),
          message: _message.text.trim(),
          listingId: widget.listingId ?? '',
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
    return PageFrame(
      children: [
        PageInset(
          maxWidth: 760,
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, compact ? 120 : 140, 0, compact ? 72 : 112),
            child: _done ? const _Success() : _formBody(context, compact),
          ),
        ),
      ],
    );
  }

  Widget _formBody(BuildContext context, bool compact) {
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Kicker('Consultation'),
          const SizedBox(height: 14),
          Text(
            SiteSeo.inquire.h1,
            style: compact
                ? Theme.of(context).textTheme.displaySmall
                : Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 16),
          Text(
            SiteCopy.inquireIntro,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: BcColors.muted),
          ),
          if ((widget.listingId ?? '').isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'This brief is tied to a researched NCR listing. We will read it against that project.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: BcColors.goldSoft),
            ),
          ],
          const SizedBox(height: 36),
          _StepDots(step: _step),
          const SizedBox(height: 36),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            child: switch (_step) {
              0 => _stepPractice(),
              1 => _stepProject(),
              _ => _stepContact(),
            },
          ),
        ],
      ),
    );
  }

  Widget _stepPractice() {
    return Column(
      key: const ValueKey('practice'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Which practice?', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        for (final practice in Practices.all)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SelectTile(
              selected: _practice == practice.kind,
              title: practice.label,
              subtitle: practice.headline,
              onTap: () => setState(() => _practice = practice.kind),
            ),
          ),
        const SizedBox(height: 24),
        GoldButton(label: 'Continue', onPressed: () => setState(() => _step = 1)),
      ],
    );
  }

  Widget _stepProject() {
    return Column(
      key: const ValueKey('project'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('The project.', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        Text('TYPE', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: _projectType,
          dropdownColor: BcColors.charcoal,
          items: [
            for (final type in _types)
              DropdownMenuItem(value: type, child: Text(type)),
          ],
          onChanged: (value) => setState(() => _projectType = value ?? _projectType),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _city,
          decoration: const InputDecoration(labelText: 'CITY'),
          validator: (value) =>
              (value == null || value.trim().isEmpty) ? 'Tell us the city.' : null,
        ),
        const SizedBox(height: 20),
        Text('BUDGET BAND', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: _budget,
          dropdownColor: BcColors.charcoal,
          items: [
            for (final band in _budgets)
              DropdownMenuItem(value: band, child: Text(band)),
          ],
          onChanged: (value) => setState(() => _budget = value ?? _budget),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            GoldButton(
              label: 'Back',
              variant: GoldButtonVariant.outline,
              onPressed: () => setState(() => _step = 0),
            ),
            GoldButton(label: 'Continue', onPressed: () {
              if (_form.currentState?.validate() ?? false) {
                setState(() => _step = 2);
              }
            }),
          ],
        ),
      ],
    );
  }

  Widget _stepContact() {
    return Column(
      key: const ValueKey('contact'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How we reach you.', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        TextFormField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'NAME'),
          validator: (value) =>
              (value == null || value.trim().length < 2) ? 'Your name, please.' : null,
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
        TextFormField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'EMAIL (OPTIONAL)'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _message,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'BRIEF'),
          validator: (value) =>
              (value == null || value.trim().length < 8) ? 'A short brief is enough.' : null,
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: BcColors.danger)),
        ],
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            GoldButton(
              label: 'Back',
              variant: GoldButtonVariant.outline,
              onPressed: _submitting ? null : () => setState(() => _step = 1),
            ),
            GoldButton(
              label: _submitting ? 'Sending…' : 'Send brief',
              onPressed: _submitting ? null : _submit,
            ),
          ],
        ),
      ],
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    const labels = ['Practice', 'Project', 'Contact'];
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: i <= step ? BcColors.gold : BcColors.line,
              ),
            ),
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= step ? BcColors.gold : Colors.transparent,
                  border: Border.all(color: BcColors.gold),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                labels[i].toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: i <= step ? BcColors.gold : BcColors.muted,
                      fontSize: 9,
                    ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SelectTile extends StatelessWidget {
  const _SelectTile({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: selected ? BcColors.gold.withValues(alpha: 0.08) : BcColors.charcoal,
            border: Border.all(color: selected ? BcColors.gold : BcColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _Success extends StatelessWidget {
  const _Success();

  @override
  Widget build(BuildContext context) {
    return Reveal(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Kicker('Studio'),
          const SizedBox(height: 14),
          Text(SiteCopy.inquireSuccessTitle, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 16),
          Text(
            SiteCopy.inquireSuccessBody,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: BcColors.muted),
          ),
          const SizedBox(height: 32),
          GoldButton(
            label: 'Email the studio',
            onPressed: () => launchUrl(Uri.parse('mailto:${Brand.email}')),
          ),
        ],
      ),
    );
  }
}
