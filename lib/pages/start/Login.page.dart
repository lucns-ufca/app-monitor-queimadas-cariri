// Developed by @lucns

import 'dart:convert';
import 'dart:ui';

import 'package:app_monitor_queimadas/api/Api.dart';
import 'package:app_monitor_queimadas/models/user.model.dart';
import 'package:app_monitor_queimadas/pages/content/MainScreen.page.dart';
import 'package:app_monitor_queimadas/pages/dialogs/BasicDialogs.dart';
import 'package:app_monitor_queimadas/pages/start/ForgottenPassword.page.dart';
import 'package:app_monitor_queimadas/pages/start/NewAccount.page.dart';
import 'package:app_monitor_queimadas/repositories/Auth.repository.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:app_monitor_queimadas/utils/Constants.dart';
import 'package:app_monitor_queimadas/utils/Utils.dart';
import 'package:app_monitor_queimadas/widgets/Button.dart';
import 'package:app_monitor_queimadas/widgets/ButtonTransparent.dart';
import 'package:app_monitor_queimadas/widgets/ContainerGradient.widget.dart';
import 'package:app_monitor_queimadas/widgets/DynamicWidgetOpacity.widget.dart';
import 'package:app_monitor_queimadas/widgets/ImageTransitionScroller.widget.dart';
import 'package:app_monitor_queimadas/widgets/TextField.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        resizeToAvoidBottomInset: false,
        body: ContainerGradient(colors: const [
          Color.fromARGB(255, 55, 255, 195),
          Color.fromARGB(255, 55, 102, 255),
          Color.fromARGB(255, 55, 102, 255),
          Color.fromARGB(255, 55, 255, 195),
        ], duration: Duration(seconds: 30), child: LoginForm()));
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

  @override
  void initState() {
    textUser = preferences.getString("user") ?? "";
    super.initState();
  }

  void signInWithGoogle() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    User user = User();
    if (googleUser == null) {
      return;
    } else {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      user.name = googleUser.displayName ?? "";
      user.email = googleUser.email;
      user.id = googleUser.id;
      user.photoUrl = googleUser.photoUrl ?? "";
      user.accessToken = googleAuth.accessToken ?? "";
    }
    AuthRepository authRepository = AuthRepository();
    if (user.email.isNotEmpty) {
      ApiResponse response = await authRepository.getUserType(user.email);
      if (response.isOk()) {
        Map<String, dynamic> map = jsonDecode(response.data);
        user.setUSerType(map['user_type']);
      }
    }

    await user.storeData();
    GetIt.instance.registerLazySingleton<User>(() => user);
    openTabsPage();
  }

  void openTabsPage() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreenPage()));
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    return Column(mainAxisSize: MainAxisSize.max, children: [
      Container(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 24),
            const Text("Acesso",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const SizedBox(
                width: double.maxFinite,
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(" ",
                      style: TextStyle(
                        color: AppColors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.left),
                )),
            const SizedBox(height: 8),
            MyFieldText(
                text: preferences.getString("user") ?? "",
                onInput: (value) {
                  setState(() {
                    textUser = value;
                  });
                },
                hintText: "Usuário",
                action: TextInputAction.next,
                // inputFormatters: [CpfFormatter()],
                inputType: TextInputType.text),
            const SizedBox(height: 16),
            MyFieldText(
                onInput: (value) {
                  setState(() {
                    textPassword = value;
                  });
                },
                hintText: "Senha",
                action: TextInputAction.done,
                inputType: TextInputType.visiblePassword),
            const SizedBox(height: 8),
            SizedBox(
                width: double.maxFinite,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8),
                  child: GestureDetector(
                    child: const Text("Esqueci minha senha", style: TextStyle(color: AppColors.textNormal)),
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ForgottenPasswordPage()));
                      //await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ForgottenPasswordPage()));
                    },
                  ),
                )),
            const SizedBox(height: 20),
            MyButton(
              onClick: textUser == null || textUser!.length < 4 || textPassword == null || textPassword!.length < 4
                  ? null
                  : () async {
                      Utils.changeBarsColors(true, true, Brightness.light, Brightness.light);
                      preferences.setString("user", textUser!);
                      FocusManager.instance.primaryFocus?.unfocus(); // hide keyboard

                      Dialogs dialogs = Dialogs(context);
                      dialogs.showIndeterminateDialog("Acessando...");
                      ApiResponse response = await AuthRepository().login(User(email: textUser!, password: textPassword!));
                      dialogs.dismiss();
                      Utils.changeBarsColors(false, true, Brightness.light, Brightness.light);
                      Utils.vibrate();

                      if (response.isOk()) {
                        await navigator.pushReplacement(MaterialPageRoute(builder: (context) => MainScreenPage()));
                        return;
                      }
                      Utils.showSnackbarError(context, response.message!);
                    },
              textButton: "Acessar",
            ),
            const SizedBox(height: 16),
            MyButtonTransparent(
                onClick: () async {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NewAccountPage()));
                  //await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NewAccountPage()));
                },
                text: "Primeiro acesso"),
            const SizedBox(height: 24),
            Divider(indent: 16, endIndent: 16, color: Colors.white.withOpacity(0.5), thickness: 1),
            const SizedBox(height: 24),
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
                ])),
          ])),
      const ImageTransitionScroller(duration: Duration(seconds: 20), assets: "assets/images/minimal_forest2.png", width: 637, height: 222),
      Expanded(
          child: Container(
              width: double.maxFinite,
              color: AppColors.appBackground,
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    DynamicWidgetOpacity(opacityStart: 1, opacityEnd: 0.5, duration: const Duration(milliseconds: 2500), child: const Image(image: ResizeImage(AssetImage('assets/images/ufca_white.png'), width: 105, height: 33))),
                    const SizedBox(
                      height: 16,
                    ),
                    const Text("MONITOR DE QUEIMADAS VERSAO ${Constants.APP_VERSION}", style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: "MontBlancLight")),
                    const SizedBox(
                      height: 32,
                    ),
                  ]))))
    ]);
  }
}
