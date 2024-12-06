import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:monitor_queimadas_cariri/models/User.model.dart';
import 'package:monitor_queimadas_cariri/pages/content/reports/FireReportPages.page.dart';
import 'package:monitor_queimadas_cariri/pages/content/tabs/Home.tab.dart';
import 'package:monitor_queimadas_cariri/pages/content/tabs/Map.tab.dart';
import 'package:monitor_queimadas_cariri/pages/content/tabs/Nature.tab.dart';
import 'package:monitor_queimadas_cariri/pages/content/tabs/Statistics.tab.dart';
import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:monitor_queimadas_cariri/utils/Notification.provider.dart';
import 'package:monitor_queimadas_cariri/utils/PermissionData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';

class MainScreenPage extends StatefulWidget {
  const MainScreenPage({super.key});

  @override
  State<StatefulWidget> createState() => MainScreenPageState();
}

class MainScreenPageState extends State<MainScreenPage> {
  final user = GetIt.I.get<User>();
  final List<PermissionData> permissions = [PermissionData(name: "Camera", permission: Permission.camera), PermissionData(name: "Localização", permission: Permission.locationWhenInUse)];
  final PageController pageController = PageController();

  MainScreenPageState();

  @override
  void initState() {
    super.initState();
    NotificationProvider notificationProvider = NotificationProvider.getInstance();
    notificationProvider.requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: !user.hasAccess(),
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (user.hasAccess()) {
            SystemNavigator.pop();
          } else {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
            SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarIconBrightness: Brightness.light,
              statusBarIconBrightness: Brightness.light,
            ));
            //await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FirstPage()));
          }
        },
        child: FocusDetector(
            onVisibilityGained: () {
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
              SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: AppColors.fragmentBackground,
                systemNavigationBarIconBrightness: Brightness.light,
                statusBarIconBrightness: Brightness.light,
              ));
            },
            child: Scaffold(
                extendBody: true,
                backgroundColor: AppColors.appBackground,
                body: PageView(physics: const NeverScrollableScrollPhysics(), controller: pageController, children: const [TabHomePage(), TabStatisticsPage(), TabMapPage(), TabNaturePage()]),
                floatingActionButton: SizedBox(
                    width: 56,
                    height: 56,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            //foregroundColor: colorsStateText,
                            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(EdgeInsetsDirectional.zero),
                            elevation: WidgetStateProperty.all<double>(4),
                            overlayColor: WidgetStateProperty.resolveWith((states) => Colors.white.withOpacity(0.5)),
                            backgroundColor: WidgetStateProperty.all<Color>(AppColors.accent),
                            shape: WidgetStateProperty.all<OvalBorder>(const OvalBorder())),
                        onPressed: () async {
                          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FireReportPages(permissions: permissions)));
                        },
                        child: const Icon(Icons.local_fire_department))),
                floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                bottomNavigationBar: NavigationBar(
                  onTabSelected: (index) {
                    pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.ease);
                  },
                ))));
  }
}

class NavigationBar extends StatefulWidget {
  final Function(int) onTabSelected;

  const NavigationBar({required this.onTabSelected, super.key});

  @override
  State<StatefulWidget> createState() => NavigationBarState();
}

class NavigationBarState extends State<NavigationBar> {
  int tabIndex = 0;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: AppColors.fragmentBackground,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBottomNavigationBar.builder(
      splashColor: Colors.transparent,
      itemCount: 4,
      tabBuilder: (int index, bool isActive) {
        IconData icon = Icons.home_outlined;
        switch (index) {
          case 1:
            icon = Icons.auto_graph_outlined;
            break;
          case 2:
            icon = Icons.place_outlined;
            break;
          case 3:
            icon = Icons.grass_sharp;
            break;
          case 4:
            icon = Icons.emoji_nature_outlined;
            break;
        }
        return IconButton(
          onPressed: () {
            setState(() => tabIndex = index);
            widget.onTabSelected(index);
          },
          icon: Icon(icon, color: tabIndex == index ? AppColors.accent : Colors.white),
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: Colors.transparent)),
              foregroundColor: Colors.white,
              highlightColor: tabIndex == index ? Colors.white : AppColors.accent,
              backgroundColor: Colors.transparent),
          //backgroundColor: _bottomNavIndex == index ? AppColors.accent : Colors.transparent),
        );
      },
      backgroundColor: AppColors.fragmentBackground,
      activeIndex: tabIndex,
      gapLocation: GapLocation.center,
      leftCornerRadius: 32,
      rightCornerRadius: 32,
      onTap: (index) {},
      shadow: const BoxShadow(
        offset: Offset(0, 1),
        blurRadius: 12,
        spreadRadius: 0.5,
        color: AppColors.black,
      ),
    );
  }
}
