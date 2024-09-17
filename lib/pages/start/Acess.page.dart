// Developed by @lucns

import 'dart:convert';
import 'dart:ui';

import 'package:app_monitor_queimadas/api/Api.dart';
import 'package:app_monitor_queimadas/models/User.model.dart';
import 'package:app_monitor_queimadas/pages/content/MainScreen.page.dart';
import 'package:app_monitor_queimadas/pages/start/tabs/Login.tab.dart';
import 'package:app_monitor_queimadas/pages/start/tabs/NewAccount.tab.dart';
import 'package:app_monitor_queimadas/repositories/Auth.repository.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:app_monitor_queimadas/utils/Constants.dart';
import 'package:app_monitor_queimadas/widgets/ContainerGradient.widget.dart';
import 'package:app_monitor_queimadas/widgets/DynamicWidgetOpacity.widget.dart';
import 'package:app_monitor_queimadas/widgets/ExpandablePageView.widget.dart';
import 'package:app_monitor_queimadas/widgets/ImageTransitionScroller.widget.dart';
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
  Widget build(BuildContext context) {
    return const Scaffold(resizeToAvoidBottomInset: false, body: ContainerGradient(colors: AppColors.gradientSky, duration: Duration(seconds: 30), child: LoginForm()));
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

  @override
  void initState() {
    textUser = preferences.getString("user") ?? "";
    super.initState();
  }

  void signInWithGoogle() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;
    GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
    User user = User();
    user.name = googleUser.displayName ?? "";
    user.email = googleUser.email;
    user.id = googleUser.id;
    user.photoUrl = googleUser.photoUrl ?? "";
    user.accessToken = googleAuth.accessToken ?? "";
    if (user.email.isNotEmpty) {
      AuthRepository authRepository = AuthRepository();
      ApiResponse response = await authRepository.getUserType(user.email);
      if (response.isOk()) {
        Map<String, dynamic> map = jsonDecode(response.data);
        user.setUSerType(map['user_type']);
      }
    }

    await user.storeData();
    openTabsPage();
  }

  void openTabsPage() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreenPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(mainAxisSize: MainAxisSize.max, children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.6),
        const ImageTransitionScroller(duration: Duration(seconds: 20), assets: "assets/images/minimal_forest2.png", width: 637, height: 223),
        Expanded(
            child: Container(
                width: double.maxFinite,
                color: AppColors.appBackground,
                child: const Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      DynamicOpacity(opacityStart: 1, opacityEnd: 0.5, duration: Duration(milliseconds: 2500), child: Image(image: AssetImage('assets/images/ufca_white.png'))),
                      SizedBox(
                        height: 16,
                      ),
                      Text("MONITOR DE QUEIMADAS VERSAO ${Constants.APP_VERSION}", style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: "MontBlancLight")),
                      SizedBox(
                        height: 32,
                      ),
                    ]))))
      ]),
      Column(mainAxisSize: MainAxisSize.min, children: [
        ExpandablePageView(physics: const NeverScrollableScrollPhysics(), pageController: pageController, children: [
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
                backgroundColor: WidgetStateProperty.all<Color>(AppColors.accent),
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
    ]);
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
