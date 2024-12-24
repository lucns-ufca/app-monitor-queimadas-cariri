import 'dart:async';
import 'dart:io';

import 'package:monitor_queimadas_cariri/models/PredictionCity.model.dart';
import 'package:monitor_queimadas_cariri/models/ForecastCity.model.dart';
import 'package:monitor_queimadas_cariri/models/User.model.dart';
import 'package:monitor_queimadas_cariri/models/WeatherCity.model.dart';
import 'package:monitor_queimadas_cariri/models/content/News.model.dart';
import 'package:monitor_queimadas_cariri/pages/content/AboutProject.page.dart';
import 'package:monitor_queimadas_cariri/pages/content/BaseWidgets.dart';
import 'package:monitor_queimadas_cariri/pages/content/IpDefinition.page.dart';
import 'package:monitor_queimadas_cariri/pages/content/admins/CreateNotification.page.dart';
import 'package:monitor_queimadas_cariri/pages/content/admins/FiresAlertValidation.page.dart';
import 'package:monitor_queimadas_cariri/pages/dialogs/PopupMenu.dart';
import 'package:monitor_queimadas_cariri/pages/start/Access.page.dart';
import 'package:monitor_queimadas_cariri/pages/start/First.page.dart';
import 'package:monitor_queimadas_cariri/repositories/App.repository.dart';
import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:monitor_queimadas_cariri/utils/Constants.dart';
import 'package:monitor_queimadas_cariri/utils/Utils.dart';
import 'package:monitor_queimadas_cariri/widgets/ContainerGradient.widget.dart';
import 'package:monitor_queimadas_cariri/widgets/ImageTransitionScroller.widget.dart';
import 'package:monitor_queimadas_cariri/widgets/TicketView.widget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TabHomePage extends StatefulWidget {
  const TabHomePage({super.key});

  @override
  State<StatefulWidget> createState() => TabHomePageState();
}

class TabHomePageState extends State<TabHomePage> with AutomaticKeepAliveClientMixin<TabHomePage> {
  final User user = GetIt.I.get<User>();
  final AppRepository appRepository = GetIt.I.get<AppRepository>();
  final SharedPreferences preferences = GetIt.I.get<SharedPreferences>();
  bool loadingTop = true;
  bool loadingBottom = true;
  bool connected = true;
  List<NewsModel> listNews = [];
  List<WeatherCityModel> listCities = [];
  Future<File?>? imageProfile;
  PredictionCityModel? selectedCurrentMonthHighestOccurred;

