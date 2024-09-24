import 'package:app_monitor_queimadas/models/PredictionCity.model.dart';
import 'package:app_monitor_queimadas/pages/content/BaseWidgets.dart';
import 'package:app_monitor_queimadas/repositories/App.repository.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:app_monitor_queimadas/utils/Utils.dart';
import 'package:app_monitor_queimadas/widgets/ContainerGradient.widget.dart';
import 'package:app_monitor_queimadas/widgets/GaugeChart.widget.dart';
import 'package:app_monitor_queimadas/widgets/charts/ChartGrid.widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get_it/get_it.dart';

class TabStatisticsPage extends StatefulWidget {
  const TabStatisticsPage({super.key});

  @override
  State<StatefulWidget> createState() => TabStatisticsPageState();
}

class TabStatisticsPageState extends State<TabStatisticsPage> {
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

    setState(() {});

    if (predictionCities!.isEmpty || appRepository.allowUpdatePrediction()) {
      await appRepository.updatePrediction();
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
    return Stack(children: [
      const ContainerGradient(colors: AppColors.gradientDark, duration: Duration(seconds: 30), child: Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [])),
      Column(children: [
        const SizedBox(height: 24),
        Container(
            padding: const EdgeInsets.only(left: 16),
            width: double.maxFinite,
            child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [Text("Metricas", style: TextStyle(color: Colors.white, fontSize: 36, fontFamily: 'MontBlancLight')), Text("Gerais", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500))])),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(16), child: getMainContent())
      ])
    ]);
  }

  Widget getMainContent() {
    if (connected) {
      if (predictionCities != null && predictionCities!.isNotEmpty) {
        double size = MediaQuery.of(context).size.width * 0.5;
        return Column(children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                  width: size,
                  height: size,
                  child: Stack(children: [
                    GaugeChart(progress: percentage),
                    Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text("$occurredTotal/$predictionTotal", style: const TextStyle(color: AppColors.textNormal, fontWeight: FontWeight.w300, fontSize: 24)),
                      const Text("Previsto anual", style: TextStyle(fontWeight: FontWeight.w300, color: AppColors.textNormal)),
                      const SizedBox(height: 2),
                      Text("Restando ${Utils.getRemainderDays()} dias", style: const TextStyle(fontWeight: FontWeight.w300, color: AppColors.accentLight, fontSize: 12)),
                      const SizedBox(height: 16)
                    ]))
                  ])),
              const SizedBox(width: 24),
              Expanded(
                  child: SizedBox(
                      height: size - 44,
                      child: Stack(children: [
                        GaugeChart(progress: percentage2),
                        Center(
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Text("$ocurrencesForCurrentMonth/$predictedForCurrentMonth", style: const TextStyle(color: AppColors.textNormal, fontWeight: FontWeight.w300, fontSize: 14)),
                          Text(Utils.getMonthName(), style: const TextStyle(fontWeight: FontWeight.w300, color: AppColors.textNormal, fontSize: 12)),
                          const SizedBox(height: 16)
                        ]))
                      ])))
            ],
          ),
          Container(
            decoration: const BoxDecoration(color: AppColors.shadow, borderRadius: BorderRadius.all(Radius.circular(24))),
            child: const ChartGrid(),
          )
        ]);
      }
      if (loading) {
        return BaseWidgets().getCenteredloading("Carregando dados...");
      }
      return BaseWidgets().getCenteredError("Falha na tratativa dos dados!");
    }
    return BaseWidgets().getCenteredError("Sem conexão!");
  }
}
