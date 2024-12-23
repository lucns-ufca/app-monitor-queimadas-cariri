import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:monitor_queimadas_cariri/models/FireAlert.model.dart';
import 'package:monitor_queimadas_cariri/pages/content/admins/FiresAlertValidation.page.dart';
import 'package:monitor_queimadas_cariri/pages/dialogs/BasicDialogs.dart';
import 'package:monitor_queimadas_cariri/repositories/Alerts.repository.dart';
import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:monitor_queimadas_cariri/utils/Notify.dart';
import 'package:monitor_queimadas_cariri/utils/Utils.dart';
import 'package:monitor_queimadas_cariri/widgets/Button.dart';
import 'package:monitor_queimadas_cariri/widgets/ButtonLoading.widget.dart';
import 'package:monitor_queimadas_cariri/widgets/CustomText.dart';
import 'package:monitor_queimadas_cariri/widgets/TextField.dart';

class FireAlertDetailsPage extends StatefulWidget {
  final FireAlertModel fireAlert;
  const FireAlertDetailsPage(this.fireAlert, {super.key});

  @override
  State<StatefulWidget> createState() => FireAlertDetailsPageState();
}

class FireAlertDetailsPageState extends State<FireAlertDetailsPage> {
  final AlertsRepository alertsRepository = AlertsRepository();
  final Connectivity connectivity = Connectivity();
  final ButtonLoadingController buttonLoadingController = ButtonLoadingController();
  String? cityName;
  String? statusClick;
  bool sending = false;
  bool sent = false;
  bool hasError = false;
  Dialogs? dialogs;

  Future<void> sendData(bool validate) async {
    buttonLoadingController.setLoading(true);
    setState(() {
      sending = true;
    });
    Response? response = await alertsRepository.sendFireAlertStatus(widget.fireAlert.id!, validate);
    setState(() {
      hasError = false;
      sending = false;
    });
    buttonLoadingController.setLoading(false);
    if (response != null && response.statusCode != null && response.statusCode! > 199 && response.statusCode! < 300) {
      buttonLoadingController.setLoading(false);
      String status = statusClick == "Validar Alerta" ? "validado" : "invalidado";
      dialogs!.showDialogSuccess("Concluído", "O alerta de queimada foi $status com sucesso.", onDismiss: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FiresAlertValidationPage()));
      });
      return;
    }
    hasError = true;
    List<ConnectivityResult> results = await connectivity.checkConnectivity();
    String status = statusClick == "Validar Alerta" ? "validadar" : "invalidadar";
    if (results.isEmpty) {
      dialogs!.showDialogError("Erro ao $status", "Sem conexão à internet.");
    } else {
      int code = response == null || response.statusCode == null ? 0 : response.statusCode!;
      String message;
      if (code == 0) {
        message = "Não foi possivel $status neste momento. Houve um problema na conexão com o servidor.";
      } else if (code == 409) {
        message = "Este alerta já foi validado/invalidado, por outra pessoa anteriormente.";
      } else {
        message = "Não foi possivel $status neste momento. Houve um problema na conexão com o servidor. Código de resposta: $code.";
      }

      dialogs!.showDialogError("Erro ao $status", message);
    }
    Utils.vibrate();
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
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (sending) {
            if (statusClick != null && statusClick == "Validar Alerta") {
              Notify.showToast("Validação em andamento...", backgroundColor: AppColors.appAdminToastBackground, textColor: AppColors.appAdminAccent);
            } else {
              Notify.showToast("Invalidação em andamento...", backgroundColor: AppColors.appAdminToastBackground, textColor: AppColors.appAdminAccent);
            }
            return;
          }
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FiresAlertValidationPage()));
        },
        child: Scaffold(
            primary: false,
            resizeToAvoidBottomInset: false,
            backgroundColor: AppColors.appAdminBackground,
            body: SafeArea(
                top: false,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: double.maxFinite,
                  color: AppColors.appAdminBackground,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: CachedNetworkImage(
                              imageUrl: widget.fireAlert.imageUrl!,
                              placeholder: (context, url) => const Center(
                                      child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: AppColors.appAdminAccent),
                                  )),
                              errorWidget: (context, url, error) => const Center(child: SizedBox(width: 16, height: 16, child: Icon(Icons.warning, color: AppColors.red))),
                              imageBuilder: (context, imageProvider) => Container(
                                      decoration: BoxDecoration(
                                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                    borderRadius: const BorderRadius.only(bottomRight: Radius.circular(24), bottomLeft: Radius.circular(24)),
                                  )))),
                      Expanded(
                          child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Column(children: [
                                  const Align(alignment: Alignment.topLeft, child: Text("Alerta de Queimada", style: TextStyle(height: 1.0, color: AppColors.textNormal, fontSize: 36, fontWeight: FontWeight.w400))),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      SvgPicture.asset("assets/icons/marker_alert.svg", width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.appAdminAccent, BlendMode.srcIn)),
                                      const SizedBox(width: 8),
                                      MyText(
                                          text: "${widget.fireAlert.latitude}, ${widget.fireAlert.longitude}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: AppColors.appAdminAccent,
                                          ))
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  MyFieldText(
                                    textAlignVertical: TextAlignVertical.top,
                                    isEnabled: false,
                                    height: 200,
                                    maximumLines: 10,
                                    hintText: "",
                                    text: widget.fireAlert.description!,
                                    action: TextInputAction.newline,
                                    inputType: TextInputType.multiline,
                                    textCapitalization: TextCapitalization.sentences,
                                    onInput: (text) {},
                                  )
                                ]),
                                if (widget.fireAlert.status == "PENDING")
                                  Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                    const SizedBox(height: 24),
                                    Padding(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        child: AnimatedSwitcher(
                                            duration: const Duration(seconds: 1),
                                            child: statusClick != null
                                                ? ButtonLoading(
                                                    backgroundColor: AppColors.appAdminAccent.withOpacity(0.5),
                                                    text: hasError ? "Tentar novamente" : (sent ? (statusClick == "Validar Alerta" ? "Validado" : "Invalidado") : statusClick),
                                                    icon: Icon(!sent || hasError ? Icons.send : Icons.done_outline),
                                                    controller: buttonLoadingController,
                                                    onPressed: () async {
                                                      await sendData(statusClick == "Validar Alerta");
                                                    })
                                                : Row(
                                                    children: [
                                                      Expanded(
                                                          child: MyButton(
                                                        colorBackground: AppColors.buttonNegative,
                                                        textButton: "Invalidar",
                                                        onClick: () {
                                                          setState(() {
                                                            statusClick = "Invalidar Alerta";
                                                          });
                                                        },
                                                      )),
                                                      const SizedBox(width: 16),
                                                      Expanded(
                                                          child: MyButton(
                                                        colorBackground: AppColors.appAdminAccent.withOpacity(0.5),
                                                        textButton: "Validar",
                                                        onClick: () {
                                                          setState(() {
                                                            statusClick = "Validar Alerta";
                                                          });
                                                        },
                                                      ))
                                                    ],
                                                  )))
                                  ])
                              ])))
                    ],
                  ),
                ))));
  }
}
