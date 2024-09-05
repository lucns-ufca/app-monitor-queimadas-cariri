// Developed by @lucns

import 'package:app_monitor_queimadas/api/Api.dart';
import 'package:app_monitor_queimadas/models/user.model.dart';
import 'package:app_monitor_queimadas/pages/start/Login.page.dart';
import 'package:app_monitor_queimadas/pages/dialogs/BasicDialogs.dart';
import 'package:app_monitor_queimadas/repositories/Auth.repository.dart';
import 'package:app_monitor_queimadas/utils/Notify.dart';
import 'package:app_monitor_queimadas/utils/Constants.dart';
import 'package:app_monitor_queimadas/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_monitor_queimadas/widgets/TextField.dart';
import 'package:app_monitor_queimadas/widgets/Button.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:app_monitor_queimadas/widgets/Toolbar.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:get_it/get_it.dart';

class NewAccountPage extends StatefulWidget {
  const NewAccountPage({Key? key}) : super(key: key);

  @override
  NewAccountPageState createState() => NewAccountPageState();
}

class NewAccountPageState extends State<NewAccountPage> {
  var preferences = GetIt.I.get<SharedPreferences>();
  String? textUsername, textUser, textPassword;

  void showMenuWindow() {}

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(systemNavigationBarColor: Colors.transparent, statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light, systemNavigationBarIconBrightness: Brightness.light));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    return PopScope(
        canPop: false,
        onPopInvoked: (deiPop) async {
          await navigator.pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.appBackground,
          body: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                  fit: BoxFit.fitWidth,
                  alignment: FractionalOffset.topCenter,
                  image: AssetImage("assets/images/araripe_church.jpg"),
                )),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const SizedBox(height: 28),
                  MyToolbar(
                      title: "Nova Conta",
                      onBackPressed: () async {
                        await navigator.pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
                      },
                      onMenuPressed: () {
                        showMenuWindow();
                      })
                ]),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 324,
                    padding: const EdgeInsets.all(24.0),
                    decoration: const BoxDecoration(
                      color: AppColors.fragmentBackground,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(Constants.DEFAULT_ROUND_BORDER), topRight: Radius.circular(Constants.DEFAULT_ROUND_BORDER)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          spreadRadius: 4,
                          blurRadius: 4,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 16,
                        ),
                        const SizedBox(
                            width: double.maxFinite,
                            child: Padding(
                              padding: EdgeInsets.only(left: 16),
                              child: Text("Todos os campos são obrigatorios.", style: TextStyle(color: AppColors.red, fontSize: 14)),
                            )),
                        const SizedBox(height: 16),
                        MyFieldText(
                            hintText: "Nome",
                            textCapitalization: TextCapitalization.words,
                            action: TextInputAction.next,
                            inputType: TextInputType.text,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))],
                            onInput: (text) {
                              setState(() {
                                textUsername = text;
                              });
                            }),
                        const SizedBox(
                          height: 16,
                        ),
                        MyFieldText(
                          hintText: "Usuário",
                          action: TextInputAction.next,
                          //inputFormatters: [CpfFormatter()],
                          inputType: TextInputType.text,
                          onInput: (text) {
                            setState(() {
                              textUser = text;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        MyFieldText(
                          hintText: "Senha",
                          action: TextInputAction.done,
                          inputType: TextInputType.visiblePassword,
                          onInput: (text) {
                            setState(() {
                              textPassword = text;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        MyButton(
                            textButton: "Criar conta",
                            onClick: textUsername == null || textUsername!.length < 4 || textUser == null || textUser!.length < 4 || textPassword == null || textPassword!.length < 4
                                ? null
                                : () async {
                                    preferences.setString("user", textUser!);
                                    FocusManager.instance.primaryFocus?.unfocus(); // hide keyboard

                                    Dialogs dialogs = Dialogs(context);
                                    dialogs.showIndeterminateDialog("Criando conta...");
                                    //await Future.delayed(const Duration(seconds: 3));
                                    ApiResponse response = await AuthRepository().createAccount(User(username: textUsername!, email: textUser!, password: textPassword!));
                                    dialogs.dismiss();
                                    Utils.vibrate();
                                    if (response.isOk()) {
                                      Notify.showToast("Conta criada.");
                                      await navigator.pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
                                      return;
                                    }
                                    Utils.showSnackbarError(context, response.message!);
                                  }),
                        const SizedBox(height: 20),
                        //MyButton(textButton: "Testar", onClick: () => {newAccountBackend.checkUserExists()},),
                      ],
                    ),
                  ))
            ],
          ),
        ));
  }
}
