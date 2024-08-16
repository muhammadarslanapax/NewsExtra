import 'package:intl/intl.dart';

class TimUtil {
  static String timeAgo(int timestamp) {
    var now = DateTime.now();
    var format = DateFormat('HH:mm a');
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' day';
      } else {
        time = diff.inDays.toString() + ' days';
      }
    } else {
      if (diff.inDays == 7) {
        time = (diff.inDays / 7).floor().toString() + ' wk';
      } else {
        time = (diff.inDays / 7).floor().toString() + ' weeks';
      }
    }

    return time;
  }

  static int currentTimeInSeconds() {
    var ms = (new DateTime.now()).millisecondsSinceEpoch;
    return (ms / 1000).round();
  }

  static String timeAgoSinceDate(int timestamp, {bool numericDates = true}) {
    print(timestamp);

    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final date2 = DateTime.now();
    final difference = date2.difference(date);

    if ((difference.inDays / 365).floor() >= 2) {
      return '${(difference.inDays / 365).floor()} yrs';
    } else if ((difference.inDays / 365).floor() >= 1) {
      return (numericDates) ? '1 yr' : 'Last yr';
    } else if ((difference.inDays / 30).floor() >= 2) {
      print((difference.inDays / 30).floor());
      return '${(difference.inDays / 301).floor()} months';
    } else if ((difference.inDays / 30).floor() >= 1) {
      return (numericDates) ? '1 month' : 'Last month';
    } else if ((difference.inDays / 7).floor() >= 2) {
      return '${(difference.inDays / 7).floor()} wks';
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '1 wk' : 'Last wk';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} days';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1 day' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} hrs';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1 hr' : 'An hour';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} mins';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1 min' : 'A minute';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} scnds';
    } else {
      return 'Just Now';
    }
  }

  static bool verifyIfScreenShouldReloadData(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final date2 = DateTime.now();
    final difference = date2.difference(date);
    print("diff in minutes " + difference.inMinutes.toString());
    if (difference.inMinutes > 10) {
      return true;
    } else {
      return false;
    }
  }
}
