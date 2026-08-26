import 'package:agent_runtime/agent_runtime.dart';
import 'package:test/test.dart';

void main() {
  test('dispatcher only runs known CMS and SEO agents', () {
    expect(isSeoAllowlisted('lib/content/copy.dart'), isTrue);
    expect(isSeoAllowlisted('lib/data/appwrite_config.dart'), isFalse);
  });
}
