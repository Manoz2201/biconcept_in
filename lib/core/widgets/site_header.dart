import 'package:biconcept_in/content/brand.dart';
import 'package:biconcept_in/content/copy.dart';
import 'package:biconcept_in/core/theme/breakpoints.dart';
import 'package:biconcept_in/core/theme/colors.dart';
import 'package:biconcept_in/core/theme/theme.dart';
import 'package:biconcept_in/core/widgets/gold_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavItem {
  const NavItem(this.label, this.path);
  final String label;
  final String path;
}

abstract final class NavItems {
  static const all = [
    NavItem('Architecture', '/architecture'),
    NavItem('Interiors', '/interiors'),
    NavItem('Real estate', '/real-estate'),
    NavItem('Listings', '/listings'),
    NavItem('Work', '/work'),
    NavItem('Studio', '/studio'),
  ];
}

class SiteHeader extends StatelessWidget {
  const SiteHeader({
    super.key,
    required this.scrolled,
    required this.onMenu,
    this.menuOpen = false,
    this.overHero = false,
  });

  final bool scrolled;
  final VoidCallback onMenu;
  final bool menuOpen;
  final bool overHero;

  @override
  Widget build(BuildContext context) {
    final compact = BcBreakpoints.isCompact(context);
    final location = GoRouterState.of(context).uri.path;
    final overPhoto = overHero && !scrolled && !menuOpen;
    final fg = overPhoto ? BcColors.photoInk : BcColors.espresso;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      height: 76,
      padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 32),
      decoration: BoxDecoration(
        color: scrolled || menuOpen
            ? BcColors.paper.withValues(alpha: 0.94)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: scrolled || menuOpen ? BcColors.line : Colors.transparent,
          ),
        ),
      ),
      child: Row(
        children: [
          _Wordmark(onTap: () => context.go('/'), color: fg),
          if (!compact) ...[
            const SizedBox(width: 16),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final item in NavItems.all)
                        _NavLink(
                          label: item.label,
                          selected: location == item.path ||
                              (item.path == '/work' && location.startsWith('/work')) ||
                              (item.path == '/listings' && location.startsWith('/listings')),
                          onPhoto: overPhoto,
                          onTap: () => context.go(item.path),
                        ),
                      const SizedBox(width: 14),
                      GoldButton(
                        label: SiteCopy.heroCtaPrimary,
                        onPressed: () => context.go('/inquire'),
                        variant: GoldButtonVariant.outline,
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: () => context.go('/admin/login'),
                        tooltip: 'Studio console',
                        icon: Icon(
                          Icons.admin_panel_settings_outlined,
                          color: overPhoto
                              ? BcColors.photoInk.withValues(alpha: 0.7)
                              : BcColors.muted,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            const Spacer(),
            IconButton(
              onPressed: () => context.go('/admin/login'),
              tooltip: 'Studio console',
              icon: Icon(
                Icons.admin_panel_settings_outlined,
                color: fg.withValues(alpha: 0.75),
                size: 22,
              ),
            ),
            IconButton(
              onPressed: onMenu,
              icon: Icon(menuOpen ? Icons.close : Icons.menu, color: fg),
              tooltip: menuOpen ? 'Close menu' : 'Open menu',
            ),
          ],
        ],
      ),
    );
  }
}

class SiteMenu extends StatelessWidget {
  const SiteMenu({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BcColors.paper,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 88, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in NavItems.all)
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: GestureDetector(
                    onTap: () {
                      onClose();
                      context.go(item.path);
                    },
                    child: Text(
                      item.label,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                ),
              const Spacer(),
              GoldButton(
                label: SiteCopy.heroCtaPrimary,
                onPressed: () {
                  onClose();
                  context.go('/inquire');
                },
              ),
              const SizedBox(height: 18),
              TextButton.icon(
                onPressed: () {
                  onClose();
                  context.go('/admin/login');
                },
                icon: const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: BcColors.muted,
                  size: 20,
                ),
                label: Text(
                  'Studio console',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: BcColors.muted,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.onTap, required this.color});

  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          Brand.name,
          style: TextStyle(
            fontFamily: BcFonts.display,
            fontSize: 26,
            fontWeight: FontWeight.w500,
            color: color,
            letterSpacing: 1.2,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.onPhoto,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool onPhoto;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || _hover;
    final idle = widget.onPhoto ? BcColors.photoInk : BcColors.espresso;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: active ? BcColors.brass : idle,
                      fontWeight: FontWeight.w400,
                    ),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                height: 1,
                width: active ? 18 : 0,
                color: BcColors.brass,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
