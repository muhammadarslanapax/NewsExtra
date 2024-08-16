import 'package:flutter/material.dart';
import 'package:newsextra/providers/InterstitialAdsModel.dart';
import './screens/VideosSourceFeedScreen.dart';
import './utils/TextStyles.dart';
import './screens/ArticleViewerScreen.dart';
import './models/ScreenArguements.dart';
import './screens/VideoViewerScreen.dart';
import './screens/FeedSourcesScreen.dart';
import './screens/LoginScreen.dart';
import './screens/OnboardingPage.dart';
import './screens/CommentsScreen.dart';
import './screens/RepliesScreen.dart';
import './i18n/strings.g.dart';
import './screens/ForgotPasswordScreen.dart';
import './screens/RegisterScreen.dart';
import './video_player/LiveTVPlayer.dart';
import './models/Articles.dart';
import './providers/AppStateNotifier.dart';
import './screens/HomePage.dart';
import './screens/CategoriesScreen.dart';
import './screens/SourcesScreen.dart';
import './screens/SearchScreen.dart';
import './models/CommentsArguement.dart';
import './models/Videos.dart';
import 'package:provider/provider.dart';
import './utils/Firebase.dart';
import './utils/AppTheme.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
    required Widget? defaultHome,
  })  : _defaultHome = defaultHome,
        super(key: key);

  final Widget? _defaultHome;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey(debugLabel: "Main Navigator");
  //BuildContext? context;
  bool isAdmobLoaded = false;
  navigateArticle(List<Articles> artsList) async {
    var count = await navigatorKey.currentState!.pushNamed(
        ArticleViewerScreen.routeName,
        arguments: ScreenArguements(position: 0, items: artsList));

    if (count == 0) {
      InterstitialAdsModel.loadInterstitialAds();
    }
  }

  navigateVideo(List<Videos> vidsList) async {
    var count = await navigatorKey.currentState!.pushNamed(
        VideoViewerScreen.routeName,
        arguments: ScreenArguements(position: 0, items: vidsList));

    if (count == 0) {
      InterstitialAdsModel.loadInterstitialAds();
    }
  }

  initFirebasePushNotifications() async {
    Firebase(context, navigateArticle, navigateVideo).init();
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 0), () {
      initFirebasePushNotifications();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //this.context = context;
    AppStateNotifier? appState = Provider.of<AppStateNotifier>(context);

    return RefreshConfiguration(
      footerTriggerDistance: 15,
      dragSpeedRatio: 0.91,
      headerBuilder: () => MaterialClassicHeader(),
      footerBuilder: () => ClassicFooter(),
      enableLoadingWhenNoData: false,
      shouldFooterFollowWhenNotFull: (state) {
        // If you want load more with noMoreData state ,may be you should return false
        return false;
      },
      //autoLoad: true,
      child: Directionality(
        textDirection:
            appState.isRtlEnabled! ? TextDirection.rtl : TextDirection.ltr,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'App',
          localizationsDelegates: [
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [
            Locale("fa", "IR"), // OR Locale('ar', 'AE') OR Other RTL locales
            Locale("en"),
          ],
          locale: appState.isRtlEnabled! ? Locale("fa", "IR") : Locale("en"),
          home: appState.isLoadingTheme!
              ? Container(
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(height: 10),
                          Text(t.appname,
                              style: TextStyles.medium(context).copyWith(
                                  fontFamily: "serif",
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30)),
                          Container(height: 12),
                          Text(t.loadingapp,
                              style: TextStyles.body1(context)
                                  .copyWith(color: Colors.grey[500])),
                          Container(height: 50),
                          CupertinoActivityIndicator(
                            radius: 20,
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : widget._defaultHome,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme, // ThemeData(primarySwatch: Colors.blue),
          darkTheme:
              AppTheme.darkTheme, // ThemeData(primarySwatch: Colors.blue),
          themeMode: appState.isDarkModeOn! ? ThemeMode.dark : ThemeMode.light,

          onGenerateRoute: (settings) {
            if (settings.name == HomePage.routeName) {
              return MaterialPageRoute(
                builder: (context) {
                  return HomePage();
                },
              );
            }
            if (settings.name == OnboardingPage.routeName) {
              return MaterialPageRoute(
                builder: (context) {
                  return OnboardingPage();
                },
              );
            }
            if (settings.name == OnboardingPage.routeName) {
              return MaterialPageRoute(
                builder: (context) {
                  return OnboardingPage();
                },
              );
            }

            if (settings.name == CategoriesScreen.routeName) {
              return MaterialPageRoute(
                builder: (context) {
                  return CategoriesScreen(
                    isFirstLoad: false,
                  );
                },
              );
            }
            if (settings.name == SourcesScreen.routeName) {
              return MaterialPageRoute(
                builder: (context) {
                  return SourcesScreen();
                },
              );
            }
            if (settings.name == SearchScreen.routeName) {
              return MaterialPageRoute(
                builder: (context) {
                  return SearchScreen();
                },
              );
            }
            // ArticleViewerScreen
            if (settings.name == ArticleViewerScreen.routeName) {
              // Cast the arguments to the correct type: ScreenArguments.
              final ScreenArguements? args =
                  settings.arguments as ScreenArguements?;
              return MaterialPageRoute(
                builder: (context) {
                  return ArticleViewerScreen(
                    position: args!.position,
                    articlesList: args.items as List<Articles>?,
                  );
                },
              );
            }
            if (settings.name == FeedSourcesScreen.routeName) {
              // Cast the arguments to the correct type: ScreenArguments.
              final ScreenArguements? args =
                  settings.arguments as ScreenArguements?;
              return MaterialPageRoute(
                builder: (context) {
                  return FeedSourcesScreen(
                    article: args!.object as Articles?,
                  );
                },
              );
            }
            if (settings.name == VideosSourceFeedScreen.routeName) {
              // Cast the arguments to the correct type: ScreenArguments.
              final ScreenArguements? args =
                  settings.arguments as ScreenArguements?;
              return MaterialPageRoute(
                builder: (context) {
                  return VideosSourceFeedScreen(
                    videos: args!.object as Videos?,
                  );
                },
              );
            }
            if (settings.name == VideoViewerScreen.routeName) {
              // Cast the arguments to the correct type: ScreenArguments.
              final ScreenArguements? args =
                  settings.arguments as ScreenArguements?;
              return MaterialPageRoute(
                builder: (context) {
                  return VideoViewerScreen(
                    position: args!.position,
                    videosList: args.items as List<Videos>?,
                  );
                },
              );
            }

            if (settings.name == CommentsScreen.routeName) {
              // Cast the arguments to the correct type: ScreenArguments.
              final CommentsArguement? args =
                  settings.arguments as CommentsArguement?;
              return MaterialPageRoute(
                builder: (context) {
                  return CommentsScreen(
                    type: args!.type,
                    item: args.item,
                    commentCount: args.commentCount,
                  );
                },
              );
            }

            if (settings.name == RepliesScreen.routeName) {
              // Cast the arguments to the correct type: ScreenArguments.
              final CommentsArguement? args =
                  settings.arguments as CommentsArguement?;
              return MaterialPageRoute(
                builder: (context) {
                  return RepliesScreen(
                    item: args!.item,
                    repliesCount: args.commentCount,
                  );
                },
              );
            }

            if (settings.name == LoginScreen.routeName) {
              return MaterialPageRoute(
                builder: (context) {
                  return LoginScreen();
                },
              );
            }

            if (settings.name == RegisterScreen.routeName) {
              return MaterialPageRoute(
                builder: (context) {
                  return RegisterScreen();
                },
              );
            }

            if (settings.name == ForgotPasswordScreen.routeName) {
              return MaterialPageRoute(
                builder: (context) {
                  return ForgotPasswordScreen();
                },
              );
            }

            if (settings.name == LiveTVPlayer.routeName) {
              final ScreenArguements? args =
                  settings.arguments as ScreenArguements?;
              return MaterialPageRoute(
                builder: (context) {
                  return LiveTVPlayer(
                    media: args!.object,
                    mediaList: args.items,
                  );
                },
              );
            }

            return MaterialPageRoute(
              builder: (context) {
                return HomePage();
              },
            );
          },
        ),
      ),
    );
  }
}
