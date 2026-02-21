import 'dart:typed_data';

enum SecurityStatus {
  active,
  inactive,
  compromised,
  updating,
}

class EncryptedMessage {
  final Uint8List cipherText;
  final List<Uint8List>? attachments;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;
  final String sender;
  final String recipient;

  EncryptedMessage({
    required this.cipherText,
    this.attachments,
    required this.metadata,
    required this.timestamp,
    required this.sender,
    required this.recipient,
  });

  Map<String, dynamic> toJson() => {
        'cipherText': cipherText.toList(),
        'attachments': attachments?.map((a) => a.toList()).toList(),
        'metadata': metadata,
        'timestamp': timestamp.toIso8601String(),
        'sender': sender,
        'recipient': recipient,
      };
}

class SecurityHealth {
  final bool e2eeActive;
  final bool keysValid;
  final bool connectionSecure;
  final bool deviceSecure;
  final bool updatesAvailable;

  SecurityHealth({
    required this.e2eeActive,
    required this.keysValid,
    required this.connectionSecure,
    required this.deviceSecure,
    required this.updatesAvailable,
  });
}
