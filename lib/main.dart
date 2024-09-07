// Developed by @lucns

import 'dart:io';

import 'package:app_monitor_queimadas/models/user.model.dart';
import 'package:app_monitor_queimadas/pages/content/MainScreen.page.dart';
import 'package:app_monitor_queimadas/pages/start/First.page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  runApp(const SplashScreen());

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  Directory directory = await getApplicationDocumentsDirectory();

  GetIt sl = GetIt.instance;
  sl.allowReassignment = true;
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<Directory>(() => directory);
  User user = User();
  await user.loadData();
  sl.registerLazySingleton<User>(() => user);

  runApp(MyApp(user));
}

class MyApp extends StatelessWidget {
  final User user;

  MyApp(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: AppColors.fragmentBackground, systemNavigationBarColor: AppColors.fragmentBackground, statusBarIconBrightness: Brightness.light, systemNavigationBarIconBrightness: Brightness.light));

    return MaterialApp(
        color: Colors.black,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(primary: Colors.white, seedColor: AppColors.accent),
          useMaterial3: true,
        ),
        //home: user.hasAccess() ? const DashboardPage() : const FirstPage()
        home: user.hasAccess() ? MainScreenPage() : const FirstPage()
        /*
              if (preferences.getBool("second_execution") ?? false) {
                return const MainScreen();
              } else {
                return const FirstAppScreen();
              }
              */
        );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      color: AppColors.fragmentBackground,
      child: const Image(image: ResizeImage(AssetImage('assets/images/ufca_white.png'), width: 105, height: 33)),
    );
  }
}
