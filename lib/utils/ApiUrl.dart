import '../utils/StringsUtils.dart';

class ApiUrl {
  static const String BASEURL = StringsUtils.BASEURL;
  //DO NOT EDIT THE LINES BELOW, ELSE THE APPLICATION WILL MISBEHAVE
  static const String CATEGORIES = BASEURL + "categories";
  static const String ARTICLES = BASEURL + "articles";
  static const String VIDEOS = BASEURL + "youtube";
  static const String RADIO = BASEURL + "radiosv2";
  static const String SEARCH = BASEURL + "query";
  static const String REGISTER = BASEURL + "registerUser";
  static const String LOGIN = BASEURL + "signinUser";
  static const String RESETPASSWORD = BASEURL + "passwordReset";
  static const String gettotallikesandcommentsviews =
      BASEURL + "gettotallikesandcommentsviewsv2";
  static const String update_post_total_views =
      BASEURL + "update_post_total_viewsv2";
  static const String likeunlikepost = BASEURL + "likeunlikepostv2";
  static const String editcomment = BASEURL + "editcommentv2";
  static const String deletecomment = BASEURL + "deletecommentv2";
  static const String makecomment = BASEURL + "makecommentv2";
  static const String loadcomments = BASEURL + "loadcommentsv2";
  static const String editreply = BASEURL + "editreplyv2";
  static const String deletereply = BASEURL + "deletereplyv2";
  static const String replycomment = BASEURL + "replycommentv2";
  static const String loadreplies = BASEURL + "loadrepliesv2";
  static const String reportcomment = BASEURL + "reportcommentv2";
  static const String storeFcmToken = BASEURL + "storeFcmTokenv2";
  static const String getArticleContent = BASEURL + "get_article_contentv2";
  static const String LIVESTREAMS = BASEURL + "fetch_livestreamsv2";
  static const String SOURCEARTICLES = BASEURL + "feeds_source";
  static const String SOURCEVIDEOS = BASEURL + "videos_source";
  static const String SOURCES = BASEURL + "sources";
}
