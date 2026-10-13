class AudioConfig {
  static const defaultPreferences = {
    'incomingRingtone': 'sound/incomming_call_ringtone.mp3',
    'outgoingRingtone': 'sound/outgoing_call_ring.mp3',
    'notification': 'sound/message/notification.mp3',
    'volume': 0.8,
    'vibrate': true,
  };

  // Emergency audio settings
  static const emergencySettings = {
    'override_silent': true,
    'max_volume': true,
    'repeat': 3,
    'cooldown': Duration(seconds: 30),
  };
}
