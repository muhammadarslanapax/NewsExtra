import 'dart:convert';
import '../models/LiveStreams.dart';

class Utility {
  static String getBase64EncodedString(String text) {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    return stringToBase64.encode(text.trim());
  }

  static String getBase64DecodedString(String text) {
    //print(text);
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    return stringToBase64.decode(text.trim());
  }

  static List<LiveStreams> removeCurrentLiveStreamsFromList(
      List<LiveStreams> mediaList, LiveStreams? media) {
    List<LiveStreams> playlist = [];
    for (LiveStreams item in mediaList) {
      if (item.id != media!.id) {
        playlist.add(item);
      }
    }
    return playlist;
  }
}
