import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

class SecurityService {
  static final _auth = LocalAuthentication();

  static Future<bool> canAuthenticate() async {
    return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
  }

  static Future<bool> authenticate() async {
    try {
      if (!await canAuthenticate()) return false;

      return await _auth.authenticate(
        localizedReason: 'Gunakan biometrik untuk membuka data akun',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allows PIN/Password as fallback
        ),
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Autentikasi Biometrik Diperlukan',
            deviceCredentialsRequiredTitle: 'Autentikasi Diperlukan',
          ),
        ],
      );
    } on PlatformException {
      return false;
    }
  }
}