  void profileClick() async {
    if (user.isAuthenticated()) {
      showMenuWindow();
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const AccessPage()));
    }
  }

  void showMenuWindow() {
    PopupMenu popupMenu = PopupMenu(context: context);
    List<String> titles = [
      if (!user.isAuthenticated()) "Login",
      if (!loadingTop && !loadingBottom) "Atualizar Dados",
      if (user.isAdminstrator()) "Validação de queimadas",
      "Sobre o Projeto",
      if (user.isAdminstrator()) "Lançar notificação",
      if (user.isAuthenticated()) "Logout"
    ];
    var items = popupMenu.generateIds(titles);
    popupMenu.showMenu(items, (index) async {
      switch (items[index].text) {
        case "Atualizar Dados":
          updateLists(force: true);
          //FirebaseMessagingSender sender = FirebaseMessagingSender();
          //sender.sendNotification("This is a title", "This is a content", topic: Constants.FCM_TOPIC_ALERT_FIRE, channelId: Constants.NOTIFICATION_ID_ALERTS);
          //sender.sendMessage(message, topic: Constants.FCM_TOPIC_ALERT_FIRE);
          break;
        case "Validação de queimadas":
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const FiresAlertValidationPage()));
          break;
        case "Definir IP":
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const IpDefinitionPage()));
          break;
        case "Login":
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AccessPage()));
          break;
        case "Sobre o Projeto":
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AboutPage()));
          break;
        case "Lançar notificação":
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CreateNotificationPage()));
          break;
        case "Logout":
          user.clear();
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FirstPage()));
          break;
      }
    });
  }

  void updateWeather() {
    listCities = appRepository.getWeatherCities;
    if (listCities.isNotEmpty) {
      WeatherCityModel highestTemperature = WeatherCityModel();
      WeatherCityModel highestDaysWithoutRain = WeatherCityModel();
      for (WeatherCityModel model in listCities) {
        if (highestTemperature.timestamp == null || model.temperature! > highestTemperature.temperature!) {
          highestTemperature = model;
        }
        if (highestDaysWithoutRain.timestamp == null || model.daysWithoutRain! > highestDaysWithoutRain.daysWithoutRain!) {
          highestDaysWithoutRain = model;
        }
      }
      NewsModel news = NewsModel();
      news.assetsIcon = "assets/icons/weather/day_clear.png";
      news.priority = 2;
      news.title = "${highestTemperature.city} com máxima de ${highestTemperature.temperature}º.";
      news.description = "A cidade ${highestTemperature.city} poderá registrar temperaturas altas, em comparação com toda chapada do araripe, registrando na faixa dos ${highestTemperature.temperature}º.";
      listNews.add(news);
      if (highestDaysWithoutRain.daysWithoutRain! > 0) {
        news = NewsModel();
        news.assetsIcon = "assets/icons/weather/rain.png";
        news.priority = 2;
        news.title = "Dias sem Chuva.";
        news.description = "Atualmente ${highestDaysWithoutRain.city} está com o maior numero de dias sem chuva. Foram registrados ${highestDaysWithoutRain.daysWithoutRain} dia${highestDaysWithoutRain.daysWithoutRain != 1 ? "s" : ""}.";
        listNews.add(news);
      }
    }
  }

  void updatePrediction() {
    int currentMonth = DateTime.now().month;
    List<PredictionCityModel> predictionCities = appRepository.getPredictionCities;
    if (predictionCities.isNotEmpty) {
      int occurredTotal = 0;
      int predictionTotal = 0;
      for (PredictionCityModel model in predictionCities) {
        occurredTotal += model.occurredTotal!;
        predictionTotal += model.predictionTotal!;
        if (selectedCurrentMonthHighestOccurred == null || model.months![currentMonth - 1].fireOccurrences! > model.months![currentMonth - 1].fireOccurrences!) {
          selectedCurrentMonthHighestOccurred = model;
        }
      }
      NewsModel news = NewsModel();
      news.assetsIcon = "assets/icons/fire.png";
      news.priority = 1;
      news.title = "Ocorreram $occurredTotal focos de incêndio.";
      news.description = "A região da Chapada do Araripe tem registrado $occurredTotal focos de queimadas só este ano. O atual previsto para o ano inteiro ta sendo de $predictionTotal.";
      listNews.add(news);
      news = NewsModel();
      news.assetsIcon = "assets/icons/fire.png";
      news.priority = 1;
      news.title = "Focos corridos neste mês.";
      news.description = "Até o momento, ${selectedCurrentMonthHighestOccurred!.city} está com o maior numero de focos de queimadas ocorrida nesse mês de ${Utils.getMonthName()}.";
      listNews.add(news);
    }
  }

  void updateProbabilities() {
    List<ForecastCityModel> probabilitiesCities = appRepository.getForecastCities;
    if (probabilitiesCities.isNotEmpty) {
      ForecastCityModel highestProbabilities = ForecastCityModel();
      ForecastCityModel highestUvIndex = ForecastCityModel();
      ForecastCityModel highestPrecipitation = ForecastCityModel();
      for (ForecastCityModel model in probabilitiesCities) {
        if (highestProbabilities.city == null || model.getMaximumFireRisk() > highestProbabilities.getMaximumFireRisk()) {
          highestProbabilities = model;
        }
        if (highestUvIndex.city == null || model.getMaximumUvIndex() > highestUvIndex.getMaximumUvIndex()) {
          highestUvIndex = model;
        }
        if (highestUvIndex.city == null || model.getMaximumPrecipitation() > highestUvIndex.getMaximumPrecipitation()) {
          highestPrecipitation = model;
        }
      }

      NewsModel news = NewsModel();
      news.assetsIcon = "assets/icons/meter.png";
      news.priority = 2;
      news.title = "Probabilidades de Focos de incêncio.";
      news.description = "${highestProbabilities.city} está entre as cidades onde está previsto uma alta taxa de probabilidade de focos de queimadas para o dia de hoje ${DateTime.now().toLocal().day} de ${Utils.getMonthName()}.";
      listNews.add(news);

      news = NewsModel();
      news.assetsIcon = "assets/icons/weather/uv.png";
      news.priority = 2;
      news.title = "Intensidade dos Raios UV.";
      news.description = "${highestUvIndex.city} poderá registrar os maiores indices de raios UV durante o dia de toda a Chapada do Araripe, para o dia de hoje ${DateTime.now().toLocal().day} de ${Utils.getMonthName()}.";
      listNews.add(news);

      if (highestPrecipitation.city != null) {
        double precipitation = highestPrecipitation.getMaximumPrecipitation();
        if (precipitation > 1) {
          news = NewsModel();
          news.assetsIcon = "assets/icons/weather/rain.png";
          news.priority = 2;
          news.title = "Probabilidade de Chuvas.";
          if (precipitation > 10) {
            news.description = "${highestPrecipitation.city} irá registrar um periodo de chuva. Haverá um nível médio de precipitação de ${precipitation}mm.";
          } else {
            news.description = "${highestPrecipitation.city} irá registrar algum momento de chuva. Pois poderá haver até ${precipitation}mm de precipitação.";
          }
          listNews.add(news);
        }
      }
    }
  }

  void updateLists({bool force = false}) async {
    setState(() {
      loadingTop = true;
      loadingBottom = true;
    });
    await appRepository.updateLocal();
    updatePrediction();
    updateWeather();
    //updateProbabilities();
    listNews.shuffle();

    List<PredictionCityModel> predictionCities = appRepository.getPredictionCities;
    listCities = appRepository.getWeatherCities;
    //List<ForecastCityModel> probabilitiesCities = appRepository.getForecastCities;
    bool a = predictionCities.isEmpty || appRepository.allowUpdatePrediction() || force;
    bool b = listCities.isEmpty || appRepository.allowUpdateWeather() || force;
    setState(() {
      loadingTop = a;
      loadingBottom = b;
    });
    if (a) {
      await appRepository.updatePrediction(DateTime.now().year);
      updatePrediction();
      if (mounted) {
        setState(() {
          loadingTop = false;
        });
      }
    }
    if (b) {
      await appRepository.updateWeather();
      updateWeather();
      if (mounted) {
        setState(() {
          loadingBottom = false;
        });
      }
    }
    /*
    if (probabilitiesCities.isEmpty || appRepository.allowUpdateForecast()) {
      await appRepository.updateforecast();
      updateProbabilities();
    }
    */
    if (loadingTop || loadingBottom) {
      if (mounted) {
        setState(() {
          loadingTop = false;
          loadingBottom = false;
        });
      }
    }
  }

  @override
  void initState() {
    appRepository.addUpdateListener((errorCode) {
      if (errorCode == null) {
        if (mounted) {
          setState(() {
            loadingTop = appRepository.updatingPrediction;
            loadingBottom = appRepository.updatingWeather;
          });
        }
      }
    });
    imageProfile = user.getProfileImage();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      Connectivity connectivity = Connectivity();
      List<ConnectivityResult> list = await connectivity.checkConnectivity();
      connected = list.any((item) => item != ConnectivityResult.none);
      connectivity.onConnectivityChanged.listen((list) {
        if (mounted) {
          setState(() {
            connected = list.any((item) => item != ConnectivityResult.none);
          });
        }
      });

      updateLists();

      if (preferences.containsKey('from_notification_type') && preferences.getInt('from_notification_type') == Constants.NOTIFICATION_ID_INTERNAL_ALERTS) {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => const FiresAlertValidationPage()));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    //double width = MediaQuery.of(context).size.width;
    //log("width: $width, pixelRatio: ${View.of(context).display.devicePixelRatio * 160}");
    double imageWidth = MediaQuery.of(context).size.width * 1.2;

    return Stack(children: [
      ContainerGradient(
          colors: AppColors.gradientSky,
          duration: const Duration(seconds: 30),
          child: Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const SizedBox(),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Container(transform: Matrix4.translationValues(0, 2, 0), child: ImageTransitionScroller(duration: const Duration(seconds: 10), assets: "assets/images/minimal_forest.png", width: 493, height: imageWidth / 2.243)),
              Container(height: MediaQuery.of(context).size.height * 0.2, color: AppColors.appBackground)
            ])
          ])),
      Column(children: [
        const SizedBox(height: 16),
        Container(
            padding: const EdgeInsets.all(24),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              /*
              const Column( // logo antigo
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text("Monitor", style: TextStyle(color: Colors.white, fontSize: 48, fontFamily: 'MontBlancLight')), Text("de Queimadas Cariri", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
                  */
              Image.asset('assets/images/monitor_queimadas_cariri.png', width: 184, height: 72),
              FutureBuilder(
                  future: imageProfile,
                  builder: (context, result) {
                    if (result.connectionState == ConnectionState.done) {
                      String? name = user.getName();
                      if (result.hasError || result.data == null) {
                        if (name == null) return getProfileButton();
                        return getProfileButton(name: name);
                      }
                      return Column(mainAxisSize: MainAxisSize.min, children: [
                        SizedBox(
                            width: 56,
                            height: 56,
                            child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 36,
                                child: ClipOval(
                                    child: Stack(children: [
                                  Image(image: FileImage(result.data as File), width: 52, height: 52),
                                  Positioned.fill(
                                      child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            splashColor: Colors.white.withOpacity(0.75),
                                            onTap: () => profileClick(),
                                          )))
                                ])))),
                        const SizedBox(height: 4),
                        Text(
                          name ?? "Visitante",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "RobotoCondensedLight"),
                        )
                      ]);
                    }
                    return getProfileButton(loading: true);
                  })
            ])),
        Expanded(
            child: CustomScrollView(
          slivers: [
            SliverFillRemaining(hasScrollBody: false, child: getMainContent()),
          ],
        )),
      ])
    ]);
  }

  Widget getMainContent() {
    if (loadingTop && listNews.isEmpty && loadingBottom && listCities.isEmpty) {
      if (connected) {
        return Center(
            child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.25), shape: BoxShape.rectangle, borderRadius: const BorderRadius.all(Radius.circular(36))),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 3,
                      )),
                  SizedBox(width: 16),
                  Text("Carregando dados...", style: TextStyle(color: Colors.white))
                ])));
      } else {
        return BaseWidgets().getCenteredError("Sem conexão!", iconColor: AppColors.accent, textColor: Colors.white);
      }
    }
    if (listNews.isEmpty && !loadingTop && listCities.isEmpty && !loadingBottom) {
      return BaseWidgets().getCenteredError("Falha ao obter dados!", iconColor: AppColors.accent, textColor: Colors.white);
    } else if (listNews.isNotEmpty && listCities.isNotEmpty) {
      return Column(children: [_getTopContent(), const SizedBox(height: 16), _getBottomContent()]);
    } else {
      List<Widget> widgets = [];
      if (listNews.isNotEmpty) {
        widgets.add(_getTopContent());
      } else if (loadingTop) {
        widgets.add(SizedBox(height: 220, child: BaseWidgets().getCenteredloading("Carregando noticias...")));
      } else {
        widgets.add(SizedBox(height: 220, child: BaseWidgets().getCenteredError("Falha ao obter dados!", iconColor: AppColors.accent, textColor: Colors.white)));
      }

      if (listCities.isNotEmpty) {
        widgets.add(_getBottomContent());
      } else if (loadingBottom) {
        widgets.add(Column(children: [const SizedBox(height: 120), BaseWidgets().getCenteredloading("Carregando noticias...")]));
      } else {
        widgets.add(Column(children: [const SizedBox(height: 120), BaseWidgets().getCenteredError("Falha ao obter dados!", iconColor: AppColors.accent, textColor: Colors.white)]));
      }
      return Column(children: widgets);
    }
  }

  String retrieveName(String completeName) {
    String name = "";
    if (completeName.contains(" ")) {
      List<String> segments = completeName.split(" ");
      name = segments[0];
      for (int i = 1; i < segments.length - 1; i++) {
        if (segments[i].length < 3) continue;
        name += ' ${segments[i].substring(0, 1)}';
      }
      name += ' ${segments[segments.length - 1]}';
    } else {
      name = completeName;
    }
    return name;
  }

  Widget getProfileButton({String name = "Visitante", bool loading = false}) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
          width: 56,
          height: 56,
          child: ElevatedButton(
            onPressed: () => profileClick(),
            style: ButtonStyle(
                //foregroundColor: colorsStateText,
                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(EdgeInsetsDirectional.zero),
                elevation: WidgetStateProperty.all<double>(0.0),
                overlayColor: WidgetStateProperty.resolveWith((states) => AppColors.accent),
                backgroundColor: WidgetStateProperty.all<Color>(AppColors.ticketColor),
                shape: WidgetStateProperty.all<OvalBorder>(const OvalBorder())),
            child: loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent)) : const Icon(Icons.person_outline),
          )),
      const SizedBox(height: 4),
      Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "RobotoCondensedLight")),
    ]);
  }

  Widget _getTopContent() {
    List<PredictionCityModel> predictionCities = appRepository.getPredictionCities;
    int predictionTotal = 0;
    int occurredTotal = 0;
    for (PredictionCityModel model in predictionCities) {
      predictionTotal += model.predictionTotal ?? 0;
      occurredTotal += model.occurredTotal ?? 0;
    }
    return Column(children: [
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(mainAxisSize: MainAxisSize.max, children: [
            getCardNumber("Focos ${DateTime.now().year}", "$occurredTotal", "assets/icons/brown_fire.png"),
            const SizedBox(width: 8),
            getCardNumber("Previsto ${DateTime.now().year}", "$predictionTotal", "assets/icons/brown_search.png"),
            const SizedBox(width: 8),
            getCardNumber("Cidades", predictionCities.isEmpty ? "" : "${predictionCities.length}", "assets/icons/brown_pin.png")
          ])),
      Container(
          padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
          height: 56,
          child: Row(children: [
            Expanded(
                child: TextButton(
                    style: ButtonStyle(
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                        backgroundColor: WidgetStateProperty.resolveWith((states) => AppColors.ticketColor),
                        overlayColor: WidgetStateProperty.resolveWith((states) => AppColors.accent.withOpacity(0.5))),
                    onPressed: () async {
                      await Future.delayed(const Duration(milliseconds: 250));
                      await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AboutPage()));
                    },
                    child: const Text("Sobre o Projeto", style: TextStyle(fontSize: 18, color: AppColors.descriptionDark)))),
            const SizedBox(width: 16),
            Expanded(
                child: TextButton(
                    style: ButtonStyle(
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                        backgroundColor: WidgetStateProperty.resolveWith((states) => AppColors.ticketColor),
                        overlayColor: WidgetStateProperty.resolveWith((states) => AppColors.accent.withOpacity(0.5))),
                    onPressed: () async {
                      await Future.delayed(const Duration(milliseconds: 250));
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => const FiresAlertValidationPage()));
                    },
                    child: const Text("Últimas Alertas", style: TextStyle(fontSize: 18, color: AppColors.descriptionDark))))
          ])),
      const SizedBox(height: 16),
      Align(
          alignment: Alignment.topLeft,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Row(mainAxisSize: MainAxisSize.max, children: [
                if (loadingTop)
                  const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )),
                if (loadingTop) const SizedBox(width: 8),
                Text(loadingTop ? "Carregando eventos..." : "Utimos eventos", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 1, color: Colors.white))
              ]))),
      getTickets(),
    ]);
  }

  Widget _getBottomContent() {
    if (listCities.isNotEmpty) {
      return Expanded(
          child: Column(
        children: [
          Align(
              alignment: Alignment.topLeft,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Row(mainAxisSize: MainAxisSize.max, children: [
                    if (loadingBottom)
                      const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )),
                    if (loadingBottom) const SizedBox(width: 8),
                    Text(loadingBottom ? "Carregando cidades" : "Cidades monitoradas", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(child: Container(height: 1, color: Colors.white))
                  ]))),
          Flexible(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                      children: List.generate(listCities.length + 1, (index) {
                    if (index == listCities.length) return const SizedBox(height: 72);
                    return Column(children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.ticketColor, borderRadius: BorderRadius.circular(24)),
                        width: double.maxFinite,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(listCities[index].city!, style: const TextStyle(color: AppColors.titleDark, fontSize: 18, fontWeight: FontWeight.bold)),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text("${listCities[index].temperature!}º", style: const TextStyle(color: AppColors.descriptionDark, fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("Dias sem chuva:${listCities[index].daysWithoutRain!}", style: const TextStyle(color: AppColors.descriptionDark, fontSize: 16, fontWeight: FontWeight.bold)),
                          ])
                        ]),
                      ),
                      SizedBox(height: index < listCities.length - 1 ? 8 : 24)
                    ]);
                  }))))
        ],
      ));
    }
    return Expanded(child: BaseWidgets().getCenteredloading("Carregando Cidades..."));
  }

  Widget getTickets() {
    double height = 150;
    return Container(
        transform: Matrix4.translationValues(-4, 0, 0),
        width: double.maxFinite,
        height: height,
        child: OverflowBox(
            maxWidth: MediaQuery.of(context).size.width + 32,
            maxHeight: height,
            child: PageView(
                physics: const ClampingScrollPhysics(),
                controller: PageController(initialPage: 0, viewportFraction: 0.8),
                children: List.generate(listNews.length, (index) {
                  //return Container(color: Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0));
                  return Container(
                      padding: const EdgeInsets.only(right: 16),
                      child: TicketView(
                          child: Container(
                              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                              color: AppColors.ticketColor,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Expanded(child: Text(listNews[index].title!, maxLines: 2, style: const TextStyle(height: 1.2, color: AppColors.titleDark, fontSize: 20, fontWeight: FontWeight.w400))),
                                  const SizedBox(width: 8),
                                  Image.asset(listNews[index].assetsIcon!, height: 30),
                                ]),
                                const SizedBox(height: 8),
                                Expanded(child: AutoSizeText(listNews[index].description!, maxLines: 5, style: const TextStyle(height: 1.2, color: AppColors.descriptionDark, fontSize: 16, fontWeight: FontWeight.bold))),
                              ]))));
                }))));
  }

  Widget getCardNumber(String title, String value, String assetsIcon) {
    switch (value.length) {
      case 1:
        value = "000$value";
        break;
      case 2:
        value = "00$value";
        break;
      case 3:
        value = "0$value";
        break;
    }
    return Expanded(
        child: Container(
      height: 115,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: AppColors.ticketColor, borderRadius: BorderRadius.circular(16)),
      child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 16, color: AppColors.titleDark, fontWeight: FontWeight.bold)),
        if (value.isNotEmpty)
          FittedBox(
              child: Row(children: [
            Text(value, style: const TextStyle(fontSize: 36, color: AppColors.descriptionDark, fontWeight: FontWeight.w300)),
            const SizedBox(width: 8),
            Image.asset(assetsIcon, height: 30),
          ])),
      ]),
    ));
  }

  @override
  bool get wantKeepAlive => true;
}
