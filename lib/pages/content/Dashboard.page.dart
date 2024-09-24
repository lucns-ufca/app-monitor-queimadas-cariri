// @Developed by @lucns

import 'dart:convert';
import 'dart:io';

import 'package:app_monitor_queimadas/api/Api.dart';
import 'package:app_monitor_queimadas/models/PredictionCity.model.dart';
import 'package:app_monitor_queimadas/models/User.model.dart';
import 'package:app_monitor_queimadas/pages/content/AboutProject.page.dart';
import 'package:app_monitor_queimadas/pages/content/reports/FireReportPages.page.dart';
import 'package:app_monitor_queimadas/pages/start/Acess.page.dart';
import 'package:app_monitor_queimadas/pages/start/First.page.dart';
import 'package:app_monitor_queimadas/pages/dialogs/PopupMenu.dart';
import 'package:app_monitor_queimadas/repositories/App.repository.dart';
import 'package:app_monitor_queimadas/utils/Constants.dart';
import 'package:app_monitor_queimadas/utils/Log.out.dart';
import 'package:app_monitor_queimadas/utils/PermissionData.dart';
import 'package:app_monitor_queimadas/utils/TimeRegister.dart';
import 'package:app_monitor_queimadas/utils/Utils.dart';
import 'package:app_monitor_queimadas/widgets/Button.dart';
import 'package:app_monitor_queimadas/widgets/CardsCities.widget.dart';
import 'package:app_monitor_queimadas/widgets/GaugeChart.widget.dart';
import 'package:app_monitor_queimadas/widgets/charts/ChartGrid.widget.dart';
import 'package:flutter/material.dart';

