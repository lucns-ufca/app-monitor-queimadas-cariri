// Developed by @lucns
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:monitor_queimadas_cariri/models/User.model.dart';
import 'package:monitor_queimadas_cariri/pages/content/MainScreen.page.dart';
import 'package:monitor_queimadas_cariri/pages/start/tabs/Login.tab.dart';
import 'package:monitor_queimadas_cariri/pages/start/tabs/NewAccount.tab.dart';
import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:monitor_queimadas_cariri/widgets/AppLogos.widget.dart';
import 'package:monitor_queimadas_cariri/widgets/ContainerGradient.widget.dart';
import 'package:monitor_queimadas_cariri/widgets/ExpandablePageView.widget.dart';
import 'package:monitor_queimadas_cariri/widgets/ImageTransitionScroller.widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessPage extends StatefulWidget {
  const AccessPage({super.key});

  @override
  AccessPageState createState() => AccessPageState();
}

class AccessPageState extends State<AccessPage> with WidgetsBindingObserver {
  bool loading = false;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: AppColors.appBackground,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: ContainerGradient(colors: AppColors.gradientSky, duration: Duration(seconds: 30), child: LoginForm()));
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<StatefulWidget> createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  var preferences = GetIt.I.get<SharedPreferences>();
  String? textUser, textPassword;
  PageController pageController = PageController();
  int page = 0;

  @override
  void initState() {
    textUser = preferences.getString("user") ?? "";
    super.initState();
  }

  void signInWithGoogle() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;
    User user = User();
    user.name = googleUser.displayName ?? "";
    user.email = googleUser.email;
    user.id = googleUser.id;
    user.photoUrl = googleUser.photoUrl ?? "";
    /*
    try { // dando problema no firebase
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      user.accessToken = googleAuth.accessToken ?? "";
    } catch (e, stacktrace) {
      print(stacktrace);
    }
    */

    /*
    if (user.email.isNotEmpty) {
      AuthRepository authRepository = AuthRepository();
      ApiResponse response = await authRepository.getUserType(user.email);
      if (response.isOk()) {
        Map<String, dynamic> map = jsonDecode(response.data);
        user.setUSerType(map['user_type']);
      }
      */

    await user.storeData();
    openTabsPage();
  }

  void openTabsPage() async {
    await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreenPage()));
  }

  @override
  Widget build(BuildContext context) {
    double imageWidth = MediaQuery.of(context).size.width * 1.55;
    return PopScope(
        canPop: page == 0,
        onPopInvoked: (a) async {
          if (page == 1) {
            pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
            return;
          }
        },
        child: Stack(children: [
          Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const SizedBox(),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Container(transform: Matrix4.translationValues(0, 2, 0), child: ImageTransitionScroller(duration: const Duration(seconds: 20), assets: "assets/images/minimal_forest2.png", width: imageWidth, height: imageWidth / 2.87)),
              Container(height: MediaQuery.of(context).size.height * 0.2, width: double.maxFinite, color: AppColors.appBackground, child: const Align(alignment: Alignment.bottomCenter, child: AppLogos(showAppLogo: true)))
            ])
          ]),
          Column(mainAxisSize: MainAxisSize.min, children: [
            ExpandablePageView(onPageChanged: (index) => setState(() => page = index), physics: const NeverScrollableScrollPhysics(), pageController: pageController, children: [
              LoginTab(scrollToNewAccount: () {
                pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
              }),
              NewAccountTab(scrollToLogin: (email) {
                setState(() {
                  textUser = email;
                });
                pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
              }),
              //Container(height: 300, color: Colors.green),
            ]),
            const SizedBox(height: 8),
            Divider(height: 1, indent: 24, endIndent: 24, color: Colors.white.withOpacity(0.5), thickness: 1),
            const SizedBox(height: 36),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(AppColors.fragmentBackground),
                    overlayColor: WidgetStateProperty.all<Color>(Colors.white.withOpacity(0.5)),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: const BorderSide(color: Colors.transparent)))),
                onPressed: () => signInWithGoogle(),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Stack(children: [
                    Opacity(opacity: 0.5, child: Image.asset("assets/images/google_logo.webp", width: 24, height: 24, color: Colors.black)),
                    ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1), child: Image.asset("assets/images/google_logo.webp", width: 24, height: 24)))
                  ]),
                  const SizedBox(width: 8),
                  const Text("Entrar com a Google", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500))
                ]))
          ])
        ]));
  }

  bool isUserValid() {
    if (textUser != null && textUser!.contains("@") && textUser!.contains(".") && !textUser!.endsWith("@") && !textUser!.endsWith(".")) {
      String before = textUser!.substring(0, textUser!.indexOf("@"));
      String center = textUser!.substring(textUser!.lastIndexOf("@") + 1, textUser!.lastIndexOf("."));
      String after = textUser!.substring(textUser!.lastIndexOf(".") + 1, textUser!.length);
      return before.length > 1 && center.length > 1 && after.length > 1;
    }
    return false;
  }

  bool isPasswordValid() {
    return textPassword != null && textPassword!.length > 3;
  }
}
