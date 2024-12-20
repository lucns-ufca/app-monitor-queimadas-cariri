// @Developed by @lucns

import 'package:monitor_queimadas_cariri/models/Member.model.dart';
import 'package:monitor_queimadas_cariri/pages/content/MainScreen.page.dart';
import 'package:monitor_queimadas_cariri/utils/Constants.dart';
import 'package:flutter/material.dart';

import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:float_column/float_column.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  AboutPageState createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage> {
  final double toolbarHeight = 220;
  final double avatarSize = 96;
  final double avatarRightPadding = 16;
  final double horizontalPadding = 24;
  final VideoPlayerController videoController = VideoPlayerController.asset('assets/videos/dark_bird.mp4');

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(systemNavigationBarColor: Colors.transparent, statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light, systemNavigationBarIconBrightness: Brightness.light));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    super.initState();
    videoController.setLooping(true);
    videoController.initialize().then((_) => setState(() {}));
    videoController.play();
  }

  @override
  Widget build(BuildContext context) {
    //final navigator = Navigator.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreenPage()));
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.appBackground,
        body: Stack(
          children: [
            AspectRatio(aspectRatio: videoController.value.aspectRatio, child: VideoPlayer(videoController)),
            SizedBox(
                height: toolbarHeight,
                child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const SizedBox(height: 32),
                      const Text("Soldadinho do Araripe", style: TextStyle(color: Colors.white, fontSize: 14)),
                      const SizedBox(height: 8),
                      Container(width: 145, height: 0.5, color: Colors.white),
                      const SizedBox(height: 8),
                      const Text(
                        "Está em perigo\ncrítico de extinção",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      )
                    ]))),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  width: double.maxFinite,
                  height: MediaQuery.of(context).size.height - toolbarHeight + Constants.DEFAULT_ROUND_BORDER,
                  padding: EdgeInsets.all(horizontalPadding),
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(Constants.DEFAULT_ROUND_BORDER), topLeft: Radius.circular(Constants.DEFAULT_ROUND_BORDER)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        spreadRadius: 4,
                        blurRadius: 4,
                        offset: Offset(0, 0),
                      ),
                    ],
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.aboutGradientStart, AppColors.aboutGradientEnd],
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Sobre o Projeto",
                        style: TextStyle(color: AppColors.textNormal2, fontSize: 20),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                          child: SingleChildScrollView(
                              child: Column(children: [
                        const Text(
                          "Este app é parte de todo um sistema que envolve uma Plataforma Web, Inteligência Artificial, Back-Ends, Front-End, um sistema de embarcados para tornar possível o funcionamento do mesmo. Oriundo de um projeto de extensão da Universidade Federal do Cariri (UFCA) em parceria com o grupo de pesquisa Lisia, nosso sistema busca monitorar dados preditos sobre queimadas na região do Cariri Cearence, no nordeste do Brasil, baseando-se em dados climáticos e número de ocorrências de anos anteriores. \n\nFez-se necessário um trabalho em equipe entre alunos da universidade para torna-lo uma realidade. Foram feitas muitas pesquisas sobre bancos de dados no qual possuíssem informações referentes a região e novos metodos de predições para obtermos um maior nível de precisão das predições. Cada integrante teve fundamental participação junto ao projeto e com base nos resultados, cruciais contribuições. \n\nAbaixo estão os integrantes, suas respectivas atribuições e participações no projeto.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(color: AppColors.textNormal2, fontSize: 14),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Image.asset('assets/images/twig.png', color: AppColors.twigColor),
                        const SizedBox(
                          height: 8,
                        ),
                      ])))
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget getMemberWidget(MemberModel member) {
    return Column(children: [
      FloatColumn(
        children: [
          Floatable(
            float: FCFloat.end,
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(width: MediaQuery.of(context).size.width - avatarSize - (2 * horizontalPadding) - avatarRightPadding, child: Text(member.name!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textNormal2))),
          ),
          Floatable(
            float: FCFloat.start,
            padding: EdgeInsets.only(right: avatarRightPadding),
            child: SizedBox(
              width: avatarSize,
              height: avatarSize,
              child: CircleAvatar(
                  backgroundColor: AppColors.textNormal2,
                  radius: 42,
                  child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: ClipOval(
                          child: Container(
                        height: toolbarHeight,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          fit: BoxFit.fitWidth,
                          alignment: FractionalOffset.topCenter,
                          image: AssetImage("assets/images/members/${member.image}"),
                        )),
                      )))),
              //child: Image.asset("assets/images/members/Luis_Fabricio_de_Freitas_Souza.jpg", width: 30),
            ),
          ),
          WrappableText(textAlign: TextAlign.justify, text: TextSpan(text: member.description, style: const TextStyle(color: AppColors.textNormal2))),
        ],
      ),
      Row(
        children: [const Text("TECNOLOGIAS USADAS:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text(member.technologies!, style: const TextStyle(color: AppColors.textNormal2))],
      )
    ]);
  }
}