import 'package:app_monitor_queimadas/widgets/Toolbar.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  var user = GetIt.I.get<User>();
  double toolbarHeight = 165;
  List<PermissionData> permissions = [PermissionData(name: "Camera", permission: Permission.camera), PermissionData(name: "Localização", permission: Permission.locationWhenInUse)];
  ProgressController progressController = ProgressController();
  ProgressController progressController2 = ProgressController();
  double value = 25;
  bool updatingPrediction = false;
  Timeregister timeRegisterPredictionTotal = const Timeregister("prediction_total");
  AppRepository appRepository = AppRepository();
  PredictionCityModel? prediction;

  Future<void> requestPredictionValues() async {
    Log.d("Lucas", "requestPredictionValues");
    if (mounted) {
      setState(() {
        updatingPrediction = true;
      });
    }
    ApiResponse response = await appRepository.getPredictionValues();
    if (response.code == 200) {
      prediction = PredictionCityModel.fromJson(jsonDecode(response.data));
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File("${directory.path}/${prediction!.city}}");
      await file.writeAsString(response.data);
      await timeRegisterPredictionTotal.setLastUpodate();

      double percentage = (prediction!.occurredTotal! / prediction!.predictionTotal!) * 100.0;
      if (percentage > 100) percentage = 100;
      progressController.setProgress(percentage);

      int month = DateTime.now().toLocal().month;
      percentage = (prediction!.months![month].fireOccurrences! / prediction!.months![month].firesPredicted!) * 100.0;
      if (percentage > 100) percentage = 100;
      progressController2.setProgress(percentage);
    } else {
      Log.d("Lucas", "response ${response.code}");
    }
    //await Future.delayed(const Duration(seconds: 5));
    if (mounted) {
      setState(() {
        updatingPrediction = false;
      });
    }
  }

  void showMenuWindow() {
    PopupMenu popupMenu = PopupMenu(context: context);
    List<String> titles = [if (!user.hasAccess()) "Login", if (user.hasAccess()) "Validação de queimadas", "Sobre o Projeto"];
    var items = popupMenu.generateIds(titles);
    popupMenu.showMenu(items, (index) async {
      switch (items[index].text) {
        case "Login":
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AccessPage()));
          break;
        case "Sobre o Projeto":
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AboutPage()));
          break;
      }
    });
  }

  void back() async {
    if (user.hasAccess()) {
      SystemNavigator.pop();
    } else {
      await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FirstPage()));
    }
  }

  Future<void> initialize() async {
    //if (await timeRegisterPredictionTotal.isOverTime(60)) {
    updatingPrediction = true;
    requestPredictionValues();
    //}
  }

  @override
  void initState() {
    initialize();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(systemNavigationBarColor: Colors.transparent, statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light, systemNavigationBarIconBrightness: Brightness.light));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    super.initState();
    //WidgetsBinding.instance.addPostFrameCallback((_) => verifyPermissions());
  }

  @override
  Widget build(BuildContext context) {
    //final navigator = Navigator.of(context);
    int ocurrences = 0;
    int predicted = 0;
    if (prediction != null) {
      int month = DateTime.now().toLocal().month;
      ocurrences = prediction!.months![month].fireOccurrences!;
      predicted = prediction!.months![month].firesPredicted!;
    }
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => back(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.appBackground,
        floatingActionButton: SizedBox(
            width: 56,
            height: 56,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                  backgroundColor: AppColors.buttonNormal,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FireReportPages(permissions: permissions)));
                },
                child: const Icon(Icons.local_fire_department))),
        body: Stack(
          children: [
            Container(
              height: toolbarHeight,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                fit: BoxFit.fitWidth,
                alignment: FractionalOffset.topCenter,
                image: AssetImage("assets/images/toolbar_background_3.jpg"),
              )),
              child: Column(mainAxisSize: MainAxisSize.min, children: [const SizedBox(height: 28), MyToolbar(title: "Monitor de Queimadas", onBackPressed: () => back(), onMenuPressed: () => showMenuWindow)]),
            ),
            SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(height: toolbarHeight - Constants.DEFAULT_ROUND_BORDER, width: double.maxFinite),
              Container(
                  padding: const EdgeInsets.only(top: 24),
                  width: double.maxFinite,
                  decoration: const BoxDecoration(
                    color: AppColors.fragmentBackground,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(Constants.DEFAULT_ROUND_BORDER), topLeft: Radius.circular(Constants.DEFAULT_ROUND_BORDER)),
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 24),
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                const Text("Predições de queimadas", style: TextStyle(color: AppColors.textNormal, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                updatingPrediction
                                    ? const Row(mainAxisSize: MainAxisSize.min, children: [
                                        Text(
                                          "Atualizando...",
                                          style: TextStyle(color: AppColors.accent),
                                        ),
                                        SizedBox(width: 4),
                                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2))
                                      ])
                                    : FutureBuilder(
                                        future: timeRegisterPredictionTotal.getLastUpdate(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.done) {
                                            return Text(
                                              snapshot.data!,
                                              style: const TextStyle(color: AppColors.accent),
                                            );
                                          }
                                          return const SizedBox(height: 16);
                                        }),
                                const SizedBox(
                                  height: 24,
                                ),
                              ]))),
                      Center(
                          child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                              width: 180,
                              height: 180,
                              child: Stack(children: [
                                GaugeChart(progressController: progressController),
                                Center(
                                    child: updatingPrediction
                                        ? const Text("Carregando...", style: TextStyle(color: AppColors.textNormal))
                                        : Column(mainAxisSize: MainAxisSize.min, children: [
                                            Text("${prediction!.occurredTotal}/${prediction!.predictionTotal}", style: const TextStyle(color: AppColors.textNormal, fontWeight: FontWeight.w300, fontSize: 24)),
                                            const Text("Previsto anual", style: TextStyle(fontWeight: FontWeight.w300, color: AppColors.textNormal)),
                                            const SizedBox(height: 2),
                                            Text("Restando ${Utils.getRemainderDays()} dias", style: const TextStyle(fontWeight: FontWeight.w300, color: AppColors.accentLight)),
                                          ]))
                              ])),
                          const SizedBox(width: 24),
                          Align(
                              alignment: Alignment.bottomLeft,
                              child: SizedBox(
                                  width: 110,
                                  height: 110,
                                  child: Stack(children: [
                                    GaugeChart(progressController: progressController2),
                                    Center(
                                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                                      Text("$ocurrences/$predicted", style: const TextStyle(color: AppColors.textNormal, fontWeight: FontWeight.w300, fontSize: 24)),
                                      Text(Utils.getMonthName(), style: const TextStyle(fontWeight: FontWeight.w300, color: AppColors.textNormal))
                                    ]))
                                  ])))
                        ],
                      )),
                      Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: AppColors.shadow, borderRadius: BorderRadius.all(Radius.circular(24))),
                            child: const ChartGrid(),
                          ))
                    ],
                  )),
              ConstrainedBox(
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height, minWidth: double.maxFinite),
                  child: Container(
                      color: AppColors.fragmentBackground,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 24),
                          const CardsCities(),
                          const SizedBox(
                            height: 24,
                          ),
                          MyButton(
                            textButton: "Click",
                            onClick: () {
                              value = value == 25 ? 75 : 25;
                              progressController.setProgress(value);
                              progressController2.setProgress(value);
                              requestPredictionValues();
                            },
                          )
                        ],
                      ))),
            ])),
          ],
        ),
      ),
    );
  }
}
