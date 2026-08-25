import 'package:biconcept_in/content/brand.dart';
import 'package:biconcept_in/core/theme/breakpoints.dart';
import 'package:biconcept_in/core/theme/colors.dart';
import 'package:biconcept_in/core/widgets/gold_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
  });

  final bool scrolled;
  final VoidCallback onMenu;
  final bool menuOpen;

  @override
  Widget build(BuildContext context) {
    final compact = BcBreakpoints.isCompact(context);
    final location = GoRouterState.of(context).uri.path;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      height: 76,
      padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 32),
      decoration: BoxDecoration(
        color: scrolled || menuOpen
            ? BcColors.ink.withValues(alpha: 0.94)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: scrolled || menuOpen ? BcColors.line : Colors.transparent,
          ),
        ),
      ),
      child: Row(
        children: [
          _Wordmark(onTap: () => context.go('/')),
          const Spacer(),
          if (!compact)
            Row(
              children: [
                for (final item in NavItems.all)
                  _NavLink(
                    label: item.label,
                    selected: location == item.path ||
                        (item.path == '/work' && location.startsWith('/work')),
                    onTap: () => context.go(item.path),
                  ),
                const SizedBox(width: 18),
                GoldButton(
                  label: 'Start a concept',
                  onPressed: () => context.go('/inquire'),
                  variant: GoldButtonVariant.outline,
                ),
              ],
            )
          else
            IconButton(
              onPressed: onMenu,
              icon: Icon(menuOpen ? Icons.close : Icons.menu, color: BcColors.ivory),
              tooltip: menuOpen ? 'Close menu' : 'Open menu',
            ),
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
      color: BcColors.ink,
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
                label: 'Start a concept',
                onPressed: () {
                  onClose();
                  context.go('/inquire');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          Brand.name,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 26,
            fontWeight: FontWeight.w500,
            color: BcColors.ivory,
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
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || _hover;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
                      color: active ? BcColors.gold : BcColors.ivory,
                      fontWeight: FontWeight.w300,
                    ),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                height: 1,
                width: active ? 18 : 0,
                color: BcColors.gold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
