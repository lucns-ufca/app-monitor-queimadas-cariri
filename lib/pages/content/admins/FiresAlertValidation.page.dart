import 'package:flutter/material.dart';
import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:monitor_queimadas_cariri/utils/Notification.provider.dart';

class FiresAlertValidationPage extends StatefulWidget {
  const FiresAlertValidationPage({super.key});

  @override
  State<StatefulWidget> createState() => FiresAlertValidationPageState();
}

class FiresAlertValidationPageState extends State<FiresAlertValidationPage> {
  void clearNotifications() async {
    NotificationProvider notificationProvider = await NotificationProvider.getInstance();
    notificationProvider.removeAll();
  }

  @override
  void initState() {
    clearNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.appBackground,
        body: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Container(width: 100, height: 200, color: Colors.red), Container(width: 100, height: 200, color: Colors.green), Container(width: 100, height: 200, color: Colors.blue)],
        )));
  }
}
