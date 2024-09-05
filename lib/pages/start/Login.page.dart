// Developed by @lucns

import 'package:app_monitor_queimadas/api/Api.dart';
import 'package:app_monitor_queimadas/models/user.model.dart';
import 'package:app_monitor_queimadas/pages/start/First.page.dart';
import 'package:app_monitor_queimadas/pages/start/ForgottenPassword.page.dart';
import 'package:app_monitor_queimadas/pages/start/NewAccount.page.dart';
import 'package:app_monitor_queimadas/pages/content/Dashboard.page.dart';
import 'package:app_monitor_queimadas/pages/dialogs/BasicDialogs.dart';
import 'package:app_monitor_queimadas/repositories/Auth.repository.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:app_monitor_queimadas/utils/Constants.dart';
import 'package:app_monitor_queimadas/utils/Utils.dart';
import 'package:app_monitor_queimadas/widgets/Button.dart';
import 'package:app_monitor_queimadas/widgets/ButtonTransparent.dart';
import 'package:app_monitor_queimadas/widgets/ClipShadowPath.dart';
import 'package:app_monitor_queimadas/widgets/TextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  Color formColor = AppColors.fragmentBackground;
  AnimationController? animationController;
  Animation<double>? animation;
  Widget? wallpaperWidget;
  Align? clipper;
  double formHeight = 405;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(systemNavigationBarColor: Colors.transparent, statusBarColor: formColor, statusBarIconBrightness: Brightness.light, systemNavigationBarIconBrightness: Brightness.light));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);

    animationController = AnimationController(vsync: this, duration: const Duration(seconds: 10));
    animation = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.fastEaseInToSlowEaseOut)).animate(animationController!);
    animationController!.forward();

    super.initState();
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    clipper ??= Align(
        alignment: Alignment.topRight,
        child: SizedBox(
            width: Constants.DEFAULT_ROUND_BORDER,
            height: Constants.DEFAULT_ROUND_BORDER,
            child: ClipShadowPath(
              clipper: MyClipper(),
              shadow: const Shadow(offset: Offset(-4, 9), color: AppColors.black, blurRadius: 7),
              child: Container(
                width: double.maxFinite,
                height: Constants.DEFAULT_ROUND_BORDER,
                color: formColor,
              ),
            )));
    return PopScope(
        canPop: false,
        onPopInvoked: (deiPop) async {
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FirstPage()));
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: IntrinsicHeightScrollView(
                child: Stack(
              children: [
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                        width: double.maxFinite,
                        height: (MediaQuery.of(context).size.height - formHeight) + Constants.DEFAULT_ROUND_BORDER,
                        decoration: const BoxDecoration(image: DecorationImage(fit: BoxFit.fitHeight, alignment: FractionalOffset.topCenter, image: AssetImage("assets/images/soldadinho_araripe.jpg"))))),
                Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                        height: formHeight + Constants.DEFAULT_ROUND_BORDER,
                        width: double.maxFinite,
                        child: Column(children: [
                          Container(
                            height: formHeight,
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              color: formColor,
                              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(Constants.DEFAULT_ROUND_BORDER)),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  spreadRadius: 8,
                                  blurRadius: 4,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                            child: const LoginForm(),
                          ),
                          clipper!
                        ]))),
              ],
            ))));
  }
}

final class IntrinsicHeightScrollView extends StatelessWidget {
  const IntrinsicHeightScrollView({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraint.maxHeight),
            child: IntrinsicHeight(
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(size.width - Constants.DEFAULT_ROUND_BORDER, 0);
    path.quadraticBezierTo(size.width, Constants.DEFAULT_ROUND_BORDER / 4, size.width, Constants.DEFAULT_ROUND_BORDER);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    throw UnimplementedError();
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

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 16),
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
                      await navigator.pushReplacement(MaterialPageRoute(builder: (context) => const DashboardPage()));
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
              text: "Primeiro acesso")
        ]));
  }
}
