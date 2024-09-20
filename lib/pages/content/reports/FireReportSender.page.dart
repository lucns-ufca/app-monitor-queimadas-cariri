import 'dart:io';

import 'package:app_monitor_queimadas/api/Api.dart';
import 'package:app_monitor_queimadas/pages/content/Dashboard.page.dart';
import 'package:app_monitor_queimadas/pages/content/reports/FireReportPages.page.dart';
import 'package:app_monitor_queimadas/pages/dialogs/BasicDialogs.dart';
import 'package:app_monitor_queimadas/repositories/App.repository.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:app_monitor_queimadas/utils/Log.out.dart';
import 'package:app_monitor_queimadas/utils/Notify.dart';
import 'package:app_monitor_queimadas/utils/Utils.dart';
import 'package:app_monitor_queimadas/widgets/Button.dart';
import 'package:app_monitor_queimadas/widgets/ButtonLoading.widget.dart';
import 'package:app_monitor_queimadas/widgets/CustomText.dart';
import 'package:app_monitor_queimadas/widgets/TextField.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

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

  void attemptSendData() async {
    setState(() {
      hasError = false;
      sending = true;
    });
    int maximumAttempts = 2;
    int attempts = 0;
    int status = -1;
    while (status != 0 && attempts < maximumAttempts) {
      attempts++;
      status = await sendData();
      switch (status) {
        case 0:
          buttonLoadingController.setLoading(false);
          dialogs!.showDialogSuccess(() async {
            await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
          });
          setState(() {
            sending = false;
            sent = true;
          });
          Utils.vibrate();
          return;
        case 1:
          if (attempts != maximumAttempts) await Future.delayed(const Duration(seconds: 10));
          break;
        default:
          buttonLoadingController.setLoading(false);
          setState(() {
            hasError = true;
            sending = false;
            sent = false;
          });
          List<ConnectivityResult> results = await connectivity.checkConnectivity();
          if (results.isEmpty) {
            dialogs!.showDialogError("Erro ao enviar", "Sem conexão à internet.");
          } else {
            dialogs!.showDialogError("Erro ao enviar", "Ocorreu um erro desconhecido. Tente novamente mais tarde.");
          }
          Utils.vibrate();
          return;
      }
      if (attempts == maximumAttempts) {
        dialogs!.showDialogError("Erro ao enviar", "Não foi possivel enviar neste momento. Aparentemente o servidor está ausente.");
        buttonLoadingController.setLoading(false);
        setState(() {
          hasError = true;
          sending = false;
          sent = false;
        });
        return;
      }
    }
  }

  Future<int> sendData() async {
    buttonLoadingController.setLoading(true);

    FormData formData = FormData();
    formData.fields.add(MapEntry("city", cityName!));
    formData.fields.add(MapEntry("latitude", latitude.toString()));
    formData.fields.add(MapEntry("longitude", longitude.toString()));
    formData.fields.add(MapEntry("timestamp", DateTime.now().toLocal().millisecondsSinceEpoch.toString()));
    formData.fields.add(MapEntry("date_time", getDateTime()));
    formData.fields.add(MapEntry("description", description ?? getInitialText()));
    formData.files.add(MapEntry("image", MultipartFile.fromFileSync(imageFile!.path)));
    ApiResponse response = await appRepository.reportFire(formData);
    Log.d("Lucas", "Response code: ${response.code}");
    switch (response.code) {
      case ApiResponseCodes.OK:
        return 3;
      case ApiResponseCodes.ALREADY_REPORTED:
      case ApiResponseCodes.CREATED:
        await imageFile!.delete();
        return 0;
      case ApiResponseCodes.GATEWAY_TIMEOUT:
      case ApiResponseCodes.NOT_FOUND:
        return 1;
      case ApiResponseCodes.INSUFFICIENT_STORAGE:
        return 2;
      default:
        return 3;
    }
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
        onPopInvoked: (didPop) async {
          if (sending) {
            Notify.showToast("Envio em andamento...");
            return;
          }
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: double.maxFinite,
          color: AppColors.fragmentBackground,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                  child: SingleChildScrollView(
                      child: Column(children: [
                Container(
                  width: double.maxFinite,
                  height: MediaQuery.of(context).size.height * 0.6,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(36), bottomRight: Radius.circular(36)),
                      image: DecorationImage(
                        fit: BoxFit.fitWidth,
                        alignment: FractionalOffset.topCenter,
                        image: Image.file(imageFile!).image,
                      )),
                ),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Alerta de Queimada", style: TextStyle(height: 1.0, color: AppColors.textNormal, fontSize: 36, fontWeight: FontWeight.w400)),
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
                          height: 150,
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
                        ),
                        //SizedBox(height: MediaQuery.of(context).viewInsets.bottom / 1.5)
                      ],
                    )),
              ]))),
              Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                  child: AnimatedSwitcher(
                      duration: const Duration(seconds: 1),
                      child: buttonsChanged
                          ? ButtonLoading(
                              text: hasError ? "Tentar novamente" : (sent ? "Enviado" : "Enviar Alerta"),
                              icon: Icon(!sent || hasError ? Icons.send : Icons.done_outline),
                              controller: buttonLoadingController,
                              onPressed: () {
                                if (isValidForm()) {
                                  attemptSendData();
                                  return;
                                }
                                Notify.showToast("Espere um pouco.\nAguardando dados da localização...");
                              })
                          : Row(
                              children: [
                                Expanded(
                                    child: MyButton(
                                  colorBackground: AppColors.accent,
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
                            ))),
            ],
          ),
        ));
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
