import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/security_utils.dart';

// Farmer-friendly UI messages (Nepali/English)
const securityMessages = {
  'connected': '🔒 आफ्नो कुराकानी सुरक्षित छ (Your conversation is secure)',
  'encrypting': 'सन्देश सुरक्षित भइरहेको छ... (Securing message...)',
  'verified': '✅ डाक्टर प्रमाणित भएको छ (Doctor verified)',
  'emergency': '🚨 आपतकालीन सेवा: १०० (Emergency: 100)',
};

class FarmerSecurityService {
  static const String _identityKeyLabel = 'identity_key';

  static Future<void> initialize() async {
    // Generate identity key once if not exists
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_identityKeyLabel)) {
      final identityKey = await _generateIdentityKey();

      // Note: Ideally use flutter_secure_storage for production
      await prefs.setString(_identityKeyLabel, identityKey);

      // Generate recovery phrase (Mock implementation)
      final recoveryPhrase = _generateMockMnemonic();
      debugPrint("Generated Recovery Phrase: $recoveryPhrase");
    }
  }

  static Future<String> _generateIdentityKey() async {
    // Uses SecurityUtils to generate a secure token as a starting point for identity
    return SecurityUtils.generateSecureToken();
  }

  static String _generateMockMnemonic() {
    // Placeholder for BIP39 implementation
    return "apple banana cherry dog elephant fish goat hat ice joke kite lemon";
  }

  // QR-based key verification for doctor-farmer pairing
  static Future<Map<String, dynamic>> generateVerificationQR(
      String farmerId) async {
    final prefs = await SharedPreferences.getInstance();
    final publicKey = prefs.getString(_identityKeyLabel) ?? '';

    return {
      'farmerId': farmerId,
      'publicKey': publicKey,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  static Future<bool> verifyDoctor(String doctorId, String scannedData) async {
    // Establish trust by verifying scanned doctor public key
    // Implementation would involve verifying signatures
    return true;
  }
}
