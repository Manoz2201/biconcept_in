import 'package:biconcept_in/content/brand.dart';
import 'package:biconcept_in/content/copy.dart';
import 'package:biconcept_in/content/services.dart';
import 'package:biconcept_in/core/layout/max_width.dart';
import 'package:biconcept_in/core/theme/breakpoints.dart';
import 'package:biconcept_in/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final compact = BcBreakpoints.isCompact(context);
    final year = Brand.copyrightYear;

    return ColoredBox(
      color: BcColors.charcoal,
      child: PageInset(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: compact ? 48 : 72),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (compact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BrandBlock(),
                    const SizedBox(height: 36),
                    _LinkColumn('Practice', [
                      for (final p in Practices.all) (p.label, p.route),
                    ]),
                    const SizedBox(height: 28),
                    _LinkColumn('Studio', const [
                      ('Work', '/work'),
                      ('Listings', '/listings'),
                      ('Studio', '/studio'),
                      ('Start a concept', '/inquire'),
                    ]),
                    const SizedBox(height: 28),
                    const _ContactColumn(),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(flex: 2, child: _BrandBlock()),
                    Expanded(
                      child: _LinkColumn('Practice', [
                        for (final p in Practices.all) (p.label, p.route),
                      ]),
                    ),
                    const Expanded(
                      child: _LinkColumn('Studio', [
                        ('Work', '/work'),
                        ('Listings', '/listings'),
                        ('Studio', '/studio'),
                        ('Start a concept', '/inquire'),
                      ]),
                    ),
                    const Expanded(child: _ContactColumn()),
                  ],
                ),
              const SizedBox(height: 48),
              const Divider(color: BcColors.line, height: 1),
              const SizedBox(height: 20),
              Text(
                '© $year ${Brand.legalName}. All rights reserved.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Brand.name,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 32,
            color: BcColors.ivory,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Text(
            SiteCopy.footerBlurb,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _LinkColumn extends StatelessWidget {
  const _LinkColumn(this.title, this.links);

  final String title;
  final List<(String, String)> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 16),
        for (final link in links)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _FooterLink(
              label: link.$1,
              onTap: () => context.go(link.$2),
            ),
          ),
      ],
    );
  }
}

class _ContactColumn extends StatelessWidget {
  const _ContactColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contact'.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 16),
        _FooterLink(
          label: Brand.email,
          onTap: () => launchUrl(Uri.parse('mailto:${Brand.email}')),
        ),
        const SizedBox(height: 10),
        Text(Brand.location, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _FooterLink extends StatefulWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _hover ? BcColors.gold : BcColors.muted,
              ),
        ),
      ),
    );
  }
}
