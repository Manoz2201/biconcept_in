import 'package:biconcept_in/content/seo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads pages.json and resolves SiteSeo paths', () async {
    await SiteSeo.load();
    expect(SiteSeo.home.h1, 'One concept. Every scale.');
    expect(SiteSeo.home.faqs, isNotEmpty);
    expect(SiteSeo.architecture.path, '/architecture');
    expect(SiteSeo.forPath('/architecture').faqs, isNotEmpty);
    expect(SiteSeo.forPath('/interiors').title, contains('Interior'));
    expect(SiteSeo.forPath('/real-estate').h1, 'Land, composed.');
    expect(SiteSeo.listings.h1, 'NCR, by pocket.');
    expect(SiteSeo.forPath('/listings/noida').path, '/listings');
    expect(SiteSeo.forPath('/missing').path, '/');
  });
}
