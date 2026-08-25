import 'package:biconcept_in/core/theme/breakpoints.dart';
import 'package:biconcept_in/core/theme/colors.dart';
import 'package:biconcept_in/data/repositories.dart';
import 'package:biconcept_in/features/admin/admin_home_page.dart';
import 'package:biconcept_in/features/admin/admin_leads_page.dart';
import 'package:biconcept_in/features/admin/admin_listings_page.dart';
import 'package:biconcept_in/features/admin/admin_services_page.dart';
import 'package:biconcept_in/features/admin/admin_showcase_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key, required this.section});

  final String section;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  final _auth = AuthRepository();
  bool _checking = true;
  bool _signedIn = false;

  @override
  void initState() {
    super.initState();
    _gate();
  }

  Future<void> _gate() async {
    final user = await _auth.currentUser();
    if (!mounted) return;
    if (user == null) {
      context.go('/admin/login');
      return;
    }
    setState(() {
      _checking = false;
      _signedIn = true;
    });
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (!mounted) return;
    context.go('/admin/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_checking || !_signedIn) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: BcColors.gold)),
      );
    }

    final compact = BcBreakpoints.isCompact(context);
    final page = switch (widget.section) {
      'leads' => const AdminLeadsPage(),
      'listings' => const AdminListingsPage(),
      'showcase' => const AdminShowcasePage(),
      'services' => const AdminServicesPage(),
      _ => const AdminHomePage(),
    };

    if (compact) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Console', style: GoogleFonts.cormorantGaramond()),
          actions: [
            IconButton(onPressed: _logout, icon: const Icon(Icons.logout), tooltip: 'Sign out'),
          ],
        ),
        drawer: Drawer(
          backgroundColor: BcColors.charcoal,
          child: _Nav(section: widget.section, onLogout: _logout),
        ),
        body: page,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 240,
            child: ColoredBox(
              color: BcColors.charcoal,
              child: _Nav(section: widget.section, onLogout: _logout),
            ),
          ),
          const VerticalDivider(width: 1, color: BcColors.line),
          Expanded(child: page),
        ],
      ),
    );
  }
}

class _Nav extends StatelessWidget {
  const _Nav({required this.section, required this.onLogout});

  final String section;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Overview', '/admin', 'home'),
      ('Leads', '/admin/leads', 'leads'),
      ('Listings', '/admin/listings', 'listings'),
      ('Showcase', '/admin/showcase', 'showcase'),
      ('Services', '/admin/services', 'services'),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BiConcept',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 24,
                color: BcColors.ivory,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'STUDIO CONSOLE',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 36),
            for (final item in items)
              _NavRow(
                label: item.$1,
                selected: section == item.$3,
                onTap: () {
                  Scaffold.maybeOf(context)?.closeDrawer();
                  context.go(item.$2);
                },
              ),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('View site'),
            ),
            TextButton(onPressed: onLogout, child: const Text('Sign out')),
          ],
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? BcColors.gold.withValues(alpha: 0.12) : Colors.transparent,
            border: Border(
              left: BorderSide(color: selected ? BcColors.gold : Colors.transparent, width: 2),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: selected ? BcColors.gold : BcColors.ivory,
                ),
          ),
        ),
      ),
    );
  }
}

class AdminPageFrame extends StatelessWidget {
  const AdminPageFrame({
    super.key,
    required this.title,
    required this.child,
    this.action,
  });

  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 72),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.displaySmall),
            ),
            ?action,
          ],
        ),
        const SizedBox(height: 28),
        child,
      ],
    );
  }
}

class AdminError extends StatelessWidget {
  const AdminError(this.message, {super.key, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message, style: const TextStyle(color: BcColors.danger)),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ],
    );
  }
}
