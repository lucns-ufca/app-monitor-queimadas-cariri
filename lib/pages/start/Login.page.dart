// Developed by @lucns

import 'dart:ui';

import 'package:app_monitor_queimadas/api/Api.dart';
import 'package:app_monitor_queimadas/models/user.model.dart';
import 'package:app_monitor_queimadas/pages/content/MainScreen.page.dart';
import 'package:app_monitor_queimadas/pages/dialogs/BasicDialogs.dart';
import 'package:app_monitor_queimadas/pages/start/First.page.dart';
import 'package:app_monitor_queimadas/pages/start/ForgottenPassword.page.dart';
import 'package:app_monitor_queimadas/pages/start/NewAccount.page.dart';
import 'package:app_monitor_queimadas/repositories/Auth.repository.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:app_monitor_queimadas/utils/Log.out.dart';
import 'package:app_monitor_queimadas/utils/Utils.dart';
import 'package:app_monitor_queimadas/widgets/Button.dart';
import 'package:app_monitor_queimadas/widgets/ButtonTransparent.dart';
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
    return PopScope(
        canPop: !loading,
        onPopInvoked: (didPop) async {
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FirstPage()));
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
                color: AppColors.appBackground,
                child: ImageTransitionScroller(
                  padding: const EdgeInsets.all(24),
                  assets: "assets/images/montains.jpg",
                  repeat: false,
                  duration: const Duration(seconds: 30),
                  color: AppColors.appBackground,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const SizedBox(
                      height: 120,
                    ),
                    Center(child: Container(width: 330, decoration: BoxDecoration(color: AppColors.fragmentBackground, borderRadius: BorderRadius.circular(24)), child: LoginForm())),
                  ]),
                ))));
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<StatefulWidget> createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final user = GetIt.I.get<User>();
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
    if (googleUser == null) {
      Log.d("Lucas", "googleUser is null");
    } else {
      Log.d("Lucas", "name ${googleUser.displayName}"); // LUCAS DO NASCIMENTO SOUZA
      Log.d("Lucas", "email ${googleUser.email}"); // lucas.nascimento@aluno.ufca.edu.br
      Log.d("Lucas", "id ${googleUser.id}"); // 114094787294812174327
      Log.d("Lucas", "photoUrl ${googleUser.photoUrl}"); // 512x512 https://lh3.googleusercontent.com/a/ACg8ocICEMWEybYpDVbVfZzDj70p0ZH6XS-yR4baFdpnRtd5JCT6iVE
    }
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    if (googleAuth == null) {
      Log.d("Lucas", "googleAuth is null");
    } else {
      Log.d("Lucas", "accessToken ${googleAuth.accessToken}"); // ya29.a0AcM612yAm81GcUmMbCDu_KCqy...
      Log.d("Lucas", "idToken ${googleAuth.idToken}"); // null
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FirstPage()));
        },
        child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text("Acesso",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w200,
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
                        await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ForgottenPasswordPage()));
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
                    await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NewAccountPage()));
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
                  ]))
            ])));
  }
}
