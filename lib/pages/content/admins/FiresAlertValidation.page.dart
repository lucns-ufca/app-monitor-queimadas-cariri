import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:monitor_queimadas_cariri/models/FireAlert.model.dart';
import 'package:monitor_queimadas_cariri/pages/content/admins/FireAlertDetails.page.dart';
import 'package:monitor_queimadas_cariri/repositories/Alerts.repository.dart';
import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:monitor_queimadas_cariri/utils/Notification.provider.dart';

class FiresAlertValidationPage extends StatefulWidget {
  const FiresAlertValidationPage({super.key});

  @override
  State<StatefulWidget> createState() => FiresAlertValidationPageState();
}

class FiresAlertValidationPageState extends State<FiresAlertValidationPage> {
  final AlertsRepository alertsRepository = AlertsRepository();

  void clearNotifications() async {
    NotificationProvider notificationProvider = await NotificationProvider.getInstance();
    notificationProvider.removeAll();
  }

  @override
  void initState() {
    clearNotifications();
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
                            Expanded(child: TabBarView(children: [getContent(true), getContent(false)]))
                          ])))
                ],
              )
            ])));
  }

  Widget getContent(bool pending) {
    return ShaderMask(
        shaderCallback: (rect) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.appValidationBackground, Colors.transparent],
          ).createShader(Rect.fromLTRB(0, rect.height * 0.75, rect.width, rect.height));
        },
        blendMode: BlendMode.dstIn,
        child: Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 48),
            child: FutureBuilder(
                future: pending ? alertsRepository.getPendingAlerts() : alertsRepository.getValidatedAlerts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return getLoadingWidget();
                  }
                  List<FireAlertModel>? alertList = snapshot.data;
                  if (snapshot.hasError || alertList == null) {
                    return getErrorWidget();
                  }
                  if (alertList.isEmpty) {
                    return getEmptyListWidget();
                  }
                  return SingleChildScrollView(
                      child: Column(
                          children: List.generate(alertList.length + 1, (index) {
                    if (index == alertList.length) return const SizedBox(height: 72);
                    DateTime dateOccurrence = DateTime.parse(alertList[index].dateTime!).toLocal();
                    DateTime now = DateTime.now();
                    String dateHour = "${dateOccurrence.hour}:${dateOccurrence.minute}";
                    Duration difference = now.difference(dateOccurrence);
                    if (difference.inHours > 47) {
                      dateHour = "Reportado antes de ontem às $dateHour";
                    } else if (difference.inHours > 23) {
                      dateHour = "Reportado ontem às $dateHour";
                    } else if (difference.inHours > 9) {
                      dateHour = "Reportado hoje às $dateHour";
                    } else if (difference.inHours > 1) {
                      dateHour = "Reportado a ${difference.inHours} horas atrás";
                    } else if (difference.inHours == 1) {
                      dateHour = "Reportado a uma hora atrás";
                    } else if (difference.inMinutes > 10) {
                      dateHour = "Reportado a menos de 1 hora atrás";
                    } else if (difference.inMinutes > 1) {
                      dateHour = "Reportado a alguns minutos atrás";
                    } else {
                      dateHour = "Reportado agora a pouco";
                    }
                    return Column(children: [getListItemWidget(dateHour, alertList[index]), SizedBox(height: index < alertList.length - 1 ? 8 : 16)]);
                  })));
                })));
  }

  Widget getListItemWidget(String title, FireAlertModel fireAlert) {
    double width = MediaQuery.of(context).size.width - (2 * 24);
    double height = 110;
    return ConstrainedBox(
        constraints: BoxConstraints(minHeight: height, maxWidth: width, minWidth: width),
        child: Container(
            decoration: BoxDecoration(
              color: AppColors.gray.withOpacity(0.25),
              borderRadius: const BorderRadius.all(Radius.circular(24)),
            ),
            child: IntrinsicHeight(
                child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  width: height,
                  decoration: BoxDecoration(
                    color: AppColors.gray.withOpacity(0.25),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(24)),
                  ),
                  child: fireAlert.imageUrl == null
                      ? const Center(child: SizedBox(width: 16, height: 16, child: Icon(Icons.warning)))
                      : CachedNetworkImage(
                          imageUrl: fireAlert.imageUrl!,
                          placeholder: (context, url) => const Center(
                                  child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: AppColors.appValidationAccent),
                              )),
                          errorWidget: (context, url, error) => const Center(child: SizedBox(width: 16, height: 16, child: Icon(Icons.warning, color: AppColors.red))),
                          imageBuilder: (context, imageProvider) => Container(
                                  decoration: BoxDecoration(
                                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(24)),
                              )))),
              Expanded(
                  child: Column(children: [
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                          Flexible(child: Text(title, overflow: TextOverflow.ellipsis, maxLines: 10, style: const TextStyle(color: AppColors.appValidationAccentHighlight, fontSize: 16, fontWeight: FontWeight.w400))),
                          Flexible(child: Text(fireAlert.description!, textAlign: TextAlign.justify, overflow: TextOverflow.ellipsis, maxLines: 10, style: const TextStyle(color: AppColors.white_2, fontSize: 14, fontWeight: FontWeight.w500)))
                        ]))),
                const SizedBox(height: 16),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(width: double.maxFinite, height: 0.5, color: AppColors.white_2)),
                SizedBox(
                    width: double.maxFinite,
                    child: TextButton(
                        style: ButtonStyle(
                            shape: WidgetStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(24)))),
                            backgroundColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
                            overlayColor: WidgetStateProperty.resolveWith((states) => AppColors.appValidationAccent.withOpacity(0.5))),
                        onPressed: () async {
                          await Future.delayed(const Duration(milliseconds: 250));
                          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FireAlertDetailsPage(fireAlert)));
                        },
                        child: const Text("Ver detalhes", style: TextStyle(fontSize: 14, color: AppColors.white_2, fontWeight: FontWeight.w600))))
              ]))
            ]))));
  }

  Widget getErrorWidget() {
    return const Center(child: Row(mainAxisSize: MainAxisSize.min, children: [SizedBox(width: 16, height: 16, child: Icon(Icons.warning)), SizedBox(width: 16), Text("Carregando dados...", style: TextStyle(color: AppColors.white_5))]));
  }

  Widget getEmptyListWidget() {
    return SizedBox(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Icon(Icons.check_circle, color: AppColors.appValidationAccent.withOpacity(0.75)), const SizedBox(width: 8), const Text("Nenhum alerta.", style: TextStyle(color: AppColors.white_5))]));
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
