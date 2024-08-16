import 'package:flutter/material.dart';
import '../providers/BookmarksModel.dart';
import '../providers/LiveStreamsModel.dart';
import '../screens/DrawerScreen.dart';
import '../viewholders/CategoriesNavHeader.dart';
import '../screens/SearchScreen.dart';
import '../screens/LiveStreamsScreen.dart';
import '../providers/RadioModel.dart';
import '../screens/ArticlesScreen.dart';
import '../screens/VideosScreen.dart';
import '../screens/BookmarksScreen.dart';
import '../screens/RadiosScreen.dart';
import '../viewholders/miniPlayer.dart';
import '../i18n/strings.g.dart';
import '../utils/my_colors.dart';
import 'package:provider/provider.dart';

import 'package:badges/badges.dart' as badge;

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);
  static const routeName = "/home";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RadioModel()),
      ],
      child: HomePageItem(),
    );
  }
}

class HomePageItem extends StatefulWidget {
  HomePageItem({
    Key? key,
  }) : super(key: key);

  final List<Widget> _widgetOptions = <Widget>[
    ArticlesScreen(),
    VideosScreen(),
    BookmarksScreen(),
    RadiosScreen(),
  ];

  @override
  _HomePageItemState createState() => _HomePageItemState();
}

class _HomePageItemState extends State<HomePageItem> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int currentIndex = 0;
  bool _headerVisibility = true;
  bool _mediaVisibility = false;
  ScrollController? _controller;
  String pinNo = "";

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  Widget buildPageView() {
    return PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: pageController,
      pageSnapping: false,
      onPageChanged: (index) {
        pageChanged(index);
      },
      children: widget._widgetOptions,
    );
  }

  void pageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookmarksModel = Provider.of<BookmarksModel>(context);
    int pinsSize = bookmarksModel.pinnedArticles.length +
        bookmarksModel.pinnedVideos.length;
    print("pinNo = " + pinsSize.toString());
    if (pinsSize != 0) {
      setState(() {
        pinNo = pinsSize > 9 ? "9+" : pinsSize.toString();
      });
    } else {
      pinNo = "";
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.appname),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: (() {
                Navigator.pushNamed(context, SearchScreen.routeName);
              }))
        ],
      ),
      body: Column(
        children: <Widget>[
          Visibility(
              visible: _headerVisibility,
              maintainState: true,
              child: categoriesNavHeader(_controller)),
          Expanded(child: buildPageView()),
          Visibility(visible: _mediaVisibility, child: MiniPlayer()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: MyColors.primary,
        unselectedItemColor: MyColors.grey_40,
        currentIndex: currentIndex,
        onTap: (int index) {
          setState(() {
            currentIndex = index;

            if (index == 0 || index == 1) {
              _headerVisibility = true;
            } else {
              _headerVisibility = false;
            }
            if (index == 3) {
              _mediaVisibility = true;
            } else {
              _mediaVisibility = false;
            }
          });
          pageController.jumpToPage(index);
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.chrome_reader_mode,
              ),
              label: t.articlesnav),
          BottomNavigationBarItem(
              icon: Icon(Icons.ondemand_video), label: t.videosnav),
          BottomNavigationBarItem(
              icon: badge.Badge(
                  badgeContent: Text(
                    pinNo,
                    style: TextStyle(color: Colors.white),
                  ),
                  child: Icon(Icons.bookmark)),
              label: t.bookmarksnav),
          BottomNavigationBarItem(icon: Icon(Icons.radio), label: t.radionav),
        ].toList(),
      ),
      drawer: Container(
        color: MyColors.grey_95,
        width: 350,
        child: Drawer(
          key: scaffoldKey,
          child: DrawerScreen(),
        ),
      ),
    );
  }
}
