import 'package:flutter/material.dart';
import 'package:newsextra/screens/CategoriesScreen.dart';
import 'package:newsextra/screens/SourcesScreen.dart';
import 'package:provider/provider.dart';
import '../screens/LoginScreen.dart';
import '../models/Userdata.dart';
import 'package:flutter/cupertino.dart';
import '../providers/AppStateNotifier.dart';
import '../utils/TextStyles.dart';
import '../utils/my_colors.dart';
import '../utils/StringsUtils.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import '../i18n/strings.g.dart';
import '../utils/langs.dart';

class DrawerScreen extends StatefulWidget {
  DrawerScreen({Key? key}) : super(key: key);

  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  late var appState;

  Future<void> showLogoutAlert() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: new Text(t.logoutfromapp),
              content: new Text(t.logoutfromapphint),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: false,
                  child: Text(t.ok),
                  onPressed: () {
                    Navigator.of(context).pop();
                    appState.unsetUserData();
                    _handleSignOut();
                  },
                ),
                CupertinoDialogAction(
                  isDefaultAction: false,
                  child: Text(t.cancel),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  Future<void> _handleSignOut() async {
    try {
      await googleSignIn.signOut();
    } catch (error) {
      print(error);
    }
  }

  openBrowserTab(String url) async {
    await FlutterWebBrowser.openWebPage(
      url: url,
      customTabsOptions: CustomTabsOptions(
        colorScheme: CustomTabsColorScheme.dark,
        toolbarColor: MyColors.primary,
        secondaryToolbarColor: MyColors.primary,
        navigationBarColor: MyColors.primary,
        addDefaultShareMenuItem: true,
        instantAppsEnabled: true,
        showTitle: true,
        urlBarHidingEnabled: true,
      ),
      safariVCOptions: SafariViewControllerOptions(
        barCollapsingEnabled: true,
        preferredBarTintColor: MyColors.primary,
        preferredControlTintColor: MyColors.primary,
        dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        modalPresentationCapturesStatusBarAppearance: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppStateNotifier>(context);
    Userdata? userdata = appState.userdata;
    String language = appLanguageData[
        AppLanguage.values[appState.preferredLanguage]]!['value']!;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              color: MyColors.primary,
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Text(
                      userdata == null
                          ? t.guestuser.substring(0, 1)
                          : userdata.name!.substring(0, 1),
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  Container(height: 10),
                  Text(userdata == null ? t.guestuser : userdata.name!,
                      style: TextStyles.title(context)
                          .copyWith(color: Colors.white, fontSize: 17)),
                  Container(height: 5),
                  userdata != null
                      ? Text(userdata.email!,
                          style: TextStyles.subhead(context)
                              .copyWith(color: MyColors.grey_10, fontSize: 13))
                      : Container(),
                  Container(
                    height: 12,
                  ),
                  SizedBox(
                    height: 30,
                    width: 150,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Colors.white,
                                width: 1,
                                style: BorderStyle.solid),
                            borderRadius: new BorderRadius.circular(10)),
                      ),
                      child: Text(
                        userdata != null ? t.logout : t.login,
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        if (userdata != null) {
                          showLogoutAlert();
                        } else {
                          Navigator.pushNamed(context, LoginScreen.routeName);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 15),
            Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(height: 10),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, CategoriesScreen.routeName);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.category,
                              size: 20.0, color: Colors.blue[500]),
                          Container(width: 10),
                          Text(t.categories,
                              style: TextStyles.subhead(context).copyWith(
                                fontSize: 15,
                              )),
                          Spacer(),
                          Icon(Icons.navigate_next,
                              size: 25.0, color: Colors.blue[500]),
                        ],
                      ),
                    ),
                  ),
                  Container(height: 15),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, SourcesScreen.routeName);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.source,
                              size: 20.0, color: Colors.blue[500]),
                          Container(width: 10),
                          Text(t.feedsources,
                              style: TextStyles.subhead(context).copyWith(
                                fontSize: 15,
                              )),
                          Spacer(),
                          Icon(Icons.navigate_next,
                              size: 25.0, color: Colors.blue[500]),
                        ],
                      ),
                    ),
                  ),
                  Container(height: 15),
                  Divider(height: 1, color: Colors.grey),
                  Container(height: 15),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.color_lens,
                              size: 20.0, color: Colors.yellow[800]),
                          Container(width: 10),
                          Text(t.nightmode,
                              style: TextStyles.subhead(context).copyWith(
                                fontSize: 15,
                              )),
                          Spacer(),
                          Switch(
                            value: appState.isDarkModeOn,
                            onChanged: (value) {
                              appState.setAppTheme(value);
                            },
                            activeColor: MyColors.primary,
                            inactiveThumbColor: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.notifications,
                              size: 20.0, color: Colors.blue[500]),
                          Container(width: 10),
                          Text(t.receievepshnotifications,
                              style: TextStyles.subhead(context).copyWith(
                                fontSize: 15,
                              )),
                          Spacer(),
                          Switch(
                            value: appState.isReceievePushNotifications,
                            onChanged: (value) {
                              appState.setRecieveNotifications(value);
                            },
                            activeColor: MyColors.primary,
                            inactiveThumbColor: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.image,
                              size: 20.0, color: Colors.blue[500]),
                          Container(width: 10),
                          Text(t.showarticleimages,
                              style: TextStyles.subhead(context).copyWith(
                                fontSize: 15,
                              )),
                          Spacer(),
                          Switch(
                            value: appState.loadArticlesImages,
                            onChanged: (value) {
                              appState.setLoadArticlesImages(value);
                            },
                            activeColor: MyColors.primary,
                            inactiveThumbColor: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  appState.loadArticlesImages
                      ? InkWell(
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 2),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.photo_size_select_small,
                                    size: 20.0, color: Colors.blue[500]),
                                Container(width: 10),
                                Text(t.showsmallarticleimages,
                                    style: TextStyles.subhead(context).copyWith(
                                      fontSize: 15,
                                    )),
                                Spacer(),
                                Switch(
                                  value: appState.loadSmallImages,
                                  onChanged: (value) {
                                    appState.setLoadSmallImages(value);
                                  },
                                  activeColor: MyColors.primary,
                                  inactiveThumbColor: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(),
                  Visibility(
                    visible: true,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.language,
                                size: 20.0, color: Colors.blue[500]),
                            Container(width: 10),
                            Text(t.enablertl,
                                style: TextStyles.subhead(context).copyWith(
                                  fontSize: 15,
                                )),
                            Spacer(),
                            Switch(
                              value: appState.isRtlEnabled,
                              onChanged: (value) {
                                appState.setRtlEnabled(value);
                              },
                              activeColor: MyColors.primary,
                              inactiveThumbColor: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(height: 8),
                  InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              scrollable: true,
                              title: Container(
                                  height: 30,
                                  width: 180,
                                  child: Text(t.chooseapplanguage,
                                      style: TextStyles.subhead(context))),
                              content: Container(
                                height: 250.0,
                                width: 400.0,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: appLanguageData.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    var selected = appLanguageData[AppLanguage
                                            .values[index]]!['value'] ==
                                        language;
                                    return ListTile(
                                      trailing: selected
                                          ? Icon(Icons.check)
                                          : Container(
                                              height: 0,
                                              width: 0,
                                            ),
                                      title: Text(
                                        appLanguageData[AppLanguage
                                            .values[index]]!['name']!,
                                      ),
                                      onTap: () {
                                        appState.setAppLanguage(index);
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  },
                                ),
                              ),
                            );
                          });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.language,
                            size: 20.0,
                            color: Colors.blue[300],
                          ),
                          Container(width: 10),
                          Expanded(
                            child: Text(t.selectlanguage,
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: TextStyles.subhead(context).copyWith(
                                  fontSize: 15,
                                )),
                          ),
                          Container(width: 10),
                          Text(
                            language,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: TextStyles.subhead(context)
                                .copyWith(fontSize: 13),
                          ),
                          Container(width: 10)
                        ],
                      ),
                    ),
                  ),
                  Container(height: 20),
                  Divider(height: 1, color: Colors.grey),
                  Container(height: 10),
                  InkWell(
                    onTap: () {
                      openBrowserTab(StringsUtils.ABOUT);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.info, size: 20.0, color: Colors.blue[500]),
                          Container(width: 10),
                          Text(t.about,
                              style: TextStyles.subhead(context).copyWith(
                                fontSize: 15,
                              )),
                          Spacer(),
                          Icon(Icons.navigate_next,
                              size: 25.0, color: Colors.blue[500]),
                        ],
                      ),
                    ),
                  ),
                  Container(height: 10),
                  InkWell(
                    onTap: () {
                      openBrowserTab(StringsUtils.TERMS);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.chrome_reader_mode,
                              size: 20.0, color: Colors.blue[500]),
                          Container(width: 10),
                          Text(t.terms,
                              style: TextStyles.subhead(context).copyWith(
                                fontSize: 15,
                              )),
                          Spacer(),
                          Icon(Icons.navigate_next,
                              size: 25.0, color: Colors.blue[500]),
                        ],
                      ),
                    ),
                  ),
                  Container(height: 10),
                  InkWell(
                    onTap: () {
                      openBrowserTab(StringsUtils.PRIVACY);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.label_important,
                              size: 20.0, color: Colors.blue[500]),
                          Container(width: 10),
                          Text(t.privacy,
                              style: TextStyles.subhead(context).copyWith(
                                fontSize: 15,
                              )),
                          Spacer(),
                          Icon(Icons.navigate_next,
                              size: 25.0, color: Colors.blue[500]),
                        ],
                      ),
                    ),
                  ),
                  Container(height: 10),
                ],
              ),
            ),
            Container(height: 0),
          ],
        ),
      ),
    );
  }
}
