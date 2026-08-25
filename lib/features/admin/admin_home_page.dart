import 'package:biconcept_in/core/theme/colors.dart';
import 'package:biconcept_in/data/repositories.dart';
import 'package:biconcept_in/features/admin/admin_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  late Future<_Counts> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_Counts> _load() async {
    final leads = await LeadsRepository().listAll();
    final listings = await ListingsRepository().listAll();
    final showcase = await ShowcaseRepository().listAll();
    final services = await CmsServicesRepository().listAll();
    return _Counts(
      leads: leads.length,
      newLeads: leads.where((item) => item.status == 'new').length,
      listings: listings.length,
      publishedListings: listings.where((item) => item.published).length,
      showcase: showcase.length,
      services: services.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageFrame(
      title: 'Overview',
      child: FutureBuilder<_Counts>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: BcColors.gold));
          }
          if (snapshot.hasError) {
            return AdminError(
              'Could not load the console. Confirm you are signed in.',
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final counts = snapshot.data!;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _Stat(
                label: 'New leads',
                value: '${counts.newLeads}',
                hint: '${counts.leads} total',
                onTap: () => context.go('/admin/leads'),
              ),
              _Stat(
                label: 'Published listings',
                value: '${counts.publishedListings}',
                hint: '${counts.listings} researched',
                onTap: () => context.go('/admin/listings'),
              ),
              _Stat(
                label: 'Showcase',
                value: '${counts.showcase}',
                hint: 'Portfolio rows',
                onTap: () => context.go('/admin/showcase'),
              ),
              _Stat(
                label: 'Services',
                value: '${counts.services}',
                hint: 'Practice copy',
                onTap: () => context.go('/admin/services'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Counts {
  const _Counts({
    required this.leads,
    required this.newLeads,
    required this.listings,
    required this.publishedListings,
    required this.showcase,
    required this.services,
  });

  final int leads;
  final int newLeads;
  final int listings;
  final int publishedListings;
  final int showcase;
  final int services;
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.hint,
    required this.onTap,
  });

  final String label;
  final String value;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: BcColors.charcoal,
          border: Border.all(color: BcColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 6),
            Text(hint, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
