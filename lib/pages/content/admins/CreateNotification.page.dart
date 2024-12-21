import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:monitor_queimadas_cariri/firebase/MessagingSender.firebase.dart';
import 'package:monitor_queimadas_cariri/pages/content/MainScreen.page.dart';
import 'package:monitor_queimadas_cariri/pages/dialogs/BasicDialogs.dart';
import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:monitor_queimadas_cariri/utils/Constants.dart';
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
  final FirebaseMessagingSender sender = FirebaseMessagingSender();
  Dialogs? dialogs;
  bool sending = false;
  bool hasError = false;
  bool sent = false;
  bool titlechanged = false;
  bool contentChanged = false;
  String title = "";
  String content = "";

  Future<void> sendData() async {
    buttonLoadingController.setLoading(true);
    await Future.delayed(const Duration(seconds: 1));
    sender.sendNotification(title, content, topic: Constants.FCM_TOPIC_GENERAL_MESSAGES);
    setState(() {
      sent = true;
      hasError = false;
    });
    buttonLoadingController.setLoading(false);
    await dialogs!.showDialogSuccess("Notificação Enviada", "A notificação será recebida em todos os dispositivos que possui o app instalado.", onDismiss: () async {
      await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreenPage()));
    });
  }

  @override
  void initState() {
    dialogs = Dialogs(context, backgroundColor: AppColors.appAdminFragmentBackground, accentColor: AppColors.appAdminAccent);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String? statusTitle = isValidTitle();
    String? statusContent = isValidContent();
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
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                                    if (titlechanged && statusTitle != null)
                                      Text(
                                        statusTitle,
                                        style: TextStyle(color: isValidTitle() == null ? AppColors.textNormal2 : AppColors.pink),
                                      ),
                                    const SizedBox(height: 8),
                                    MyFieldText(
                                        hintText: "Titulo",
                                        action: TextInputAction.next,
                                        inputType: TextInputType.text,
                                        textCapitalization: TextCapitalization.sentences,
                                        onInput: (text) {
                                          setState(() {
                                            title = text;
                                            titlechanged = true;
                                          });
                                        }),
                                    const SizedBox(height: 36),
                                    if (contentChanged && statusContent != null)
                                      Text(
                                        statusContent,
                                        style: TextStyle(color: isValidContent() == null ? AppColors.textNormal2 : AppColors.pink),
                                      ),
                                    const SizedBox(height: 8),
                                    MyFieldText(
                                      textAlignVertical: TextAlignVertical.top,
                                      height: 200,
                                      maximumLines: 10,
                                      hintText: "Conteúdo",
                                      action: TextInputAction.newline,
                                      inputType: TextInputType.multiline,
                                      textCapitalization: TextCapitalization.sentences,
                                      onInput: (text) {
                                        setState(() {
                                          content = text;
                                          contentChanged = true;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    Center(
                                        child: ButtonLoading(
                                            backgroundColor: AppColors.appAdminAccent.withOpacity(0.5),
                                            text: hasError ? "Tentar novamente" : (sent ? "Enviado" : "Enviar Notificação"),
                                            icon: Icon(!sent || hasError ? Icons.send : Icons.done_outline),
                                            controller: buttonLoadingController,
                                            onPressed: () async {
                                              if (isValidTitle() == null && isValidContent() == null) {
                                                FocusManager.instance.primaryFocus?.unfocus(); // hide keyboard
                                                await sendData();
                                                return;
                                              }
                                              Notify.showToast("Espere um pouco.\nAguardando dados da localização...");
                                            }))
                                  ]))))
                    ],
                  )
                ]))));
  }

  Widget getDivider(String title) {
    return Row(mainAxisSize: MainAxisSize.max, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(width: 8), Expanded(child: Container(height: 1, color: Colors.white))]);
  }

  String? isValidTitle() {
    if (title.isEmpty) return "Digite um titulo válido.";
    if (title.startsWith(" ")) return "O titulo não deve começar com espaço!";
    String firstLetter = title.substring(0, 1);
    if (firstLetter != firstLetter.toUpperCase()) return "A primeira letra do titulo deve ser maiúscula!";
    if (title.endsWith(" ")) return "O titulo não deve terminar com espaço!";
    if (title.contains("  ")) return "O titulo não deve ter dois espaços seguidos!";
    if (title.length > 32) return "O titulo não deve ultrapassar 32 caracteres!";
    if (title.length < 5) return "O titulo está muito curto!";
    if (!title.contains(" ")) return "Digite pelo menos mais uma palavra.";
    List<String> segments = title.split(" ");
    if (segments[segments.length - 1].length < 3) return "A última palavra é muito curta!";
    return null;
  }

  String? isValidContent() {
    if (content.isEmpty) return "Digite um conteúdo válido.";
    if (content.startsWith(" ")) return "O conteúdo não deve começar com espaço!";
    String firstLetter = content.substring(0, 1);
    if (firstLetter != firstLetter.toUpperCase()) return "A primeira letra do titulo deve ser maiúscula!";
    if (content.endsWith(" ")) return "O conteúdo não deve terminar com espaço!";
    if (content.contains(" ") && content.split(" ").length < 4) return "Há poucas palavras no conteúdo!";
    if (content.contains("  ")) return "O conteúdo não deve ter dois espaços seguidos!";
    if (content.length > 512) return "O conteúdo não deve ultrapassar 32 caracteres!";
    if (!content.contains(" ")) return "Digite pelo menos 5 palavras.";

    List<String> segments = content.split(" ");
    if (segments[segments.length - 1].length < 2) return "A última palavra é muito curta!";
    return null;
  }
}
