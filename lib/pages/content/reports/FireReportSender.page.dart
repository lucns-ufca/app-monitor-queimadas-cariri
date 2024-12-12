// Developed by @lucns

import 'dart:io';

import 'package:monitor_queimadas_cariri/api/Controller.api.dart';
import 'package:monitor_queimadas_cariri/firebase/MessagingSender.firebase.dart';
import 'package:monitor_queimadas_cariri/pages/content/MainScreen.page.dart';
import 'package:monitor_queimadas_cariri/pages/content/reports/FireReportPages.page.dart';
import 'package:monitor_queimadas_cariri/pages/dialogs/BasicDialogs.dart';
import 'package:monitor_queimadas_cariri/repositories/App.repository.dart';
import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:monitor_queimadas_cariri/utils/Constants.dart';
import 'package:monitor_queimadas_cariri/utils/Notify.dart';
import 'package:monitor_queimadas_cariri/utils/Utils.dart';
import 'package:monitor_queimadas_cariri/widgets/Button.dart';
import 'package:monitor_queimadas_cariri/widgets/ButtonLoading.widget.dart';
import 'package:monitor_queimadas_cariri/widgets/CustomText.dart';
import 'package:monitor_queimadas_cariri/widgets/TextField.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:platform_device_id/platform_device_id.dart';

class FireReportSenderPage extends StatefulWidget {
  final CallbackController callbackController;
  const FireReportSenderPage({required this.callbackController, super.key});

  @override
  State<StatefulWidget> createState() => FireReportSenderPageState();
}

class FireReportSenderPageState extends State<FireReportSenderPage> {
  Connectivity connectivity = Connectivity();
  File? imageFile;
  String? description;
  double latitude = 0;
  double longitude = 0;
  String? cityName;
  bool buttonsChanged = false;
  bool textChanged = false;
  bool sending = false;
  bool sent = false;
  bool hasError = false;
  String? hours;
  Dialogs? dialogs;
  ButtonLoadingController buttonLoadingController = ButtonLoadingController();
  AppRepository appRepository = AppRepository();

