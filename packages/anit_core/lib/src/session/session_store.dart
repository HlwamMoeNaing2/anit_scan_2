/// Access token used by the network client. The implementation lives in
/// the data module and stores the value in the platform keystore.
abstract interface class SessionStore {
  Future<String?> readAccessToken();

  Future<void> saveAccessToken(String token);

  Future<void> clearSession();
}
