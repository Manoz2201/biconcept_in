import 'package:biconcept_in/content/brand.dart';
import 'package:biconcept_in/content/projects.dart';
import 'package:biconcept_in/content/seo.dart';
import 'package:biconcept_in/core/seo/seo.dart';
import 'package:biconcept_in/core/widgets/site_footer.dart';
import 'package:biconcept_in/core/widgets/site_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SiteScaffold extends StatefulWidget {
  const SiteScaffold({super.key, required this.child});

  final Widget child;

  @override
  State<SiteScaffold> createState() => _SiteScaffoldState();
}

class _SiteScaffoldState extends State<SiteScaffold> {
  bool _scrolled = false;
  bool _menuOpen = false;

  bool _onScroll(ScrollNotification notification) {
    final next = notification.metrics.pixels > 24;
    if (next != _scrolled) {
      setState(() => _scrolled = next);
    }
    return false;
  }

  bool get _overHero {
    final path = GoRouterState.of(context).uri.path;
    if (path == '/' || path == '/studio') return true;
    if (path == '/architecture' || path == '/interiors' || path == '/real-estate') {
      return true;
    }
    return RegExp(r'^/work/[^/]+$').hasMatch(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: _SeoBinder(child: widget.child),
          ),
          if (_menuOpen) SiteMenu(onClose: () => setState(() => _menuOpen = false)),
          SiteHeader(
            scrolled: _scrolled,
            menuOpen: _menuOpen,
            overHero: _overHero,
            onMenu: () => setState(() => _menuOpen = !_menuOpen),
          ),
        ],
      ),
    );
  }
}

class _SeoBinder extends StatefulWidget {
  const _SeoBinder({required this.child});

  final Widget child;

  @override
  State<_SeoBinder> createState() => _SeoBinderState();
}

class _SeoBinderState extends State<_SeoBinder> {
  String? _applied;

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (_applied != path) {
      _applied = path;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final seo = SiteSeo.forPath(path);
        var title = seo.title;
        var description = seo.description;
        String? image;
        final match = RegExp(r'^/work/([^/]+)$').firstMatch(path);
        if (match != null) {
          final project = Projects.bySlug(match.group(1)!);
          if (project != null) {
            title = '${project.title} — ${Brand.name}';
            description = project.lede;
            image = project.heroUrl;
          }
        }
        applyRouteSeo(
          title: title,
          description: description,
          canonical: '${Brand.siteUrl}$path',
          imageUrl: image,
          faqs: [
            for (final faq in seo.faqs) (question: faq.question, answer: faq.answer),
          ],
        );
      });
    }
    return widget.child;
  }
}

class PageFrame extends StatelessWidget {
  const PageFrame({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList.list(children: children),
        const SliverToBoxAdapter(child: SiteFooter()),
      ],
    );
  }
}
