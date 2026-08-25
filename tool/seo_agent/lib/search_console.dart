/// Google Search Console is not wired in this phase.
/// It needs a live, verified Search Console property and OAuth.
///
/// Later: pull queries, impressions, and CTR, then bias the daily prompt.
class SearchConsoleClient {
  Future<Map<String, dynamic>?> fetch() async => null;
}
