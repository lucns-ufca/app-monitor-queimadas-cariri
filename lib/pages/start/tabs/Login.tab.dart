import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:monitor_queimadas_cariri/api/Controller.api.dart';
import 'package:monitor_queimadas_cariri/firebase/MessagingReceiver.firebase.dart';
import 'package:monitor_queimadas_cariri/models/User.model.dart';
import 'package:monitor_queimadas_cariri/pages/content/MainScreen.page.dart';
import 'package:monitor_queimadas_cariri/pages/dialogs/BasicDialogs.dart';
import 'package:monitor_queimadas_cariri/repositories/Auth.repository.dart';
import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:monitor_queimadas_cariri/utils/Constants.dart';
import 'package:monitor_queimadas_cariri/utils/Notify.dart';
import 'package:monitor_queimadas_cariri/utils/Utils.dart';
import 'package:monitor_queimadas_cariri/widgets/Button.dart';
import 'package:monitor_queimadas_cariri/widgets/ButtonTransparent.dart';
import 'package:monitor_queimadas_cariri/widgets/TextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginTab extends StatefulWidget {
  final Function() scrollToNewAccount;
  const LoginTab({required this.scrollToNewAccount, super.key});

  @override
  State<StatefulWidget> createState() => LoginTabState();
}

class LoginTabState extends State<LoginTab> {
  final User user = GetIt.I.get<User>();
  SharedPreferences? preferences;
  String? textUser, textPassword;
  NavigatorState? navigator;

  void initializePreferences() async {
    preferences = await SharedPreferences.getInstance();
    textUser = preferences!.getString("user") ?? "";
  }

  @override
  void initState() {
    initializePreferences();
    navigator = Navigator.of(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    preferences!.setString("user", textUser!);
                    FocusManager.instance.primaryFocus?.unfocus(); // hide keyboard

                    Dialogs dialogs = Dialogs(context);
                    dialogs.showIndeterminateDialog("Acessando...");
                    Response? response = await AuthRepository().login(textUser!, textPassword!);
                    dialogs.dismiss();
                    Utils.vibrate();

                    if (response != null && response.statusCode != null) {
                      switch (response.statusCode) {
                        case ApiResponseCodes.OK:
                          if (user.isAdminstrator()) {
                            await dialogs.showDialogInfo("Você é um administrador do sistema.", "Com este privilégio você poderá acessar partes delicadas do app, como por exemplo, a área de validações de alertas de queimadas e outros futuros recursos.",
                                positiveText: "Entendi");
                            FirebaseMessagingReceiver messaging = FirebaseMessagingReceiver();
                            await messaging.subscribeTopic(Constants.FCM_TOPIC_ALERT_FIRE);
                          }
                          await navigator!.pushReplacement(MaterialPageRoute(builder: (context) => const MainScreenPage()));
                          break;
                        case ApiResponseCodes.UNAUTHORIZED:
                          Notify.showSnackbarError("Usuario ou senha inválidos!");
                          break;
                        default:
                          Notify.showSnackbarError("Ocorreu um erro desconhecido!");
                          break;
                      }
                    }
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
      if (textUser!.lastIndexOf(".") < textUser!.lastIndexOf("@")) return false;
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
