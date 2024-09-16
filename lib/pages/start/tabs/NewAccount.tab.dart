import 'package:app_monitor_queimadas/api/Api.dart';
import 'package:app_monitor_queimadas/models/User.model.dart';
import 'package:app_monitor_queimadas/pages/dialogs/BasicDialogs.dart';
import 'package:app_monitor_queimadas/repositories/Auth.repository.dart';
import 'package:app_monitor_queimadas/utils/Notify.dart';
import 'package:app_monitor_queimadas/utils/Utils.dart';
import 'package:app_monitor_queimadas/widgets/Button.dart';
import 'package:app_monitor_queimadas/widgets/TextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewAccountTab extends StatefulWidget {
  final Function(String) scrollToLogin;
  const NewAccountTab({required this.scrollToLogin, super.key});

  @override
  State<StatefulWidget> createState() => NewAccountTabState();
}

class NewAccountTabState extends State<NewAccountTab> {
  var preferences = GetIt.I.get<SharedPreferences>();
  String? textName, textUser, textPassword;
  NavigatorState? navigator;

  @override
  void initState() {
    navigator = Navigator.of(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Text("Nova Conta",
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center),
          const SizedBox(height: 32),
          MyFieldText(
              hintText: "Nome e Sobrenome",
              textCapitalization: TextCapitalization.words,
              action: TextInputAction.next,
              inputType: TextInputType.text,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))],
              onInput: (text) {
                setState(() {
                  textName = text;
                });
              }),
          const SizedBox(
            height: 16,
          ),
          MyFieldText(
            hintText: "E-mail",
            action: TextInputAction.next,
            //inputFormatters: [CpfFormatter()],
            inputType: TextInputType.text,
            onInput: (value) {
              bool wasValid = isNameValid() && isUserValid() && isPasswordValid();
              textUser = value;
              if (wasValid || isUserValid()) setState(() {});
            },
          ),
          const SizedBox(height: 16),
          MyFieldText(
            hintText: "Senha",
            action: TextInputAction.done,
            inputType: TextInputType.visiblePassword,
            onInput: (value) {
              bool wasValid = isNameValid() && isUserValid() && isPasswordValid();
              textPassword = value;
              if (wasValid || isPasswordValid()) setState(() {});
            },
          ),
          const SizedBox(height: 20),
          MyButton(
              textButton: "Criar conta",
              onClick: !isNameValid() || !isPasswordValid() || !isUserValid()
                  ? null
                  : () async {
                      preferences.setString("user", textUser!);
                      FocusManager.instance.primaryFocus?.unfocus(); // hide keyboard

                      Dialogs dialogs = Dialogs(context);
                      dialogs.showIndeterminateDialog("Criando conta...");
                      //await Future.delayed(const Duration(seconds: 3));
                      ApiResponse response = await AuthRepository().createAccount(User(name: textName!, email: textUser!, password: textPassword!));
                      dialogs.dismiss();
                      Utils.vibrate();
                      if (response.isOk()) {
                        Notify.showToast("Conta criada.");
                        widget.scrollToLogin(textUser!);
                        return;
                      }
                      Utils.showSnackbarError(context, response.message!);
                    }),
        ],
      ),
    );
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

  bool isNameValid() {
    return textName != null && textName!.length > 4;
  }
}
