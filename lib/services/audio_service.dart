import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';

/// 🎵 Enhanced Audio Service for HamiKisan - Production Ready
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _secondaryPlayer = AudioPlayer();
  final AudioCache _audioCache = AudioCache(prefix: 'sound/');

  // Sound file paths
  static const _soundAssets = {
    'incoming_call': 'incomming_call_ringtone.mp3',
    'outgoing_call': 'outgoing_call_ring.mp3',
    'call_connected': 'connected_tone.mp3',
    'call_ended': 'end_tone.mp3',
    'message_sent': 'message/message_send.mp3',
    'message_received': 'message/message_received.mp3',
    'notification': 'message/notification.mp3',
    'error': 'error_tone.mp3',
    'success': 'success_tone.mp3',
    'button_click': 'ui/button_click.mp3',
    'swipe': 'ui/swipe.mp3',
    'emergency_alert': 'emergency/alert.mp3',
  };

  // State management
  bool _isPlayingCallSound = false;
  bool _isMuted = false;
  Completer<void>? _callSoundCompleter;
  Timer? _vibrationTimer;
  double _volumeLevel = 1.0;

  // Audio preferences
  AudioPreferences _preferences = AudioPreferences();

  // Event streams
  final StreamController<AudioEvent> _eventController =
      StreamController<AudioEvent>.broadcast();
  Stream<AudioEvent> get events => _eventController.stream;

  /// 🎵 Initialize audio service with preferences
  Future<void> initialize({AudioPreferences? preferences}) async {
    try {
      if (preferences != null) {
        _preferences = preferences;
      }

      // Configure players
      await _player.setReleaseMode(ReleaseMode.stop);
      await _secondaryPlayer.setReleaseMode(ReleaseMode.stop);

      // Set prefix for sound assets
      _player.audioCache.prefix = 'sound/';
      _secondaryPlayer.audioCache.prefix = 'sound/';

      // Set initial volume
      await _player.setVolume(_preferences.volume);
      await _secondaryPlayer.setVolume(_preferences.volume);

      // Configure audio session based on platform
      await _configureAudioSession();

      // Preload frequently used sounds
      if (_preferences.preloadSounds) {
        await _preloadCommonSounds();
      }

      _eventController.add(AudioEvent.initialized());
      print('🎵 Audio Service Initialized with volume: ${_preferences.volume}');
    } catch (e, stack) {
      print('❌ Audio initialization error: $e\n$stack');
      _eventController.add(AudioEvent.error('Initialization failed: $e'));
    }
  }

  /// 📞 Play incoming call with smart handling
  Future<void> playIncomingCall({
    String? customRingtone,
    bool? vibrate,
    Duration? vibrationPattern,
    bool isUrgent = false,
    String callerType = 'doctor',
  }) async {
    if (_isPlayingCallSound && !isUrgent) {
      // Already ringing, don't interrupt unless urgent
      return;
    }

    // Stop any existing call sound
    await stopCallSound();

    _isPlayingCallSound = true;
    _callSoundCompleter = Completer();

    try {
      // Determine ringtone
      String ringtone;
      if (customRingtone != null) {
        ringtone = customRingtone;
      } else if (isUrgent) {
        ringtone = _soundAssets['emergency_alert']!;
      } else {
        ringtone = _soundAssets['incoming_call']!;
      }

      // Configure player
      await _player.stop();
      await _player.setSource(AssetSource(ringtone));
      await _player.setReleaseMode(ReleaseMode.loop);

      // Adjust volume for call context
      await _player.setVolume(isUrgent
          ? 1.0
          : _preferences.volume * _preferences.callVolumeMultiplier);

      // Start vibration if enabled and device supports it
      final shouldVibrate = vibrate ?? _preferences.vibrateOnCall;
      if (shouldVibrate && await _canVibrate()) {
        _startSmartVibrationPattern(
          isUrgent: isUrgent,
          pattern: vibrationPattern ?? _preferences.vibrationPattern,
        );
      }

      // Play the ringtone
      await _player.play(AssetSource(ringtone));
      _eventController.add(AudioEvent.ringingStarted(callerType, isUrgent));

      // Set auto-decline timeout
      if (!isUrgent) {
        Timer(const Duration(seconds: 45), () async {
          if (_isPlayingCallSound) {
            await stopCallSound();
            _eventController.add(AudioEvent.callMissed());
          }
        });
      }

      // Wait for completion
      await _callSoundCompleter!.future;
    } catch (e, stack) {
      print('❌ Error playing incoming call: $e\n$stack');
      _eventController.add(AudioEvent.error('Call ring failed: $e'));
      await stopCallSound();
    }
  }

  /// 📞 Play outgoing call with progress feedback
  Future<void> playOutgoingCall({
    String? recipientName,
    bool vibrate = false,
  }) async {
    try {
      await stopCallSound();

      _isPlayingCallSound = true;
      _callSoundCompleter = Completer();

      await _player.stop();
      await _player.setSource(AssetSource(_soundAssets['outgoing_call']!));
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(_preferences.volume * 0.7);
      await _player.play(AssetSource(_soundAssets['outgoing_call']!));

      _eventController.add(AudioEvent.outgoingStarted(recipientName));

// Gentle vibration feedback on Android
      if (vibrate &&
          !kIsWeb &&
          defaultTargetPlatform == TargetPlatform.android &&
          await _canVibrate()) {
        await _safeVibrate(duration: 50, amplitude: 30);
      }
    } catch (e, stack) {
      print('❌ Error playing outgoing call: $e\n$stack');
      _eventController.add(AudioEvent.error('Outgoing call failed: $e'));
      await stopCallSound();
    }
  }

  /// ✅ Play call connected sound with haptic feedback
  Future<void> playCallConnected() async {
    try {
      await _playSingleSound(
        _soundAssets['call_connected']!,
        volume: _preferences.volume * 0.8,
      );

      // Haptic feedback
      if (await _canVibrate()) {
        await _safeVibrate(duration: 100, amplitude: 80);
      }

      _eventController.add(AudioEvent.callConnected());
    } catch (e) {
      print('❌ Error playing call connected sound: $e');
    }
  }

  /// ❌ Play call ended sound
  Future<void> playCallEnded({String? reason}) async {
    try {
      await _playSingleSound(
        _soundAssets['call_ended']!,
        volume: _preferences.volume * 0.6,
      );

      _eventController.add(AudioEvent.callEnded(reason));
    } catch (e) {
      print('❌ Error playing call ended sound: $e');
    }
  }

  /// ✉️ Play message sent sound
  Future<void> playMessageSent() async {
    try {
      await _playSingleSound(
        _soundAssets['message_sent']!,
        volume: _preferences.volume * 0.3,
      );
    } catch (e) {
      print('❌ Error playing message sent sound: $e');
    }
  }

  /// 📨 Play message received sound
  Future<void> playMessageReceived({bool isImportant = false}) async {
    try {
      await _playSingleSound(
        _soundAssets['message_received']!,
        volume: _preferences.volume * (isImportant ? 0.7 : 0.5),
      );

      if (isImportant && await _canVibrate()) {
        await _safeVibrate(duration: 150);
      }
    } catch (e) {
      print('❌ Error playing message received sound: $e');
    }
  }

  /// 🔔 Play notification sound with smart behavior
  Future<void> playNotification({
    String? customSound,
    bool? vibrate,
    NotificationType type = NotificationType.normal,
  }) async {
    try {
      final sound = customSound ?? _soundAssets['notification']!;

      double volume;
      switch (type) {
        case NotificationType.urgent:
          volume = _preferences.volume;
          break;
        case NotificationType.important:
          volume = _preferences.volume * 0.8;
          break;
        case NotificationType.normal:
          volume = _preferences.volume * 0.6;
          break;
        case NotificationType.silent:
          volume = 0.1;
          break;
      }

      await _playSingleSound(sound, volume: volume);

      final shouldVibrate = vibrate ?? _preferences.vibrateOnNotification;
      if (shouldVibrate && await _canVibrate()) {
        switch (type) {
          case NotificationType.urgent:
            await _safeVibrate(pattern: [0, 500, 200, 500]);
            break;
          case NotificationType.important:
            await _safeVibrate(duration: 300);
            break;
          case NotificationType.normal:
            await _safeVibrate(duration: 100);
            break;
          case NotificationType.silent:
            break;
        }
      }

      _eventController.add(AudioEvent.notificationPlayed(type));
    } catch (e) {
      print('❌ Error playing notification: $e');
    }
  }

  /// ⚠️ Play error sound
  Future<void> playError({String? message}) async {
    try {
      await _playSingleSound(
        _soundAssets['error']!,
        volume: _preferences.volume * 0.4,
      );

      _eventController.add(AudioEvent.errorSoundPlayed(message));
    } catch (e) {
      print('❌ Error playing error sound: $e');
    }
  }

  /// ✅ Play success sound
  Future<void> playSuccess() async {
    try {
      await _playSingleSound(
        _soundAssets['success']!,
        volume: _preferences.volume * 0.5,
      );

      // Gentle haptic feedback
      if (await _canVibrate()) {
        await _safeVibrate(duration: 50, amplitude: 40);
      }
    } catch (e) {
      print('❌ Error playing success sound: $e');
    }
  }

  /// 🎮 Play UI interaction sound
  Future<void> playButtonClick() async {
    if (!_preferences.uiSoundsEnabled) return;

    try {
      await _playSingleSound(
        _soundAssets['button_click']!,
        volume: _preferences.volume * 0.2,
      );
    } catch (e) {
      // Silently fail for UI sounds
    }
  }

  /// ⏹️ Stop call sound
  Future<void> stopCallSound() async {
    try {
      await _player.stop();
      await _player.release();
      _isPlayingCallSound = false;

      if (_callSoundCompleter != null && !_callSoundCompleter!.isCompleted) {
        _callSoundCompleter!.complete();
      }
      _callSoundCompleter = null;

      _stopVibration();
      _eventController.add(AudioEvent.ringingStopped());
    } catch (e) {
      print('❌ Error stopping call sound: $e');
    }
  }

  /// 🔇 Set mute state
  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    try {
      await _player.setVolume(_isMuted ? 0.0 : _volumeLevel);
      await _secondaryPlayer.setVolume(_isMuted ? 0.0 : _volumeLevel);

      _eventController
          .add(_isMuted ? AudioEvent.muted() : AudioEvent.unmuted());
    } catch (e) {
      print('❌ Error setting mute: $e');
    }
  }

  /// 🔇 Toggle mute state
  Future<void> toggleMute() async {
    await setMuted(!_isMuted);
  }

  /// 🔊 Adjust volume
  Future<void> setVolume(double volume) async {
    _volumeLevel = volume.clamp(0.0, 1.0);
    _preferences.volume = _volumeLevel;

    if (!_isMuted) {
      try {
        await _player.setVolume(_volumeLevel);
        await _secondaryPlayer.setVolume(_volumeLevel);
      } catch (e) {
        print('❌ Error setting volume: $e');
      }
    }
  }

  /// 📱 Handle audio focus changes
  Future<void> handleAudioFocus([AudioFocusState? state]) async {
    try {
      if (state == AudioFocusState.lost) {
        // Reduce volume when audio focus is lost
        await _player.setVolume(_volumeLevel * 0.3);
      } else if (state == AudioFocusState.gained) {
        // Restore volume when focus is regained
        await _player.setVolume(_isMuted ? 0.0 : _volumeLevel);
      }
    } catch (e) {
      print('❌ Error handling audio focus: $e');
    }
  }

  /// 🧹 Clean up resources
  Future<void> dispose() async {
    try {
      await stopCallSound();
      await _secondaryPlayer.dispose();
      await _player.dispose();
      _stopVibration();
      await _eventController.close();
    } catch (e) {
      print('❌ Error disposing audio service: $e');
    }
  }

  // Private helper methods
  Future<void> _playSingleSound(String asset, {double volume = 1.0}) async {
    try {
      await _secondaryPlayer.stop();
      await _secondaryPlayer.setSource(AssetSource(asset));
      await _secondaryPlayer.setVolume(volume);
      await _secondaryPlayer.setReleaseMode(ReleaseMode.stop);
      await _secondaryPlayer.play(AssetSource(asset));
    } catch (e) {
      rethrow;
    }
  }

  void _startSmartVibrationPattern({
    required bool isUrgent,
    Duration pattern = const Duration(milliseconds: 500),
  }) {
    _stopVibration();

    if (isUrgent) {
      // Urgent pattern: strong and frequent
      _vibrationTimer =
          Timer.periodic(const Duration(milliseconds: 300), (timer) {
        unawaited(_safeVibrate(duration: 200, amplitude: 255));
      });
    } else {
      // Normal pattern: gentle and spaced
      _vibrationTimer = Timer.periodic(pattern, (timer) {
        unawaited(_safeVibrate(duration: 150, amplitude: 128));
      });
    }
  }

  void _stopVibration() {
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
    unawaited(_safeCancelVibration());
  }

  Future<bool> _canVibrate() async {
    if (kIsWeb || !_preferences.vibrationEnabled) return false;
    try {
      return await Vibration.hasVibrator() == true;
    } on MissingPluginException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _safeVibrate({
    int? duration,
    int? amplitude,
    List<int>? pattern,
  }) async {
    if (!await _canVibrate()) return;
    try {
      if (pattern != null) {
        await Vibration.vibrate(pattern: pattern);
      } else {
        final safeDuration = duration ?? 100;
        final safeAmplitude = amplitude ?? 128;
        await Vibration.vibrate(
          duration: safeDuration,
          amplitude: safeAmplitude,
        );
      }
    } on MissingPluginException {
      // Plugin not available on this platform; ignore.
    } catch (_) {
      // Ignore vibration failures to avoid breaking call flow.
    }
  }

  Future<void> _safeCancelVibration() async {
    if (kIsWeb) return;
    try {
      await Vibration.cancel();
    } on MissingPluginException {
      // Plugin not available on this platform; ignore.
    } catch (_) {
      // Ignore vibration cancel failures.
    }
  }

  Future<void> _configureAudioSession() async {
    try {
      // Skip audio session configuration on web
      if (kIsWeb) {
        return;
      }

      if (defaultTargetPlatform == TargetPlatform.android) {
        await _player.setPlayerMode(PlayerMode.mediaPlayer);
        await _player.setAudioContext(AudioContext(
          android: AudioContextAndroid(
            contentType: AndroidContentType.speech,
          ),
        ));
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _player.setAudioContext(AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playAndRecord,
            options: {
              AVAudioSessionOptions.mixWithOthers,
              AVAudioSessionOptions.defaultToSpeaker,
            },
          ),
        ));
      }
    } catch (e) {
      print('⚠️ Audio session configuration failed: $e');
    }
  }

  Future<void> _preloadCommonSounds() async {
    try {
      final commonSounds = [
        _soundAssets['notification']!,
        _soundAssets['message_sent']!,
        _soundAssets['message_received']!,
        _soundAssets['button_click']!,
      ];

      for (final sound in commonSounds) {
        await _audioCache.load(sound);
      }
    } catch (e) {
      print('⚠️ Sound preloading failed: $e');
    }
  }
}

