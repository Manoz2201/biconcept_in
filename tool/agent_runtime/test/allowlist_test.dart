import 'package:agent_runtime/agent_runtime.dart';
import 'package:test/test.dart';

void main() {
  test('SEO allowlist accepts copy and seo assets only', () {
    expect(isSeoAllowlisted('assets/seo/pages.json'), isTrue);
    expect(isSeoAllowlisted('assets/seo/runs/2026.json'), isTrue);
    expect(isSeoAllowlisted('web/sitemap.xml'), isTrue);
    expect(isSeoAllowlisted('web/index.html'), isTrue);
    expect(isSeoAllowlisted('lib/content/copy.dart'), isTrue);
    expect(isSeoAllowlisted('lib/data/appwrite_config.dart'), isFalse);
    expect(isSeoAllowlisted('lib/features/admin/admin_login_page.dart'), isFalse);
  });

  test('withJob runs the body when APPWRITE_API_KEY is absent', () async {
    final result = await withJob(
      agentId: 'market',
      title: 'progress',
      body: (writer, jobId) async {
        expect(writer, isNull);
        expect(jobId, isNull);
        return 10;
      },
    );
    expect(result, 10);
  });
}
