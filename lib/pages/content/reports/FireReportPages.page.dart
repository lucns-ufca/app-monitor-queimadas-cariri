import 'dart:async';

import 'package:app_monitor_queimadas/pages/content/Dashboard.page.dart';
import 'package:app_monitor_queimadas/pages/content/reports/FireReportCamera.page.dart';
import 'package:app_monitor_queimadas/pages/content/reports/FireReportIntroduction.page.dart';
import 'package:app_monitor_queimadas/pages/content/reports/FireReportSender.page.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:app_monitor_queimadas/utils/PermissionData.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class FireReportPages extends StatefulWidget {
  final List<PermissionData> permissions;
  const FireReportPages({required this.permissions, super.key});

  @override
  State<StatefulWidget> createState() => FireReportPagesState();
}

class FireReportPagesState extends State<FireReportPages> {
  double toolbarHeight = 165;
  PageController pageController = PageController();
  CallbackController callbackController = CallbackController();
  String? filePath;
  StreamSubscription<Position>? positionStream;
  bool skipPermissionPage = true;
  Position? position;

  void initializeGps() {
    for (PermissionData data in widget.permissions) {
      if (data.permission == Permission.locationWhenInUse) {
        if (!data.granted) return;
        break;
      }
    }
    positionStream = Geolocator.getPositionStream(locationSettings: const LocationSettings(accuracy: LocationAccuracy.best)).listen((Position? p) {
      if (p == null) return;
      position = p;
      if (p.accuracy < 25) positionStream!.cancel();
      callbackController.setPosition(p);
    });
    //positionStream.resume();
  }

  @override
  void initState() {
    callbackController.getImagePath = getImagePath;
    callbackController.onPreviousStep = onPreviousStep;
    callbackController.getPosition = getPosition;
    for (PermissionData permission in widget.permissions) {
      if (!permission.granted) {
        skipPermissionPage = false;
        break;
      }
    }

    super.initState();
    initializeGps();
  }

  @override
  void dispose() {
    positionStream!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final navigator = Navigator.of(context);
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
        },
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: AppColors.appBackground,
            body: PageView(physics: const NeverScrollableScrollPhysics(), controller: pageController, scrollDirection: Axis.horizontal, children: [
              if (!skipPermissionPage)
                FireReportIntroductionPage(
                    permissions: widget.permissions,
                    onPermissionChanged: () {
                      for (PermissionData data in widget.permissions) {
                        if (!data.granted) return;
                        if (data.permission == Permission.locationWhenInUse) {
                          initializeGps();
                        }
                      }
                      pageController.animateToPage(1, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                    }),
              FireReportCameraPage(onCapture: (file) {
                filePath = file.path;
                pageController.animateToPage(skipPermissionPage ? 1 : 2, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
              }),
              FireReportSenderPage(callbackController: callbackController)
            ])));
  }

  String? getImagePath() {
    return filePath;
  }

  Position? getPosition() {
    return position;
  }

  void onPreviousStep() {
    pageController.animateToPage(skipPermissionPage ? 0 : 1, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }
}

class CallbackController {
  Function setPosition = (a) {};
  Function getPosition = () {};
  Function getImagePath = () {};
  Function onPreviousStep = () {};
  Function updateWidget = () {};
}
