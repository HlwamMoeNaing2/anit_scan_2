/// Access token used by the network client. The implementation lives in
/// core_storage and stores the value in the platform keystore.
abstract interface class SessionStore {
  Future<String?> readAccessToken();

  Future<void> saveAccessToken(String token);

  Future<void> clearSession();
}