/// 🎛️ Audio Preferences
class AudioPreferences {
  double volume = 0.8;
  bool vibrateOnCall = true;
  bool vibrateOnNotification = true;
  bool vibrationEnabled = true;
  bool uiSoundsEnabled = true;
  bool preloadSounds = true;
  Duration vibrationPattern = const Duration(milliseconds: 500);
  double callVolumeMultiplier = 0.9;
  double notificationVolumeMultiplier = 0.6;
}

/// 📊 Audio Events
enum AudioEventType {
  initialized,
  ringingStarted,
  ringingStopped,
  outgoingStarted,
  callConnected,
  callEnded,
  callMissed,
  notificationPlayed,
  errorSoundPlayed,
  muted,
  unmuted,
  error,
}

class AudioEvent {
  final AudioEventType type;
  final dynamic data;
  final DateTime timestamp;

  AudioEvent(this.type, {this.data}) : timestamp = DateTime.now();

  factory AudioEvent.initialized() => AudioEvent(AudioEventType.initialized);
  factory AudioEvent.ringingStarted(String callerType, bool isUrgent) =>
      AudioEvent(AudioEventType.ringingStarted, data: {
        'callerType': callerType,
        'isUrgent': isUrgent,
      });
  factory AudioEvent.ringingStopped() =>
      AudioEvent(AudioEventType.ringingStopped);
  factory AudioEvent.outgoingStarted(String? recipientName) =>
      AudioEvent(AudioEventType.outgoingStarted, data: recipientName);
  factory AudioEvent.callConnected() =>
      AudioEvent(AudioEventType.callConnected);
  factory AudioEvent.callEnded(String? reason) =>
      AudioEvent(AudioEventType.callEnded, data: reason);
  factory AudioEvent.callMissed() => AudioEvent(AudioEventType.callMissed);
  factory AudioEvent.notificationPlayed(NotificationType type) =>
      AudioEvent(AudioEventType.notificationPlayed, data: type);
  factory AudioEvent.errorSoundPlayed(String? message) =>
      AudioEvent(AudioEventType.errorSoundPlayed, data: message);
  factory AudioEvent.muted() => AudioEvent(AudioEventType.muted);
  factory AudioEvent.unmuted() => AudioEvent(AudioEventType.unmuted);
  factory AudioEvent.error(String message) =>
      AudioEvent(AudioEventType.error, data: message);
}

/// 🔔 Notification Types
enum NotificationType {
  urgent,
  important,
  normal,
  silent,
}

/// 🔊 Audio Focus States
enum AudioFocusState {
  gained,
  lost,
  temporaryLoss,
}
