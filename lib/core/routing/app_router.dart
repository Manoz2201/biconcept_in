import 'package:biconcept_in/content/brand.dart';
import 'package:biconcept_in/content/projects.dart';
import 'package:biconcept_in/content/seo.dart';
import 'package:biconcept_in/core/layout/site_scaffold.dart';
import 'package:biconcept_in/core/seo/seo.dart';
import 'package:biconcept_in/features/admin/admin_login_page.dart';
import 'package:biconcept_in/features/admin/admin_shell.dart';
import 'package:biconcept_in/features/home/home_page.dart';
import 'package:biconcept_in/features/inquire/inquire_page.dart';
import 'package:biconcept_in/features/listings/listings_page.dart';
import 'package:biconcept_in/features/services/service_page.dart';
import 'package:biconcept_in/features/studio/studio_page.dart';
import 'package:biconcept_in/features/work/project_page.dart';
import 'package:biconcept_in/features/work/work_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => const _NotFoundPage(),
    observers: [_SeoObserver()],
    routes: [
      ShellRoute(
        builder: (context, state, child) => SiteScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => _fade(state, const HomePage()),
          ),
          GoRoute(
            path: '/architecture',
            pageBuilder: (context, state) =>
                _fade(state, const ServicePage(slug: 'architecture')),
          ),
          GoRoute(
            path: '/interiors',
            pageBuilder: (context, state) =>
                _fade(state, const ServicePage(slug: 'interiors')),
          ),
          GoRoute(
            path: '/real-estate',
            pageBuilder: (context, state) =>
                _fade(state, const ServicePage(slug: 'real-estate')),
          ),
          GoRoute(
            path: '/work',
            pageBuilder: (context, state) => _fade(state, const WorkPage()),
            routes: [
              GoRoute(
                path: ':slug',
                pageBuilder: (context, state) {
                  final slug = state.pathParameters['slug']!;
                  return _fade(state, ProjectPage(slug: slug));
                },
              ),
            ],
          ),
          GoRoute(
            path: '/listings',
            pageBuilder: (context, state) => _fade(state, const ListingsPage()),
            routes: [
              GoRoute(
                path: ':city',
                pageBuilder: (context, state) => _fade(
                  state,
                  ListingsPage(citySlug: state.pathParameters['city']),
                ),
                routes: [
                  GoRoute(
                    path: ':sector',
                    pageBuilder: (context, state) => _fade(
                      state,
                      ListingsPage(
                        citySlug: state.pathParameters['city'],
                        sectorSlug: state.pathParameters['sector'],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/studio',
            pageBuilder: (context, state) => _fade(state, const StudioPage()),
          ),
          GoRoute(
            path: '/inquire',
            pageBuilder: (context, state) {
              final query = state.uri.queryParameters;
              return _fade(
                state,
                InquirePage(
                  listingId: query['listing'],
                  city: query['city'],
                  sector: query['sector'],
                  practiceSlug: query['practice'],
                  offer: query['offer'],
                ),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/admin/login',
        pageBuilder: (context, state) => _fade(state, const AdminLoginPage()),
      ),
      GoRoute(
        path: '/admin',
        pageBuilder: (context, state) => _fade(state, const AdminShell(section: 'home')),
      ),
      GoRoute(
        path: '/admin/leads',
        pageBuilder: (context, state) => _fade(state, const AdminShell(section: 'leads')),
      ),
      GoRoute(
        path: '/admin/listings',
        pageBuilder: (context, state) => _fade(state, const AdminShell(section: 'listings')),
      ),
      GoRoute(
        path: '/admin/showcase',
        pageBuilder: (context, state) => _fade(state, const AdminShell(section: 'showcase')),
      ),
      GoRoute(
        path: '/admin/services',
        pageBuilder: (context, state) => _fade(state, const AdminShell(section: 'services')),
      ),
      GoRoute(
        path: '/admin/offers',
        pageBuilder: (context, state) => _fade(state, const AdminShell(section: 'offers')),
      ),
      GoRoute(
        path: '/admin/agents',
        pageBuilder: (context, state) => _fade(state, const AdminShell(section: 'agents')),
      ),
    ],
  );
}

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondary, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: child,
      );
    },
  );
}

class _SeoObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _apply(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _apply(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _apply(previousRoute);
  }

  void _apply(Route<dynamic> route) {
    final settingsName = route.settings.name;
    var path = '/';
    if (settingsName != null && settingsName.isNotEmpty) {
      path = settingsName;
    }
    final seo = SiteSeo.forPath(path);
    String title = seo.title;
    String description = seo.description;
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
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Page not found.', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Return home'),
            ),
          ],
        ),
      ),
    );
  }
}
