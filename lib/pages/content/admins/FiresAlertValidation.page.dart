import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:monitor_queimadas_cariri/repositories/Validations.repository.dart';
import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:monitor_queimadas_cariri/utils/Notification.provider.dart';
import 'package:monitor_queimadas_cariri/utils/Notify.dart';

class FiresAlertValidationPage extends StatefulWidget {
  const FiresAlertValidationPage({super.key});

  @override
  State<StatefulWidget> createState() => FiresAlertValidationPageState();
}

class FiresAlertValidationPageState extends State<FiresAlertValidationPage> {
  final ValidationsRepository validationsRepository = ValidationsRepository();

  void clearNotifications() async {
    NotificationProvider notificationProvider = await NotificationProvider.getInstance();
    notificationProvider.removeAll();
  }

  @override
  void initState() {
    clearNotifications();
    validationsRepository.setOnError((responseCode) {
      if (responseCode == 0) {
        Notify.showSnackbarError("Falha ao tentar obter dados!");
        return;
      }
      Notify.showSnackbarError("Falha ao tentar obter dados!\nCodigo: $responseCode");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
        onVisibilityGained: () {
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            //systemNavigationBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.black.withOpacity(0.002),
            systemNavigationBarIconBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.light,
          ));
        },
        child: Scaffold(
            primary: false,
            resizeToAvoidBottomInset: false,
            backgroundColor: AppColors.appValidationBackground,
            body: Stack(children: [
              const SizedBox(width: double.maxFinite, height: double.maxFinite),
              TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  curve: Curves.ease,
                  duration: const Duration(seconds: 5),
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
                      padding: const EdgeInsets.only(left: 24, right: 24, top: 48, bottom: 24),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Image.asset('assets/images/monitor_queimadas_cariri.png', width: 122, height: 48),
                        const SizedBox(
                          width: 24,
                        ),
                        const Flexible(child: Text("Alertas de\nQueimadas", overflow: TextOverflow.ellipsis, maxLines: 4, textAlign: TextAlign.end, style: TextStyle(height: 1.2, fontWeight: FontWeight.w300, color: Colors.white, fontSize: 22))),
                      ])),
                  Expanded(
                      child: DefaultTabController(
                          length: 2,
                          child: Column(children: [
                            TabBar(
                              dividerColor: AppColors.appValidationAccent.withOpacity(0.5),
                              labelColor: AppColors.appValidationAccent,
                              unselectedLabelColor: AppColors.white_5,
                              indicatorColor: AppColors.appValidationAccent,
                              tabs: const [
                                Tab(text: "Pendentes"),
                                Tab(text: "Validados"),
                              ],
                            ),
                            Expanded(
                                child: TabBarView(children: [
                              getLoadingWidget(),
                              getLoadingWidget(),
                            ]))
                          ]))),
                  const SizedBox(height: 56)
                ],
              )
            ])));
  }

  Widget getLoadingWidget() {
    return const Center(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            color: AppColors.appValidationAccent,
            strokeWidth: 3,
          )),
      SizedBox(width: 16),
      Text("Carregando dados...", style: TextStyle(color: Colors.white))
    ]));
  }
}
