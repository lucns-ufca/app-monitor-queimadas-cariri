import 'package:flutter/material.dart';
import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:monitor_queimadas_cariri/widgets/CardsCities.widget.dart';

class TabNaturePage extends StatefulWidget {
  const TabNaturePage({super.key});

  @override
  State<StatefulWidget> createState() => TabNaturePageState();
}

class TabNaturePageState extends State<TabNaturePage> with AutomaticKeepAliveClientMixin<TabNaturePage> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.fragmentBackground, AppColors.appBackground],
        ),
      ),
      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 56),
        Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Text("Um pouco\ndo cariri", style: TextStyle(height: 1.2, fontWeight: FontWeight.w200, color: Colors.white, fontSize: 36))),
        SizedBox(height: 56),
        CardsCities()
      ]),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
