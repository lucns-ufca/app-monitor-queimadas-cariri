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
    return SizedBox(
        height: MediaQuery.of(context).size.width / 1.87,
        child: PageView.builder(
            physics: const ClampingScrollPhysics(),
            controller: pageController,
            itemCount: Constants.CITIES_COORDINATES.length,
            onPageChanged: (index) {},
            itemBuilder: (context, index) {
              double alignmentX = -(dx - index) * 10;
              return Container(
                padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(36), boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 4, spreadRadius: 4, offset: Offset(0, 4))]),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(36),
                        child: Container(
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/images/cards_background/${numbers[index]}.jpg"),
                                fit: BoxFit.cover,
                                alignment: Alignment(alignmentX, 0),
                              ),
                            ),
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
                                    style: const TextStyle(color: AppColors.textNormal, fontSize: 24, fontWeight: FontWeight.w300),
                                  ))
                            ])))
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
                    ),
              );
            }));
  }
}
