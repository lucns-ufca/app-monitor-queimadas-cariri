// Developed by @lucns

import 'package:app_monitor_queimadas/models/User.model.dart';
import 'package:app_monitor_queimadas/pages/content/MainScreen.page.dart';
import 'package:app_monitor_queimadas/pages/start/First.page.dart';
import 'package:app_monitor_queimadas/repositories/App.repository.dart';
import 'package:flutter/material.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  runApp(const SplashScreen());

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  GetIt sl = GetIt.instance;
  sl.allowReassignment = true;
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<AppRepository>(() => AppRepository());
  User user = User();
  await user.loadData();
  sl.registerLazySingleton<User>(() => user);

  runApp(MyApp(user));
}

class MyApp extends StatelessWidget {
  final User user;

  const MyApp(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        color: AppColors.appBackground,
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
