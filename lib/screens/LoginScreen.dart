import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:newsextra/utils/my_colors.dart';
import 'package:sign_in_apple/apple_id_user.dart';
import 'package:sign_in_apple/sign_in_apple.dart';
import '../utils/img.dart';
import 'package:provider/provider.dart';
import '../providers/AppStateNotifier.dart';
import '../i18n/strings.g.dart';
import 'dart:io';
import '../screens/ForgotPasswordScreen.dart';
import '../screens/RegisterScreen.dart';
import '../utils/Alerts.dart';
import 'dart:convert';
import 'dart:async';
import '../utils/ApiUrl.dart';
import 'package:http/http.dart' as http;
import 'package:email_validator/email_validator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/Userdata.dart';
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: [
    'email',
  ],
);

class LoginScreen extends StatefulWidget {
  static const routeName = "/login";
  LoginScreen();

  @override
  LoginScreenRouteState createState() => new LoginScreenRouteState();
}

class LoginScreenRouteState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  GoogleSignInAccount? _currentUser;
  final fb = FacebookLogin();

  Future<void> _handleSignIn() async {
    try {
      await googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  verifyFormAndSubmit() {
    String _email = emailController.text;
    String _password = passwordController.text;

    if (_email == "" || _password == "") {
      Alerts.show(context, t.error, t.emptyfielderrorhint);
    } else if (EmailValidator.validate(_email) == false) {
      Alerts.show(context, t.error, t.invalidemailerrorhint);
    } else {
      loginUser(_email, _password, "", "");
    }
  }

  Future<void> loginUser(
      String? email, String password, String? name, String type) async {
    Alerts.showProgressDialog(context, t.processingpleasewait);
    try {
      var data = {
        "email": email,
        "password": password,
      };
      if (type != "") {
        data = {
          "email": email,
          "password": password,
          "name": name,
          "type": type
        };
      }
      final response = await http.post(Uri.parse(ApiUrl.LOGIN),
          body: jsonEncode({"data": data}));
      if (response.statusCode == 200) {
        // Navigator.pop(context);
        // If the server did return a 200 OK response,
        // then parse the JSON.
        Navigator.of(context).pop();
        print(response.body);
        Map<String, dynamic> res = json.decode(response.body);
        if (res["status"] == "error") {
          Alerts.show(context, t.error, res["message"]);
        } else {
          print(res["user"]);
          //Alerts.show(context, Strings.success, res["message"]);
          Provider.of<AppStateNotifier>(context, listen: false)
              .setUserData(Userdata.fromJson(res["user"]));
          Navigator.of(context).pop();
        }
        //print(res);
      }
    } catch (exception) {
      // Navigator.pop(context);
      // I get no exception here
      print(exception);
    }
  }

  Future<Null> loginWithFacebook() async {
    await fb.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);
    await _updateLoginInfo();
  }

  Future<void> _updateLoginInfo() async {
    final token = await fb.accessToken;
    FacebookUserProfile? profile;

    if (token != null) {
      profile = await fb.getUserProfile();
      if (token.permissions.contains(FacebookPermission.email.name)) {
        String? email = await fb.getUserEmail();
        loginUser(email, "", profile!.name, t.facebook);
      } else {
        Alerts.showToast(
            context, t.facebook + ': Failed to get email permissions');
      }
    } else {
      Alerts.showToast(context, t.facebook + ': Failed to get user details');
    }
  }

  Future<void> initPlatformState() async {
    SignInApple.handleAppleSignInCallBack(
        onCompleteWithSignIn: (AppleIdUser user) async {
      print("flutter receiveCode: \n");
      print(user.authorizationCode);
      print("flutter receiveToken \n");
      print(user.identifyToken);

      if (user.mail != null || user.mail != "") {
        loginUser(user.mail ?? "Apple User", "", user.name ?? "", "Apple");
      }
    }, onCompleteWithError: (AppleSignInErrorCode code) async {
      var errorMsg = "unknown";
      switch (code) {
        case AppleSignInErrorCode.canceled:
          errorMsg = "user canceled request";
          break;
        case AppleSignInErrorCode.failed:
          errorMsg = "request fail";
          break;
        case AppleSignInErrorCode.invalidResponse:
          errorMsg = "request invalid response";
          break;
        case AppleSignInErrorCode.notHandled:
          errorMsg = "request not handled";
          break;
        case AppleSignInErrorCode.unknown:
          errorMsg = "request fail unknown";
          break;
      }
      print(errorMsg);
    });
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      //check for ios if developing for both android & ios
      initPlatformState();
    }
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        // _handleGetContact();
        print(_currentUser!.email);
        loginUser(_currentUser!.email, "", _currentUser!.displayName, "Google");
      }
    });
    googleSignIn.signInSilently();
    //_googleSignIn.signOut();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.primary,
      resizeToAvoidBottomInset: true,
      // backgroundColor: Colors.white,
      appBar:
          PreferredSize(child: Container(), preferredSize: Size.fromHeight(0)),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            Container(
              height: 250,
              width: double.infinity,
              child: Image.asset(Img.get("world_map.png")),
            ),
            Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                    width: double.infinity,
                    height: double.infinity,
                    child: ListView(
                      children: <Widget>[
                        Container(height: 0),
                        Container(
                          child: Center(
                              child: Text(
                            t.appname,
                            style: TextStyle(color: Colors.white, fontSize: 26),
                          )),
                          width: double.infinity,
                          height: 100,
                        ),
                        Container(height: 0),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.text,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: t.emailaddress,
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                        Container(height: 25),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          keyboardType: TextInputType.text,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: t.password,
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                        Container(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            TextButton(
                              child: Text(
                                t.createaccount,
                                style: TextStyle(color: Colors.white),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.transparent,
                              ),
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, RegisterScreen.routeName);
                              },
                            ),
                            Container(height: 5),
                            TextButton(
                              child: Text(
                                t.forgotpassword,
                                style: TextStyle(color: Colors.white),
                              ),
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.transparent),
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, ForgotPasswordScreen.routeName);
                              },
                            )
                          ],
                        ),
                        Container(height: 15),
                        Container(
                          width: double.infinity,
                          height: 40,
                          child: TextButton(
                            child: Text(
                              t.login,
                              style: TextStyle(color: MyColors.primary),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(20)),
                            ),
                            onPressed: () {
                              verifyFormAndSubmit();
                            },
                          ),
                        ),
                        Container(height: 40),
                        Center(
                          child: Text(
                            t.orloginwith,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Container(height: 15),
                        Column(
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                icon: FaIcon(
                                  FontAwesomeIcons.facebook,
                                  color: Colors.blue,
                                  size: 20,
                                ), //`Icon` to display
                                label: Text(
                                  t.facebook,
                                  style: TextStyle(color: Colors.blue),
                                ), //`Text` to display
                                onPressed: () {
                                  loginWithFacebook();
                                },
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                icon: FaIcon(
                                  FontAwesomeIcons.google,
                                  color: MyColors.primary,
                                  size: 20,
                                ), //`Icon` to display
                                label: Text(
                                  t.google,
                                  style: TextStyle(color: MyColors.primary),
                                ), //`Text` to display
                                onPressed: () {
                                  _handleSignIn();
                                },
                              ),
                            ),
                            Visibility(
                              visible: Platform.isIOS ? true : false,
                              child: Container(
                                width: double.infinity,
                                child: AppleSignInSystemButton(
                                  width: 250,
                                  height: 50,
                                  buttonStyle:
                                      AppleSignInSystemButtonStyle.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(height: 15),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          t.skiplogin,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
