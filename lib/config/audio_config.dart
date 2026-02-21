class AudioConfig {
  // Farmer-specific audio preferences
  static const farmerPreferences = {
    'ringtone': 'sound/call/farmer_call.mp3',
    'notification': 'sound/messages/notification.wav',
    'volume': 0.8,
    'vibrate': true,
    'spoken_feedback': false, // For low-literacy farmers
  };

  // Doctor-specific audio preferences
  static const doctorPreferences = {
    'ringtone': 'sound/call/doctor_call.mp3',
    'notification': 'sound/messages/notification.wav',
    'volume': 0.6,
    'vibrate': true,
    'spoken_feedback': true,
  };

  // Emergency audio settings
  static const emergencySettings = {
    'override_silent': true,
    'max_volume': true,
    'repeat': 3,
    'cooldown': Duration(seconds: 30),
  };
}
