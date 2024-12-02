import 'package:monitor_queimadas_cariri/models/PredictionCity.model.dart';
import 'package:monitor_queimadas_cariri/models/PredictionMonthly.model.dart';
import 'package:monitor_queimadas_cariri/pages/content/BaseWidgets.dart';
import 'package:monitor_queimadas_cariri/repositories/App.repository.dart';
import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:monitor_queimadas_cariri/utils/Utils.dart';
import 'package:monitor_queimadas_cariri/widgets/ContainerGradient.widget.dart';
import 'package:monitor_queimadas_cariri/widgets/GaugeChart.widget.dart';
import 'package:monitor_queimadas_cariri/widgets/charts/ChartGrid.widget.dart';
import 'package:monitor_queimadas_cariri/widgets/charts/PieChart.widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get_it/get_it.dart';

class TabStatisticsPage extends StatefulWidget {
  const TabStatisticsPage({super.key});

  @override
  State<StatefulWidget> createState() => TabStatisticsPageState();
}

class TabStatisticsPageState extends State<TabStatisticsPage> with AutomaticKeepAliveClientMixin<TabStatisticsPage> {
  bool connected = true;
  final appRepository = GetIt.I.get<AppRepository>();
  List<PredictionCityModel>? predictionCities;
  bool loading = true;
  int occurredTotal = 0;
  int predictionTotal = 0;
  int ocurrencesForCurrentMonth = 0;
  int predictedForCurrentMonth = 0;
  double percentage = 0;
  double percentage2 = 0;
  PredictionCityModel? chapadaAraripe;

  void updateLists() async {
    setState(() {
      loading = true;
    });
    await appRepository.updateLocal();
    occurredTotal = 0;
    predictionTotal = 0;
    ocurrencesForCurrentMonth = 0;
    predictedForCurrentMonth = 0;
    predictionCities = appRepository.getPredictionCities;
    int currentMonth = DateTime.now().month;
    if (predictionCities!.isNotEmpty) {
      for (PredictionCityModel city in predictionCities!) {
        occurredTotal += city.occurredTotal!;
        predictionTotal += city.predictionTotal!;
        ocurrencesForCurrentMonth += city.months![currentMonth - 1].fireOccurrences!;
        predictedForCurrentMonth += city.months![currentMonth - 1].firesPredicted!;
      }
    }
    percentage = (occurredTotal / predictionTotal) * 100.0;
    if (percentage > 100) percentage = 100;
    percentage2 = (ocurrencesForCurrentMonth / predictedForCurrentMonth) * 100.0;
    if (percentage2 > 100) percentage2 = 100;

    chapadaAraripe = PredictionCityModel();
    chapadaAraripe!.months = List.generate(12, (index) => PredictionMonthlyModel(fireOccurrences: 0, firesPredicted: 0));
    chapadaAraripe!.occurredTotal = occurredTotal;
    chapadaAraripe!.predictionTotal = predictionTotal;
    for (PredictionCityModel city in predictionCities!) {
      for (int i = 0; i < currentMonth; i++) {
        chapadaAraripe!.months![i].fireOccurrences = chapadaAraripe!.months![i].fireOccurrences! + city.months![i].fireOccurrences!;
        chapadaAraripe!.months![i].firesPredicted = chapadaAraripe!.months![i].firesPredicted! + city.months![i].firesPredicted!;
      }
    }
    setState(() {});

    if (predictionCities!.isEmpty || appRepository.allowUpdatePrediction()) {
      await appRepository.updatePrediction(DateTime.now().year);
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      Connectivity connectivity = Connectivity();
      List<ConnectivityResult> list = await connectivity.checkConnectivity();
      connected = list.any((item) => item != ConnectivityResult.none);
      connectivity.onConnectivityChanged.listen((list) {
        setState(() {
          connected = list.any((item) => item != ConnectivityResult.none);
        });
      });

      updateLists();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(children: [
      const ContainerGradient(colors: AppColors.gradientDark, duration: Duration(seconds: 30), child: Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [])),
      Column(children: [
        const SizedBox(height: 36),
        Container(
            padding: const EdgeInsets.only(left: 16),
            width: double.maxFinite,
            child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [Text("Métricas", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w200)), Text("Gerais de Predição", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w300))])),
        const SizedBox(height: 16),
        Expanded(
            child: CustomScrollView(
          slivers: [
            SliverFillRemaining(hasScrollBody: false, child: getMainContent()),
          ],
        ))
      ])
    ]);
  }

  Widget getMainContent() {
    if (connected) {
      if (predictionCities != null && predictionCities!.isNotEmpty) {
        double size = MediaQuery.of(context).size.width * 0.6;
        double space = 16;
        double padding = 8;
        double size2 = (MediaQuery.of(context).size.width * 0.4) - (2 * padding) - space;
        return SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GaugeChart(
                    size: size,
                    progress: percentage,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text("$occurredTotal/$predictionTotal", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 24)),
                      const Text("Previsto anual", style: TextStyle(fontWeight: FontWeight.w300, color: AppColors.white_2)),
                      const SizedBox(height: 2),
                      Text("Restando ${Utils.getRemainderDays()} dias", style: const TextStyle(fontWeight: FontWeight.w400, color: AppColors.accentLight, fontSize: 12)),
                      const SizedBox(height: 16)
                    ]),
                  ),
                  SizedBox(width: space),
                  Expanded(
                      child: Column(children: [
                    SizedBox(
                      width: size2,
                      height: size2,
                      child: SizedBox(
                          width: size2,
                          height: size2,
                          child: GaugeChart(
                              progress: percentage2,
                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                                Text("$ocurrencesForCurrentMonth/$predictedForCurrentMonth", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w300, fontSize: 14)),
                                Text(Utils.getMonthName(), style: const TextStyle(fontWeight: FontWeight.w300, color: AppColors.white_2, fontSize: 12)),
                                const SizedBox(height: 8)
                              ]))),
                    ),
                    const SizedBox(
                      height: 24,
                    )
                  ]))
                ],
              )),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [const Text("Ano Selecionado", style: TextStyle(color: AppColors.white_5, fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(width: 8), Expanded(child: Container(height: 1, color: AppColors.white_5))])),
          const SizedBox(height: 16),
          Container(
            decoration: const BoxDecoration(color: AppColors.shadow, borderRadius: BorderRadius.all(Radius.circular(4))),
            child: Column(children: [
              Container(
                  padding: const EdgeInsets.only(left: 16, top: 8),
                  child: Row(children: [
                    Container(width: 8, height: 8, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text("Ocorrido", style: TextStyle(color: Colors.white, fontSize: 12)),
                    const SizedBox(width: 16),
                    Container(width: 8, height: 8, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text("Predito", style: TextStyle(color: Colors.white, fontSize: 12))
                  ])),
              ChartGrid(
                city: chapadaAraripe!,
              ),
              const SizedBox(height: 16),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child:
                      Row(children: [const Text("Cidades de maior ocorrência", style: TextStyle(color: AppColors.white_5, fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(width: 8), Expanded(child: Container(height: 1, color: AppColors.white_5))])),
              PieChartSample(predictionCities: predictionCities!),
              const SizedBox(height: 72),
            ]),
          )
        ]));
      }
      if (loading) {
        return BaseWidgets().getCenteredloading("Carregando dados...");
      }
      return BaseWidgets().getCenteredError("Falha na tratativa dos dados!");
    }
    return BaseWidgets().getCenteredError("Sem conexão!");
  }

  @override
  bool get wantKeepAlive => true;
}