  Future<void> sendData() async {
    buttonLoadingController.setLoading(true);
    FormData formData = FormData();
    //formData.fields.add(MapEntry("city", cityName ?? "(Não foi possível obter o nome da cidade. GPS sem precisão!)"));
    formData.fields.add(MapEntry("latitude", latitude.toString()));
    formData.fields.add(MapEntry("longitude", longitude.toString()));
    //formData.fields.add(MapEntry("timestamp", DateTime.now().toLocal().millisecondsSinceEpoch.toString()));
    //formData.fields.add(MapEntry("date_time", getDateTime()));
    formData.fields.add(MapEntry("description", description ?? getInitialText()));
    formData.files.add(MapEntry("image", await MultipartFile.fromFile(imageFile!.path, contentType: DioMediaType.parse("image/jpg"))));
    ApiResponse response = await appRepository.reportFireFormData(formData);

    if (response.code != null && response.code! > 199 && response.code! < 300) {
      await imageFile!.delete();
      FirebaseMessagingSender sender = FirebaseMessagingSender();
      sender.sendNotification("Um alerta foi reportado", "Foi reportado um alerta de queimada. Clique para ver mais detalhes ou validar, na lista de alertas.", topic: Constants.FCM_TOPIC_ALERT_FIRE);
      buttonLoadingController.setLoading(false);
      dialogs!.showDialogSuccess("Enviado", "Obrigado por nos ajudar no monitoramento de queimadas.", onDismiss: () async {
        await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreenPage()));
      });
      return;
    }
    List<ConnectivityResult> results = await connectivity.checkConnectivity();
    if (results.isEmpty) {
      dialogs!.showDialogError("Erro ao enviar", "Sem conexão à internet.");
    } else {
      dialogs!.showDialogError("Erro ao enviar", "Não foi possivel enviar neste momento. Houve um problema na conexão com o servidor. Código de resposta: ${response.code}.");
    }
    buttonLoadingController.setLoading(false);
    Utils.vibrate();
  }

  bool isValidForm() {
    return imageFile != null && latitude != 0 && longitude != 0;
  }

  void setPosition(Position position) async {
    latitude = position.latitude;
    longitude = position.longitude;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (cityName != null) {
        if (cityName != placemarks[0].subAdministrativeArea) {
          if (mounted) {
            setState(() {
              cityName = placemarks[0].subAdministrativeArea;
            });
          } else {
            cityName = placemarks[0].subAdministrativeArea;
          }
        }
      } else {
        if (mounted) {
          setState(() {
            cityName = placemarks[0].subAdministrativeArea;
          });
        } else {
          cityName = placemarks[0].subAdministrativeArea;
        }
      }
    } catch (err) {
      // ignored, really.
    }
  }

  Future<String?> getDeviceId() async {
    try {
      return await PlatformDeviceId.getDeviceId;
      //log(deviceId)
    } on PlatformException {
      return null;
    }
  }

  @override
  void initState() {
    dialogs = Dialogs(context);
    imageFile = File(widget.callbackController.getImagePath());
    Position? position = widget.callbackController.getPosition();
    if (position != null) setPosition(position);
    widget.callbackController.setPosition = setPosition;
    widget.callbackController.updateWidget = updateWidget;
    hours = getHours();
    super.initState();
  }

  void updateWidget() {
    setState(() {
      imageFile = File(widget.callbackController.getImagePath());
    });
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
          //await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreenPage()));
        },
        child: SafeArea(
            top: false,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: double.maxFinite,
              color: AppColors.fragmentBackground,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                      child: Container(
                    //height: MediaQuery.of(context).size.height * 0.6,
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(36), bottomRight: Radius.circular(36)),
                        image: DecorationImage(
                          fit: BoxFit.fitWidth,
                          image: Image.file(imageFile!).image,
                        )),
                  )),
                  Expanded(
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Column(children: [
                              const Align(alignment: Alignment.topLeft, child: Text("Alerta de Queimada", style: TextStyle(height: 1.0, color: AppColors.textNormal, fontSize: 36, fontWeight: FontWeight.w400))),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  SvgPicture.asset("assets/icons/marker_alert.svg", width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.accent, BlendMode.srcIn)),
                                  const SizedBox(width: 8),
                                  MyText(
                                      text: cityName ?? "Carregando...",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.accent,
                                      ))
                                ],
                              ),
                              const SizedBox(height: 20),
                              MyFieldText(
                                textAlignVertical: TextAlignVertical.top,
                                isEnabled: !buttonsChanged,
                                height: 200,
                                maximumLines: 10,
                                hintText: "Escreva um relato aqui...",
                                text: getInitialText(),
                                action: TextInputAction.newline,
                                inputType: TextInputType.multiline,
                                textCapitalization: TextCapitalization.sentences,
                                onInput: (text) {
                                  description = text;
                                  if (description!.isEmpty) description = getInitialText();
                                },
                              )
                            ]),
                            Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              const SizedBox(height: 24),
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: AnimatedSwitcher(
                                      duration: const Duration(seconds: 1),
                                      child: buttonsChanged
                                          ? ButtonLoading(
                                              text: hasError ? "Tentar novamente" : (sent ? "Enviado" : "Enviar Alerta"),
                                              icon: Icon(!sent || hasError ? Icons.send : Icons.done_outline),
                                              controller: buttonLoadingController,
                                              onPressed: () async {
                                                if (isValidForm()) {
                                                  await sendData();
                                                  return;
                                                }
                                                Notify.showToast("Espere um pouco.\nAguardando dados da localização...");
                                              })
                                          : Row(
                                              children: [
                                                Expanded(
                                                    child: MyButton(
                                                  colorBackground: AppColors.buttonNegative,
                                                  textButton: "Voltar",
                                                  onClick: () => widget.callbackController.onPreviousStep(),
                                                )),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                    child: MyButton(
                                                  textButton: "Avançar",
                                                  onClick: () {
                                                    setState(() {
                                                      buttonsChanged = true;
                                                    });
                                                  },
                                                ))
                                              ],
                                            )))
                            ])
                          ])))
                ],
              ),
            )));
  }

  String getInitialText() {
    DateTime now = DateTime.now().toLocal();
    String city = cityName ?? "(Carregando...)";
    String month = Utils.getMonthName().toLowerCase();
    return "Foco de queimada sendo relatado as ${hours!} do dia ${now.day} de $month, nas aproximidades da cidade de $city. A mesma está sendo resportada pelo app.";
  }

  String getDateTime() {
    //2024-07-23 17:45 25
    DateTime now = DateTime.now().toLocal();
    String month = now.month < 10 ? "0${now.month}" : "${now.month}";
    String day = now.day < 10 ? "0${now.day}" : "${now.day}";
    String hour = now.hour < 10 ? "0${now.hour}" : "${now.hour}";
    String minute = now.minute < 10 ? "0${now.minute}" : "${now.minute}";
    String second = now.second < 10 ? "0${now.second}" : "${now.second}";
    return "${now.year}-$month-$day $hour:$minute $second";
  }

  String getHours() {
    DateTime now = DateTime.now().toLocal();
    String minute = now.minute < 10 ? "0${now.minute}" : "${now.minute}";
    return "${now.hour}:$minute";
  }
}
/*
        FormData formData = FormData();
          File imageFile = File(file.path);
          formData.files.add(MapEntry('file', MultipartFile.fromBytes(imageFile.readAsBytesSync(), filename: compressImg.path.split('/').last)));
          */
