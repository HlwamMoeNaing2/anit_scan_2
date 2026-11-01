import 'package:core_common/core_common.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract final class SecureKeys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
}

class SecureSessionStore implements SessionStore {
  SecureSessionStore(this._secureStore);

  final SecureStore _secureStore;

  @override
  Future<String?> readAccessToken() {
    return _secureStore.read(SecureKeys.accessToken);
  }

  @override
  Future<void> saveAccessToken(String token) {
    return _secureStore.write(SecureKeys.accessToken, token);
  }

  @override
  Future<void> clearSession() async {
    await _secureStore.delete(SecureKeys.accessToken);
    await _secureStore.delete(SecureKeys.refreshToken);
  }
}

/// Keystore-backed storage. Android uses Keystore AES-GCM. iOS uses the
/// Keychain and does not sync the item to iCloud.
class SecureStore {
  SecureStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(migrateWithBackup: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
              synchronizable: false,
            ),
          );

  final FlutterSecureStorage _storage;

  Future<String?> read(String key) {
    return _guard(() => _storage.read(key: key));
  }

  Future<void> write(String key, String value) {
    return _guard(() => _storage.write(key: key, value: value));
  }

  Future<void> delete(String key) {
    return _guard(() => _storage.delete(key: key));
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PlatformException catch (error) {
      throw AppException(
        const SecureStorageFailure('Saved information could not be opened.'),
        cause: error,
      );
    }
  }
}
