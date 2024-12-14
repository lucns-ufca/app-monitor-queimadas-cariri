import 'dart:math' as math;

import 'package:get_it/get_it.dart';
import 'package:monitor_queimadas_cariri/models/WeatherCity.model.dart';
import 'package:monitor_queimadas_cariri/repositories/App.repository.dart';
import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:monitor_queimadas_cariri/utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:monitor_queimadas_cariri/widgets/GaugeChart.widget.dart';

class CardsCities extends StatefulWidget {
  const CardsCities({super.key});

  @override
  State<StatefulWidget> createState() => CardsCitiesState();
}

class CardsCitiesState extends State<CardsCities> {
  PageController pageController = PageController(initialPage: 0, viewportFraction: 0.9);
  double dx = 0;
  final List<int> numbers = [];
  final List<String> cityNames = Constants.CITIES_DATA.keys.toList();
  final Map<String, dynamic> gaugeControllers = {};
  final Map<String, dynamic> descriptions = {};
  final AppRepository appRepository = GetIt.I.get<AppRepository>();

  @override
  void initState() {
    appRepository.setOnUpdateConcluded(() {
      if (mounted) setState(() {});
    });
    for (String city in cityNames) {
      gaugeControllers[city] = ProgressController();
      descriptions[city] = generageCardDescription(Constants.CITIES_DATA[city]);
    }
    super.initState();
    for (int i = 1; i < 31; i++) {
      numbers.add(i);
    }
    numbers.shuffle();
    pageController.addListener(() {
      setState(() {
        dx = pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    appRepository.setOnUpdateConcluded(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: SafeArea(
            child: PageView.builder(
                physics: const ClampingScrollPhysics(),
                controller: pageController,
                itemCount: Constants.CITIES_DATA.length,
                onPageChanged: (index) {},
                itemBuilder: (context, index) {
                  double alignmentX = -(dx - index) * 8;
                  return Container(
                      padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                      child: Column(children: [
                        Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                                height: MediaQuery.of(context).size.width / 1.87,
                                width: double.maxFinite,
                                decoration: BoxDecoration(
                                    boxShadow: const [
                                      BoxShadow(
                                        color: AppColors.shadow,
                                        spreadRadius: 4,
                                        blurRadius: 4,
                                        offset: Offset(0, 0),
                                      ),
                                    ],
                                    image: DecorationImage(
                                      image: AssetImage("assets/images/cards_background/${numbers[index]}.jpg"),
                                      fit: BoxFit.cover,
                                      alignment: Alignment(alignmentX, 0),
                                    ),
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(36), topRight: Radius.circular(36))),
                                child: Stack(children: [
                                  Positioned.fill(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          stops: const [0.6, 0.95],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      bottom: 8,
                                      left: 24,
                                      child: Text(
                                        cityNames[index],
                                        style: const TextStyle(color: AppColors.textNormal, fontSize: 24, fontWeight: FontWeight.w400),
                                      ))
                                ]))),
                        Expanded(
                            child: Container(
                                width: double.maxFinite,
                                decoration: const BoxDecoration(boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadow,
                                    spreadRadius: 4,
                                    blurRadius: 4,
                                    offset: Offset(0, 0),
                                  ),
                                ], color: Color.fromARGB(255, 255, 216, 171), borderRadius: BorderRadius.only(bottomRight: Radius.circular(36), bottomLeft: Radius.circular(36))),
                                child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(children: [
                                      Expanded(
                                          child: SingleChildScrollView(
                                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Center(child: Image.asset('assets/images/flower_divider.png', color: AppColors.fragmentBackground, height: 40)),
                                        const SizedBox(height: 16),
                                        const Text(
                                          "Detalhes",
                                          style: TextStyle(color: AppColors.appBackground, fontSize: 18, fontWeight: FontWeight.w800),
                                        ),
                                        Text(descriptions[cityNames[index]], textAlign: TextAlign.justify, style: TextStyle(color: AppColors.appBackground, fontSize: 16)),
                                      ]))),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                          height: 130,
                                          width: double.maxFinite,
                                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                            const Text(
                                              "Probabilidade de ocorrencias e clima",
                                              style: TextStyle(color: AppColors.appBackground, fontSize: 18, fontWeight: FontWeight.w800),
                                            ),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                  Text("Temperatura:", style: TextStyle(color: AppColors.appBackground)),
                                                  Text("Humidade:", style: TextStyle(color: AppColors.appBackground)),
                                                  Text("Nivel de CO²:", style: TextStyle(color: AppColors.appBackground)),
                                                  Text("Índice UV:", style: TextStyle(color: AppColors.appBackground)),
                                                ]),
                                                getValuesWidget(appRepository.updatingWeather, weather: getCityModel(cityNames[index]))
                                              ],
                                            )
                                          ]))
                                    ])))),
                        const SizedBox(height: 24)
                      ]));
                })));
  }

  WeatherCityModel? getCityModel(String city) {
    try {
      return appRepository.getWeatherCities.firstWhere((item) => item.city == city);
    } catch (_) {}
    return null;
  }

  Widget getValuesWidget(bool loading, {WeatherCityModel? weather}) {
    return Expanded(
        child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                    visible: !loading && weather == null,
                    child: const Expanded(
                        child: SizedBox(
                            height: 100,
                            child: Center(
                                child: Text(
                              "Falha na conexão!",
                              style: TextStyle(color: AppColors.red, fontSize: 12),
                            ))))),
                if (!loading && weather != null)
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("${weather.temperature}º", style: const TextStyle(color: AppColors.appBackground, fontWeight: FontWeight.bold)),
                    Text("${weather.humidity}%", style: const TextStyle(color: AppColors.appBackground, fontWeight: FontWeight.bold)),
                    Text("${weather.carbonMonoxide!.toInt()}ppm", style: const TextStyle(color: AppColors.appBackground, fontWeight: FontWeight.bold)),
                    Text("${weather.uvIndex}", style: const TextStyle(color: AppColors.appBackground, fontWeight: FontWeight.bold)),
                  ]),
                if (loading)
                  const Expanded(
                      child: SizedBox(
                          height: 100,
                          child: Center(
                              child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: AppColors.appBackground,
                                    strokeWidth: 3,
                                  ))))),
                Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: GaugeChart(
                      progressController: weather == null ? null : gaugeControllers[weather.city],
                      size: 96,
                      progress: weather == null ? 0 : weather.fireRisk!.toDouble(),
                      child: loading || weather == null ? const SizedBox() : Text("${weather.fireRisk}%", style: const TextStyle(color: AppColors.appBackground, fontWeight: FontWeight.w800, fontSize: 24)),
                    ))
              ],
            )));
  }

  String generageCardDescription(CityData cityData) {
    String description = "";
    Tuple geograficalArea = cityData.geographicalArea;
    Tuple urbanizedArea = cityData.urbanizedArea;
    Tuple population = cityData.population;

    math.Random random = math.Random();
    for (int i = 0; i < 3; i++) {
      int position = random.nextInt(3);
      switch (i) {
        case 0:
          switch (position) {
            case 0:
              description = "No censo ${population.key}, foi registrado ${population.value} habitantes.";
              break;
            case 1:
              description = "Foi registrado ${population.value} habitantes no censo ${population.key}.";
              break;
            default:
              description = "Em ${population.key} havia um registro de ${population.value} habitantes.";
              break;
          }
          break;
        case 1:
          switch (position) {
            case 0:
              description = "$description A área urbanizada da cidade estava em torno de ${urbanizedArea.value}. Sendo o total em quilometros quadrados de área era de ${geograficalArea.value}.";
              break;
            case 1:
              description = "$description O total em quilometros quadrados de ária era de ${geograficalArea.value}. E a área urbanizada da cidade estava em torno de ${urbanizedArea.value}.";
              break;
            default:
              description = "$description A cidade possui uma média de ${urbanizedArea.value}km² de área urbanizada. E possui em torno de ${geograficalArea.value}km² de área geografica.";
              break;
          }
          break;
        default:
          switch (position) {
            case 0:
              description = "$description Abaixo está um pouco sobre o clima da região verde que rodeia a cidade.";
              break;
            case 1:
              description = "$description Mais em baixo contém dados climaticos referente a área verde da região.";
              break;
            default:
              description = "$description Há informações logo abaixo, sobre o clima da região florestal da área.";
              break;
          }
          break;
      }
    }
    return description;
  }
}
