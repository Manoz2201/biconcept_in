import 'package:appwrite/appwrite.dart';
import 'package:biconcept_in/data/appwrite_config.dart';

class AppwriteServices {
  AppwriteServices._() {
    client = Client()
        .setEndpoint(AppwriteConfig.endpoint)
        .setProject(AppwriteConfig.projectId);
    account = Account(client);
    tables = TablesDB(client);
    storage = Storage(client);
  }

  static final AppwriteServices instance = AppwriteServices._();

  late final Client client;
  late final Account account;
  late final TablesDB tables;
  late final Storage storage;
}
