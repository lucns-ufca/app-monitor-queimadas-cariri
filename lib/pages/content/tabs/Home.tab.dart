import 'dart:async';
import 'dart:io';

import 'package:app_monitor_queimadas/models/PredictionCity.model.dart';
import 'package:app_monitor_queimadas/models/ProbabilityCity.model.dart';
import 'package:app_monitor_queimadas/models/User.model.dart';
import 'package:app_monitor_queimadas/models/WeatherCity.model.dart';
import 'package:app_monitor_queimadas/models/content/News.model.dart';
import 'package:app_monitor_queimadas/pages/content/AboutProject.page.dart';
import 'package:app_monitor_queimadas/pages/content/IpDefinition.page.dart';
import 'package:app_monitor_queimadas/pages/dialogs/PopupMenu.dart';
import 'package:app_monitor_queimadas/pages/start/Acess.page.dart';
import 'package:app_monitor_queimadas/pages/start/First.page.dart';
import 'package:app_monitor_queimadas/repositories/App.repository.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:app_monitor_queimadas/utils/Utils.dart';
import 'package:app_monitor_queimadas/widgets/ContainerGradient.widget.dart';
import 'package:app_monitor_queimadas/widgets/ImageTransitionScroller.widget.dart';
import 'package:app_monitor_queimadas/widgets/TicketView.widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';

class TabHomePage extends StatefulWidget {
  const TabHomePage({super.key});

  @override
  State<StatefulWidget> createState() => TabHomePageState();
}

class TabHomePageState extends State<TabHomePage> {
  final user = GetIt.I.get<User>();
  final appRepository = GetIt.I.get<AppRepository>();
  bool runColor = false;
  bool loadingTop = true;
  bool loadingBottom = true;
  bool connected = true;
  List<NewsModel> listNews = [];
  List<WeatherCityModel> listCities = [];
  StreamSubscription<List<ConnectivityResult>>? subscription;
  Future<File?>? imageProfile;
  PredictionCityModel? selectedHighestOccurred;
  PredictionCityModel? selectedCurrentMonthHighestOccurred;

