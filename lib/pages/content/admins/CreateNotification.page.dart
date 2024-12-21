import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:monitor_queimadas_cariri/pages/content/MainScreen.page.dart';
import 'package:monitor_queimadas_cariri/pages/dialogs/BasicDialogs.dart';
import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:monitor_queimadas_cariri/utils/Notify.dart';
import 'package:monitor_queimadas_cariri/widgets/ButtonLoading.widget.dart';
import 'package:monitor_queimadas_cariri/widgets/TextField.dart';

class CreateNotificationPage extends StatefulWidget {
  const CreateNotificationPage({super.key});

  @override
  State<StatefulWidget> createState() => CreateNotificationPageState();
}

class CreateNotificationPageState extends State<CreateNotificationPage> {
  final ButtonLoadingController buttonLoadingController = ButtonLoadingController();
  Dialogs? dialogs;
  bool sending = false;
  bool hasError = false;
  bool sent = false;
  String title = "";
  String content = "";

  Future<void> sendData() async {
    await Future.delayed(const Duration(seconds: 1));
    await dialogs!.showDialogSuccess("Enviado", "A notificação será recebida em todos os dispositivos que possui o app instalado.");
  }

  @override
  void initState() {
    dialogs = Dialogs(context, backgroundColor: AppColors.appAdminFragmentBackground, accentColor: AppColors.appAdminAccent);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (sending) {
            Notify.showToast("Envio em andamento...");
            return;
          }
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreenPage()));
        },
        child: FocusDetector(
            onVisibilityGained: () {
              SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Colors.black.withOpacity(0.002),
                systemNavigationBarIconBrightness: Brightness.light,
                statusBarIconBrightness: Brightness.light,
              ));
            },
            child: Scaffold(
                backgroundColor: AppColors.appAdminBackground,
                body: Stack(children: [
                  const SizedBox(width: double.maxFinite, height: double.maxFinite),
                  TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      curve: Curves.easeIn,
                      duration: const Duration(seconds: 4),
                      builder: (BuildContext context, double opacity, Widget? child) {
                        return Opacity(
                            opacity: opacity,
                            child: const Align(
                                alignment: Alignment.bottomCenter,
                                child: Image(
                                  image: AssetImage("assets/images/vitoria_regea.jpg"),
                                  fit: BoxFit.fitWidth,
                                )));
                      }),
                  Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Image.asset('assets/images/monitor_queimadas_cariri.png', width: 122, height: 48),
                            const SizedBox(
                              width: 24,
                            ),
                            const Flexible(child: Text("Envio de\nNotificações", overflow: TextOverflow.ellipsis, maxLines: 4, textAlign: TextAlign.end, style: TextStyle(height: 1.2, fontWeight: FontWeight.w300, color: Colors.white, fontSize: 22))),
                          ])),
                      Expanded(
                          child: SingleChildScrollView(
                              child: Padding(
                                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 56),
                                  child: Column(children: [
                                    getDivider("Regras de Envio"),
                                    const SizedBox(height: 16),
                                    const Text("1 - As notificações enviadas aqui serão recebidas em todos os smartphones com o app instalado. Portanto, cuidado com o conteúdo que você está inserindo nela.", style: TextStyle(color: AppColors.pink)),
                                    const SizedBox(height: 8),
                                    const Text("2 - Tente inserir um conteúdo atrativo que fará com que o usuário toque para ver, invés de apagar a notificação.", style: TextStyle(color: AppColors.pink)),
                                    const SizedBox(height: 8),
                                    const Text("3 - Não envie muitas notificações dentro de um intervalo curto de tempo. Isso poderá fazer com que o usuário desisntale o nosso app.", style: TextStyle(color: AppColors.pink)),
                                    const SizedBox(height: 8),
                                    const Text("4 - Ao tocar na notificação o app irá abrir, para que o usuário veja as atualizações. Entáo não crie um conteúdo considerado fake news.", style: TextStyle(color: AppColors.pink)),
                                    const SizedBox(height: 8),
                                    const Text("5 - Seja intuitivo e direto. O conteúdo da notificação não deve ser longo.", style: TextStyle(color: AppColors.pink)),
                                    const SizedBox(height: 8),
                                    const Text("Obs: Existe algumas validações sobre o texto digitado. O botao de enviar só ficará habilitado se não for encontrado nenhuma inconformidade no texto digitado.", style: TextStyle(color: AppColors.accent)),
                                    const SizedBox(height: 16),
                                    getDivider("Dados da Notificação"),
                                    const SizedBox(height: 16),
                                    MyFieldText(onInput: (value) {}, hintText: "Titulo", action: TextInputAction.next, inputType: TextInputType.text, textCapitalization: TextCapitalization.sentences),
                                    const SizedBox(height: 16),
                                    MyFieldText(
                                      textAlignVertical: TextAlignVertical.top,
                                      height: 200,
                                      maximumLines: 10,
                                      hintText: "Conteúdo",
                                      action: TextInputAction.newline,
                                      inputType: TextInputType.multiline,
                                      textCapitalization: TextCapitalization.sentences,
                                      onInput: (text) {},
                                    ),
                                    const SizedBox(height: 24),
                                    ButtonLoading(
                                        backgroundColor: AppColors.appAdminAccent.withOpacity(0.5),
                                        text: hasError ? "Tentar novamente" : (sent ? "Enviado" : "Enviar Notificação"),
                                        icon: Icon(!sent || hasError ? Icons.send : Icons.done_outline),
                                        controller: buttonLoadingController,
                                        onPressed: () async {
                                          if (isValidTitle() == null && isValidContent() == null) {
                                            await sendData();
                                            return;
                                          }
                                          Notify.showToast("Espere um pouco.\nAguardando dados da localização...");
                                        })
                                  ]))))
                    ],
                  )
                ]))));
  }

  Widget getDivider(String title) {
    return Row(mainAxisSize: MainAxisSize.max, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(width: 8), Expanded(child: Container(height: 1, color: Colors.white))]);
  }

  String? isValidTitle() {
    return null;
  }

  String? isValidContent() {
    return null;
  }
}
