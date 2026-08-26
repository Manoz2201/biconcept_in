/// Public Appwrite IDs only. Never put API keys or passwords in the client.
///
/// Web sessions require this hostname as an Appwrite **Web** platform:
/// Web sessions require this hostname as an Appwrite **Web** platform:
/// `localhost` (dev) and `manoz2201.github.io` (GitHub Pages). Without that
/// registration, Auth cookies and CORS fail in the browser.
abstract final class AppwriteConfig {
  static const endpoint = 'https://sgp.cloud.appwrite.io/v1';
  static const projectId = '6a8de2d2003a8c9f54fe';
  static const databaseId = 'biconcept';

  static const tableListings = 'listings';
  static const tableLeads = 'leads';
  static const tableShowcase = 'showcase';
  static const tableServices = 'services';
  static const tableOffers = 'offers';
  static const tableAgentJobs = 'agent_jobs';
  static const bucketMedia = 'media';
  static const functionConcierge = 'studio-concierge';

  static const adminEmailDomain = 'biconcept.in';

  static String emailFromUsername(String username) {
    final trimmed = username.trim();
    if (trimmed.contains('@')) return trimmed;
    if (trimmed.toLowerCase() == 'manozsingharya') {
      return 'manozsingharya@$adminEmailDomain';
    }
    return '$trimmed@$adminEmailDomain';
  }

  static String fileViewUrl(String fileId) {
    if (fileId.startsWith('http://') || fileId.startsWith('https://')) {
      return fileId;
    }
    return '$endpoint/storage/buckets/$bucketMedia/files/$fileId/view?project=$projectId';
  }
}