  void profileClick() async {
    if (user.hasAccess()) {
      showMenuWindow();
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const AccessPage()));
    }
  }

  void showMenuWindow() {
    PopupMenu popupMenu = PopupMenu(context: context);
    List<String> titles = ["Definir IP", if (!user.hasAccess()) "Login", if (user.hasAccess()) "Validação de queimadas", "Sobre o Projeto", if (user.hasAccess()) "Logout"];
    var items = popupMenu.generateIds(titles);
    popupMenu.showMenu(items, (index) async {
      switch (items[index].text) {
        case "Definir IP":
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const IpDefinitionPage()));
          break;
        case "Login":
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AccessPage()));
          break;
        case "Sobre o Projeto":
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AboutPage()));
        case "Logout":
          user.clear();
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FirstPage()));
          break;
      }
    });
  }

  Future<void> updateWeather() async {
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
      news.priority = 2;
      news.title = "${highestTemperature.city} com máxima de ${highestTemperature.temperature}º.";
      news.description = "A cidade ${highestTemperature.city} poderá registrar temperaturas altas, em comparação com toda chapada do araripe, registrando na faixa dos ${highestTemperature.temperature}º.";
      listNews.add(news);
      if (highestDaysWithoutRain.daysWithoutRain! > 0) {
        news = NewsModel();
        news.priority = 2;
        news.title = "Dias sem Chuva.";
        news.description = "Atualmente ${highestDaysWithoutRain.city} está com o maior numero de dias sem chuva. Foram registrados ${highestDaysWithoutRain.daysWithoutRain}.";
        listNews.add(news);
      }
    }
  }

  Future<void> updatePrediction() async {
    int currentMonth = DateTime.now().month;
    List<PredictionCityModel> predictionCities = appRepository.getPredictionCities;
    if (predictionCities.isNotEmpty) {
      for (PredictionCityModel model in predictionCities) {
        if (selectedHighestOccurred == null || model.occurredTotal! > selectedHighestOccurred!.occurredTotal!) {
          selectedHighestOccurred = model;
        }
        if (selectedCurrentMonthHighestOccurred == null || model.months![currentMonth - 1].fireOccurrences! > model.months![currentMonth - 1].fireOccurrences!) {
          selectedCurrentMonthHighestOccurred = model;
        }
      }
      NewsModel news = NewsModel();
      news.priority = 1;
      news.title = "Ocorreram ${selectedHighestOccurred!.occurredTotal} focos de incêndio.";
      news.description =
          "A região da Chapada do Araripe tem registrado ${selectedHighestOccurred!.occurredTotal} focos de queimadas só este ano. E este número tende a crescer. O atual previsto para o ano inteiro ta sendo de ${selectedHighestOccurred!.predictionTotal}.";
      listNews.add(news);
      news = NewsModel();
      news.priority = 1;
      news.title = "Focos corridos neste mês.";
      news.description = "Até o momento, ${selectedCurrentMonthHighestOccurred!.city} está com o maior numero de focos de queimadas ocorrida nesse mês de ${Utils.getMonthName()}.";
      listNews.add(news);
    }
  }

  Future<void> updateProbabilities() async {
    List<ProbabilityCityModel> probabilitiesCities = appRepository.getProbabilityCities;
    if (probabilitiesCities.isNotEmpty) {
      ProbabilityCityModel highestProbabilities = ProbabilityCityModel();
      ProbabilityCityModel highestUvIndex = ProbabilityCityModel();
      ProbabilityCityModel highestPrecipitation = ProbabilityCityModel();
      for (ProbabilityCityModel model in probabilitiesCities) {
        if (highestProbabilities.city == null || model.getMaximumProbability() > highestProbabilities.getMaximumProbability()) {
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
      news.priority = 2;
      news.title = "Probabilidades de Focos de incêncio.";
      news.description = "${highestProbabilities.city} está entre as cidades onde está previsto uma alta taxa de probabilidade de focos de queimadas para o dia de hoje ${DateTime.now().toLocal().day} de ${Utils.getMonthName()}.";
      listNews.add(news);

      news = NewsModel();
      news.priority = 2;
      news.title = "Intensidade dos Raios UV.";
      news.description = "${highestUvIndex.city} poderá registrar os maiores indices de raios UV durante o dia de toda a Chapada do Araripe, para o dia de hoje ${DateTime.now().toLocal().day} de ${Utils.getMonthName()}.";
      listNews.add(news);

      if (highestPrecipitation.city != null) {
        double precipitation = highestPrecipitation.getMaximumPrecipitation();
        if (precipitation > 1) {
          news = NewsModel();
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

  void updateLists() async {
    setState(() {
      loadingTop = true;
      loadingBottom = true;
    });
    await appRepository.updateLocal();
    updatePrediction();
    updateWeather();
    updateProbabilities();
    listNews.shuffle();

    List<PredictionCityModel> predictionCities = appRepository.getPredictionCities;
    listCities = appRepository.getWeatherCities;
    List<ProbabilityCityModel> probabilitiesCities = appRepository.getProbabilityCities;
    setState(() {});

    if (predictionCities.isEmpty || appRepository.allowUpdatePrediction()) {
      await appRepository.updatePrediction();
      await updatePrediction();
      setState(() {
        loadingTop = true;
        loadingBottom = false;
      });
    }
    if (listCities.isEmpty || appRepository.allowUpdateWeather()) {
      await appRepository.updateWeather();
      await updateWeather();
    }
    if (probabilitiesCities.isEmpty || appRepository.allowUpdateProbability()) {
      await appRepository.updateProbabilities();
      await updateProbabilities();
    }
    setState(() {
      loadingTop = false;
      loadingBottom = false;
    });
  }

  @override
  void initState() {
    imageProfile = user.getProfileImage();
    appRepository.setOnUpdateConcluded(() {});
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      Connectivity connectivity = Connectivity();
      List<ConnectivityResult> list = await connectivity.checkConnectivity();
      connected = list.any((item) => item != ConnectivityResult.none);
      setState(() {
        runColor = true;
      });
      subscription = connectivity.onConnectivityChanged.listen((list) {
        setState(() {
          connected = list.any((item) => item != ConnectivityResult.none);
        });
      });

      updateLists();
    });
    super.initState();
  }

  @override
  void dispose() {
    subscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ContainerGradient(
          colors: AppColors.gradientSky,
          duration: const Duration(seconds: 30),
          child: Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const SizedBox(),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Container(transform: Matrix4.translationValues(0, 2, 0), child: const ImageTransitionScroller(duration: Duration(seconds: 10), assets: "assets/images/minimal_forest.png", width: 493, height: 222)),
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
                      if (result.data == null) {
                        return getProfileButton();
                      }
                      String name = "";
                      if (user.name.contains(" ")) {
                        List<String> segments = user.name.split(" ");
                        name = segments[0];
                        for (int i = 1; i < segments.length - 1; i++) {
                          if (segments[i].length < 3) continue;
                          name += ' ${segments[i].substring(0, 1)}';
                        }
                        name += ' ${segments[segments.length - 1]}';
                      } else {
                        name = user.name;
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
                          name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "RobotoCondensedLight"),
                        )
                      ]);
                    }
                    return getProfileButton(loading: true);
                  }),
            ])),
        Expanded(child: getMainContent()),
        const SizedBox(height: 72)
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
                  Text("Carregando dados...\nA primeira vez pode levar até 30 segundos.", style: TextStyle(color: Colors.white))
                ])));
      } else {
        return Center(
            child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.25), shape: BoxShape.rectangle, borderRadius: const BorderRadius.all(Radius.circular(36))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [SvgPicture.asset("assets/icons/alert.svg", width: 16, height: 16), const SizedBox(width: 8), const Text("Sem conexão!", style: TextStyle(color: AppColors.red))])));
      }
    }
    if (listNews.isNotEmpty && listCities.isNotEmpty) {
      return Column(children: [_getTopContent(), const SizedBox(height: 16), _getBottomContent()]);
    } else if (listNews.isNotEmpty) {
      return Column(children: [_getTopContent(), const SizedBox(height: 16), Expanded(child: SizedBox(child: _getCenteredloading("Carregando cidades...")))]);
    } else {
      return Column(children: [SizedBox(height: 220, child: _getCenteredloading("Carregando noticias...")), const SizedBox(height: 16), _getBottomContent()]);
    }
  }

  Widget getProfileButton({bool loading = false}) {
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
      const Text("Visitante", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "RobotoCondensedLight")),
    ]);
  }

  Widget _getTopContent() {
    List<PredictionCityModel> predictionCities = appRepository.getPredictionCities;
    PredictionCityModel? chapadaAraripe;
    if (predictionCities.isNotEmpty) {
      chapadaAraripe = predictionCities.firstWhere((item) => item.city == "Chapada do Araripe");
    }
    return Column(children: [
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(mainAxisSize: MainAxisSize.max, children: [
            Expanded(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 75),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.ticketColor, borderRadius: BorderRadius.circular(16)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text("Focos de ${DateTime.now().year}", style: const TextStyle(fontSize: 16, color: AppColors.titleDark, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        if (selectedHighestOccurred != null) Text("${selectedHighestOccurred!.occurredTotal}", style: const TextStyle(fontSize: 36, color: AppColors.descriptionDark, fontWeight: FontWeight.w300)),
                      ]),
                    ))),
            const SizedBox(width: 8),
            Expanded(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 75),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.ticketColor, borderRadius: BorderRadius.circular(16)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text("Previsto ${DateTime.now().year}", style: const TextStyle(fontSize: 16, color: AppColors.titleDark, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        if (chapadaAraripe != null) Text("${chapadaAraripe.predictionTotal}", style: const TextStyle(fontSize: 36, color: AppColors.descriptionDark, fontWeight: FontWeight.w300)),
                      ]),
                    ))),
            const SizedBox(width: 8),
            Expanded(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 75),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.ticketColor, borderRadius: BorderRadius.circular(16)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text("Cidades", style: TextStyle(fontSize: 16, color: AppColors.titleDark, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        if (predictionCities.isNotEmpty) Text("${predictionCities.length - 1}", style: const TextStyle(fontSize: 36, color: AppColors.descriptionDark, fontWeight: FontWeight.w300)),
                      ]),
                    ))),
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
      getCards(),
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
                  child: SingleChildScrollView(
                      child: Column(
                          children: List.generate(listCities.length, (index) {
                    return Column(children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.ticketColor, borderRadius: BorderRadius.circular(24)),
                        width: double.maxFinite,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(listCities[index].city!, style: const TextStyle(color: AppColors.titleDark, fontSize: 24, fontWeight: FontWeight.bold)),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text("${listCities[index].temperature!}º", style: const TextStyle(color: AppColors.titleDark, fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("Dias sem chuva:${listCities[index].daysWithoutRain!}", style: const TextStyle(color: AppColors.titleDark, fontSize: 16, fontWeight: FontWeight.bold)),
                          ])
                        ]),
                      ),
                      SizedBox(height: index < listCities.length - 1 ? 8 : 24)
                    ]);
                  })))))
        ],
      ));
    }
    return Expanded(child: _getCenteredloading("Carregando Cidades..."));
  }

  Widget _getCenteredloading(String text) {
    return Center(
        child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.25), shape: BoxShape.rectangle, borderRadius: const BorderRadius.all(Radius.circular(36))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: AppColors.accent,
                    strokeWidth: 3,
                  )),
              const SizedBox(width: 16),
              Text(text, style: const TextStyle(color: Colors.white))
            ])));
  }

  Widget getCards() {
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
                                Text(listNews[index].title!, style: const TextStyle(height: 1.2, color: AppColors.titleDark, fontSize: 24, fontWeight: FontWeight.w400)),
                                const SizedBox(height: 8),
                                Expanded(child: SingleChildScrollView(child: Text(listNews[index].description!, style: const TextStyle(height: 1.2, color: AppColors.descriptionDark, fontSize: 16, fontWeight: FontWeight.bold)))),
                              ]))));
                }))));
  }
}
