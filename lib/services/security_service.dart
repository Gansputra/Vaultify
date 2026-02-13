import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

class SecurityService {
  static final _auth = LocalAuthentication();

  static Future<bool> canAuthenticate() async {
    return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
  }

  static Future<bool> authenticate() async {
    try {
      if (!await canAuthenticate()) return false;

      return await _auth.authenticate(
        localizedReason: 'Please authenticate to view account details',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allows PIN/Password as fallback
        ),
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Biometric authentication required',
            deviceCredentialsRequiredTitle: 'Authentication required',
          ),
          IOSAuthMessages(),
        ],
      );
    } on PlatformException {
      return false;
    }
  }
}
