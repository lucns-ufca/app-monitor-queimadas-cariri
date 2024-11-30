import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:monitor_queimadas_cariri/utils/Constants.dart';
import 'package:flutter/material.dart';

class CardsCities extends StatefulWidget {
  const CardsCities({super.key});

  @override
  State<StatefulWidget> createState() => CardsCitiesState();
}

class CardsCitiesState extends State<CardsCities> {
  PageController pageController = PageController(initialPage: 0, viewportFraction: 0.9);
  double dx = 0;
  final List<int> numbers = [];
  final List<String> cityNames = Constants.CITIES_COORDINATES.keys.toList();

  @override
  void initState() {
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
  Widget build(BuildContext context) {
    return Flexible(
        child: PageView.builder(
            physics: const ClampingScrollPhysics(),
            controller: pageController,
            itemCount: Constants.CITIES_COORDINATES.length,
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
                            decoration: const BoxDecoration(boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadow,
                                spreadRadius: 4,
                                blurRadius: 4,
                                offset: Offset(0, 0),
                              ),
                            ], color: Color.fromARGB(255, 255, 216, 171), borderRadius: BorderRadius.only(bottomRight: Radius.circular(36), bottomLeft: Radius.circular(36))),
                            child: const Padding(
                                padding: EdgeInsets.all(16),
                                child: SingleChildScrollView(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(
                                    "Em Desenvolvimento...",
                                    style: TextStyle(color: AppColors.appBackground, fontSize: 20),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Quis ipsum suspendisse ultrices gravida. Risus commodo viverra maecenas accumsan lacus vel facilisis. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Quis ipsum suspendisse ultrices gravida. Risus commodo viverra maecenas accumsan lacus vel facilisis.Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Quis ipsum suspendisse ultrices gravida. Risus commodo viverra maecenas accumsan lacus vel facilisis.",
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(color: AppColors.appBackground, fontSize: 16)),
                                ]))))),
                    const SizedBox(height: 96)
                  ])
                  /*
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: Positioned.fill(
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
                    ))*/
                  );
            }));
  }
}
