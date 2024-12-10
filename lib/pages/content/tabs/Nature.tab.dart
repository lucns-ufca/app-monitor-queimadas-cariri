import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:monitor_queimadas_cariri/models/PredictionCity.model.dart';
import 'package:monitor_queimadas_cariri/repositories/App.repository.dart';
import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:monitor_queimadas_cariri/widgets/CardsCities.widget.dart';

class TabNaturePage extends StatefulWidget {
  const TabNaturePage({super.key});

  @override
  State<StatefulWidget> createState() => TabNaturePageState();
}

class TabNaturePageState extends State<TabNaturePage> with AutomaticKeepAliveClientMixin<TabNaturePage> {
  final appRepository = GetIt.I.get<AppRepository>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    List<PredictionCityModel> predictionCities = appRepository.getPredictionCities;
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.fragmentBackground, Color.fromARGB(255, 231, 173, 97)],
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 48),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Image.asset('assets/images/monitor_queimadas_cariri.png', width: 122, height: 48),
              const SizedBox(
                width: 24,
              ),
              const Text("Um pouco\ndo cariri", textAlign: TextAlign.end, style: TextStyle(height: 1.2, fontWeight: FontWeight.w300, color: Colors.white, fontSize: 22)),
            ])),
        const SizedBox(height: 24),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(mainAxisSize: MainAxisSize.max, children: [
              Text("${predictionCities.length} Cidades da Chapada do Araripe", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(child: Container(height: 1, color: Colors.white))
            ])),
        const CardsCities()
      ]),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
