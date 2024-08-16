import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:audiofileplayer/audio_system.dart';
import 'package:flutter/services.dart';
import 'package:newsextra/utils/Alerts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/Radios.dart';
import '../utils/my_colors.dart';

final Logger _logger = Logger('newsextra_flutter');

class AudioPlayerModel with ChangeNotifier {
  List<Radios?> currentPlaylist = [];
  Radios? currentMedia;
  int currentMediaPosition = 0;
  Color backgroundColor = MyColors.primary;
  bool isDialogShowing = false;

  double backgroundAudioDurationSeconds = 0.0;
  double backgroundAudioPositionSeconds = 0.0;

  bool isSeeking = false;
  Audio? _remoteAudio;
  bool remoteAudioPlaying = false;
  bool _remoteAudioLoading = false;
  bool isUserSubscribed = false;
  late BuildContext _context;
  late StreamController<double> audioProgressStreams;

  /// Identifiers for the two custom Android notification buttons.
  static const String replayButtonId = 'replayButtonId';
  static const String newReleasesButtonId = 'newReleasesButtonId';
  static const String skipPreviousButtonId = 'skipPreviousButtonId';
  static const String skipNextButtonId = 'skipNextButtonId';

  AudioPlayerModel() {
    getRepeatMode();
    AudioSystem.instance.addMediaEventListener(_mediaEventListener);
    audioProgressStreams = new StreamController<double>.broadcast();
    audioProgressStreams.add(0);
  }

  bool? _isRepeat = false;
  bool? get isRepeat => _isRepeat;
  changeRepeat() async {
    _isRepeat = !_isRepeat!;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("_isRepeatMode", _isRepeat!);
  }

  getRepeatMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("_isRepeatMode") != null) {
      _isRepeat = prefs.getBool("_isRepeatMode");
    }
  }

  setUserSubscribed(bool isUserSubscribed) {
    this.isUserSubscribed = isUserSubscribed;
  }

  setContext(BuildContext context) {
    _context = context;
  }

  bool _showList = false;
  bool get showList => _showList;
  setShowList(bool showList) {
    _showList = showList;
    notifyListeners();
  }

  preparePlaylist(List<Radios?> playlist, Radios media) async {
    currentPlaylist = playlist;
    startAudioPlayBack(media);
  }

  startAudioPlayBack(Radios media) {
    if (currentMedia != null && _remoteAudio != null) {
      _remoteAudio!.pause();
    }
    currentMedia = media;
    setCurrentMediaPosition();
    _remoteAudioLoading = true;
    remoteAudioPlaying = false;
    notifyListeners();
    audioProgressStreams.add(0);
    _remoteAudio = null;
    //_remoteAudio.dispose();
    _remoteAudio = Audio.loadFromRemoteUrl(media.link!,
        onDuration: (double durationSeconds) {
          _remoteAudioLoading = false;
          remoteAudioPlaying = true;
          backgroundAudioDurationSeconds = durationSeconds;
          notifyListeners();
          Future.delayed(const Duration(milliseconds: 1000), () {
            _resumeBackgroundAudio();
          });
        },
        onPosition: (double positionSeconds) {
          print("positionSeconds = " + positionSeconds.toString());
          backgroundAudioPositionSeconds = positionSeconds;
          //if (isSeeking) return;
          audioProgressStreams.add(backgroundAudioPositionSeconds);
          //TimUtil.parseDuration(event.parameters["progress"].toString());
        },
        //looping: _isRepeat,
        onComplete: () {
          if (_isRepeat!) {
            /*backgroundAudioPositionSeconds = 0;
            audioProgressStreams.add(backgroundAudioPositionSeconds);
            _pauseBackgroundAudio();
            _resumeBackgroundAudio();*/
            startAudioPlayBack(currentMedia!);
          } else {
            skipNext();
          }
        },
        playInBackground: true,
        onError: (String? message) {
          _remoteAudio!.dispose();
          _remoteAudio = null;
          remoteAudioPlaying = false;
          _remoteAudioLoading = false;
          _stopBackgroundAudio();
          Alerts.showToast(
            _context,
            "Cant play this radio",
          );
        });
    //..play();
    remoteAudioPlaying = false;
    setMediaNotificationData(0);
  }

  setCurrentMediaPosition() {
    currentMediaPosition = currentPlaylist.indexOf(currentMedia);
    if (currentMediaPosition == -1) {
      currentMediaPosition = 0;
    }
    print("currentMediaPosition = " + currentMediaPosition.toString());
  }

  cleanUpResources() {
    _stopBackgroundAudio();
  }

  Widget icon() {
    if (_remoteAudioLoading) {
      return Theme(
          data: ThemeData(
              cupertinoOverrideTheme:
                  CupertinoThemeData(brightness: Brightness.dark)),
          child: CupertinoActivityIndicator());
    }
    if (remoteAudioPlaying) {
      return const Icon(
        Icons.pause,
        size: 30,
        color: Colors.white,
      );
    }
    return const Icon(
      Icons.play_arrow,
      size: 30,
      color: Colors.white,
    );
  }

  onPressed() {
    return remoteAudioPlaying
        ? _pauseBackgroundAudio()
        : _resumeBackgroundAudio();
  }

  void _mediaEventListener(MediaEvent mediaEvent) {
    _logger.info('App received media event of type: ${mediaEvent.type}');
    final MediaActionType type = mediaEvent.type;
    if (type == MediaActionType.play) {
      _resumeBackgroundAudio();
    } else if (type == MediaActionType.pause) {
      _pauseBackgroundAudio();
    } else if (type == MediaActionType.playPause) {
      remoteAudioPlaying ? _pauseBackgroundAudio() : _resumeBackgroundAudio();
    } else if (type == MediaActionType.stop) {
      _stopBackgroundAudio();
    } else if (type == MediaActionType.seekTo) {
      _remoteAudio!.seek(mediaEvent.seekToPositionSeconds!);
      AudioSystem.instance
          .setPlaybackState(true, mediaEvent.seekToPositionSeconds!);
    } else if (type == MediaActionType.next) {
      print("skip next");
      skipNext();
      final double? skipIntervalSeconds = mediaEvent.skipIntervalSeconds;
      _logger.info(
          'Skip-forward event had skipIntervalSeconds $skipIntervalSeconds.');
      _logger.info('Skip-forward is not implemented in this example app.');
    } else if (type == MediaActionType.previous) {
      print("skip next");
      skipPrevious();
      final double? skipIntervalSeconds = mediaEvent.skipIntervalSeconds;
      _logger.info(
          'Skip-backward event had skipIntervalSeconds $skipIntervalSeconds.');
      _logger.info('Skip-backward is not implemented in this example app.');
    } else if (type == MediaActionType.custom) {
      if (mediaEvent.customEventId == replayButtonId) {
        _remoteAudio!.play();
        AudioSystem.instance.setPlaybackState(true, 0.0);
      } else if (mediaEvent.customEventId == newReleasesButtonId) {
        _logger
            .info('New-releases button is not implemented in this exampe app.');
      }
    }
  }

  Future<void> _resumeBackgroundAudio() async {
    _remoteAudio!.resume();
    remoteAudioPlaying = true;
    notifyListeners();
    setMediaNotificationData(0);
  }

  void _pauseBackgroundAudio() {
    _remoteAudio!.pause();
    remoteAudioPlaying = false;
    notifyListeners();
    setMediaNotificationData(1);
  }

  void _stopBackgroundAudio() {
    if (_remoteAudio != null) _remoteAudio!.pause();
    currentMedia = null;
    notifyListeners();
    // setState(() => _backgroundAudioPlaying = false);
    AudioSystem.instance.stopBackgroundDisplay();
  }

  void shufflePlaylist() {
    currentPlaylist.shuffle();
    startAudioPlayBack(currentPlaylist[0]!);
  }

  skipPrevious() {
    if (currentPlaylist.length == 0 || currentPlaylist.length == 1) return;
    int pos = currentMediaPosition - 1;
    if (pos == -1) {
      pos = currentPlaylist.length - 1;
    }
  }

  skipNext() {
    if (currentPlaylist.length == 0 || currentPlaylist.length == 1) return;
    int pos = currentMediaPosition + 1;
    if (pos >= currentPlaylist.length) {
      pos = 0;
    }
  }

  seekTo(double positionSeconds) {
    //audioProgressStreams.add(_backgroundAudioPositionSeconds);
    //_remoteAudio.seek(positionSeconds);
    //isSeeking = false;
    backgroundAudioPositionSeconds = positionSeconds;
    _remoteAudio!.seek(positionSeconds);
    audioProgressStreams.add(backgroundAudioPositionSeconds);
    AudioSystem.instance.setPlaybackState(true, positionSeconds);
  }

  onStartSeek() {
    isSeeking = true;
  }

  setMediaNotificationData(int state) async {
    // final Uint8List imageBytes =
    //   await generateImageBytes(currentMedia.cover_photo);

    if (state == 0) {
      AudioSystem.instance
          .setPlaybackState(true, backgroundAudioPositionSeconds);
      AudioSystem.instance.setAndroidNotificationButtons(<dynamic>[
        AndroidMediaButtonType.pause,
        AndroidMediaButtonType.previous,
        AndroidMediaButtonType.next,
        AndroidMediaButtonType.stop,
        const AndroidCustomMediaButton(
            'replay', replayButtonId, 'ic_replay_black_36dp')
      ], androidCompactIndices: <int>[
        0
      ]);
    } else {
      AudioSystem.instance
          .setPlaybackState(false, backgroundAudioPositionSeconds);
      AudioSystem.instance.setAndroidNotificationButtons(<dynamic>[
        AndroidMediaButtonType.play,
        AndroidMediaButtonType.previous,
        AndroidMediaButtonType.next,
        AndroidMediaButtonType.stop,
        const AndroidCustomMediaButton(
            'replay', replayButtonId, 'ic_replay_black_36dp')
      ], androidCompactIndices: <int>[
        0
      ]);
    }

    AudioSystem.instance.setMetadata(AudioMetadata(
        title: currentMedia!.title,
        artist: currentMedia!.interest,
        album: currentMedia!.interest,
        genre: currentMedia!.interest,
        durationSeconds: backgroundAudioDurationSeconds,
        artBytes: await generateImageBytes(currentMedia!.thumbnail!)));

    AudioSystem.instance.setSupportedMediaActions(<MediaActionType>{
      MediaActionType.playPause,
      MediaActionType.pause,
      MediaActionType.next,
      MediaActionType.previous,
      MediaActionType.skipForward,
      MediaActionType.skipBackward,
      MediaActionType.seekTo,
    }, skipIntervalSeconds: 30);
  }

  /// Generates a 200x200 png, with randomized colors, to use as art for the
  /// notification/lockscreen.
  static Future<Uint8List> generateImageBytes(String coverphoto) async {
    /*Uint8List byteImage = await networkImageToByte(coverphoto);
    return byteImage;*/

    Uint8List bytes =
        (await NetworkAssetBundle(Uri.parse(coverphoto)).load(coverphoto))
            .buffer
            .asUint8List();
    return bytes;
  }
}
