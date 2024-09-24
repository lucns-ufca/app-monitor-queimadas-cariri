import 'package:app_monitor_queimadas/api/Api.dart';
import 'package:app_monitor_queimadas/models/User.model.dart';
import 'package:app_monitor_queimadas/pages/content/MainScreen.page.dart';
import 'package:app_monitor_queimadas/pages/dialogs/BasicDialogs.dart';
import 'package:app_monitor_queimadas/repositories/Auth.repository.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:app_monitor_queimadas/utils/Notify.dart';
import 'package:app_monitor_queimadas/utils/Utils.dart';
import 'package:app_monitor_queimadas/widgets/Button.dart';
import 'package:app_monitor_queimadas/widgets/ButtonTransparent.dart';
import 'package:app_monitor_queimadas/widgets/TextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginTab extends StatefulWidget {
  final Function() scrollToNewAccount;
  const LoginTab({required this.scrollToNewAccount, super.key});

  @override
  State<StatefulWidget> createState() => LoginTabState();
}

class LoginTabState extends State<LoginTab> {
  var preferences = GetIt.I.get<SharedPreferences>();
  String? textUser, textPassword;
  NavigatorState? navigator;

  @override
  void initState() {
    textUser = preferences.getString("user") ?? "";
    navigator = Navigator.of(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.58,
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
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z.@]"))],
              text: textUser,
              onInput: (value) {
                bool wasValid = isUserValid() && isPasswordValid();
                textUser = value;
                if (wasValid || isUserValid()) setState(() {});
              },
              hintText: "E-mail",
              action: TextInputAction.next,
              // inputFormatters: [CpfFormatter()],
              inputType: TextInputType.text),
          const SizedBox(height: 16),
          MyFieldText(
              onInput: (value) {
                bool wasValid = isUserValid() && isPasswordValid();
                textPassword = value;
                if (wasValid || isPasswordValid()) setState(() {});
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
                    Utils.vibrate();
                    Notify.showToast("Não implementada ainda.");
                    //await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ForgottenPasswordPage()));
                    //await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ForgottenPasswordPage()));
                  },
                ),
              )),
          const SizedBox(height: 20),
          MyButton(
            onClick: isUserValid() && isPasswordValid()
                ? () async {
                    preferences.setString("user", textUser!);
                    FocusManager.instance.primaryFocus?.unfocus(); // hide keyboard

                    Dialogs dialogs = Dialogs(context);
                    dialogs.showIndeterminateDialog("Acessando...");
                    ApiResponse response = await AuthRepository().login(User(email: textUser!, password: textPassword!));
                    dialogs.dismiss();
                    Utils.vibrate();

                    if (response.isOk()) {
                      await navigator!.pushReplacement(MaterialPageRoute(builder: (context) => MainScreenPage()));
                      return;
                    }
                    Utils.showSnackbarError(context, response.message!);
                  }
                : null,
            textButton: "Acessar",
          ),
          const SizedBox(height: 16),
          MyButtonTransparent(onClick: () => widget.scrollToNewAccount(), text: "Primeiro acesso"),
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
