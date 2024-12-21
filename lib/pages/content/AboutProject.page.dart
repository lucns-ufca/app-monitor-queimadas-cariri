// @Developed by @lucns

import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:monitor_queimadas_cariri/models/Member.model.dart';
import 'package:monitor_queimadas_cariri/models/User.model.dart';
import 'package:monitor_queimadas_cariri/pages/content/MainScreen.page.dart';
import 'package:monitor_queimadas_cariri/utils/Constants.dart';
import 'package:flutter/material.dart';

import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:float_column/float_column.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  AboutPageState createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage> {
  final User user = GetIt.I.get<User>();
  final double toolbarHeight = 220;
  final double avatarSize = 96;
  final double avatarRightPadding = 16;
  final double horizontalPadding = 24;
  final VideoPlayerController videoController = VideoPlayerController.asset('assets/videos/dark_bird.mp4');

  Future<List<MemberModel>> getMembers() async {
    List<MemberModel> members = [];
    String content = await rootBundle.loadString('assets/files/members.json');
    List<dynamic> list = await json.decode(content);
    for (Map<String, dynamic> map in list) {
      members.add(MemberModel.fromJson(map));
    }
    return members;
  }

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      //systemNavigationBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.black.withOpacity(0.002),
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
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
                  padding: EdgeInsets.only(top: horizontalPadding, left: horizontalPadding, right: horizontalPadding),
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
                          "Este app é parte de todo um sistema que envolve uma Plataforma Web, Inteligência Artificial, Back-Ends, Front-Ends e um sistema de embarcados para tornar possível o funcionamento do mesmo. Oriundo de um projeto de extensão da Universidade Federal do Cariri (UFCA) em parceria com o grupo de pesquisa LISIA, nosso sistema busca monitorar dados preditos sobre queimadas da região do Cariri Cearence, no nordeste do Brasil, baseando-se em dados climáticos e número de ocorrências de anos anteriores. \n\nFez-se necessário um trabalho em equipe entre alunos da universidade para torna-lo uma realidade. Foram feitas muitas pesquisas sobre bancos de dados no qual possuíssem informações referentes a região e sobre novos métodos de predições, para obtermos um maior nível de precisão. Cada integrante teve fundamental participação junto ao projeto e com base nos resultados, tiveram cruciais contribuições. \n\nAbaixo estão os membros, suas respectivas atribuições e participações no projeto.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(color: AppColors.textNormal2, fontSize: 14),
                        ),
                        FutureBuilder(
                            future: getMembers(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState != ConnectionState.done || snapshot.data == null) return const SizedBox();
                              List<MemberModel> members = snapshot.data!;
                              return Column(
                                  children: List.generate(members.length, (index) {
                                return Column(children: [
                                  Container(padding: const EdgeInsets.symmetric(vertical: 16), height: 85, child: Center(child: Image.asset("assets/images/divider_twig.png", color: AppColors.twigColor))),
                                  getMemberWidget(members[index]),
                                  if (index == members.length - 1) const SizedBox(height: 56)
                                ]);
                              }));
                            })
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FloatColumn(
        children: [
          Floatable(
            float: FCFloat.end,
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(width: MediaQuery.of(context).size.width - avatarSize - (2 * horizontalPadding) - avatarRightPadding, child: Text(member.name!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accent))),
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
            ),
          ),
          WrappableText(textAlign: TextAlign.justify, text: TextSpan(text: member.description, style: const TextStyle(color: AppColors.textNormal2))),
        ],
      ),
      const SizedBox(height: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tecnologias usadas:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(member.technologies!, overflow: TextOverflow.ellipsis, maxLines: 4, style: const TextStyle(color: AppColors.textNormal2))
        ],
      ),
      const SizedBox(height: 8),
      if (member.email != null && member.linkedin != null && member.instagram != null && member.orcid != null && member.github != null && member.lattes != null) const Text("Contatos:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            if (member.instagram != null) getSocialButton('assets/icons/instagram.webp', member.instagram!),
            if (member.email != null) getSocialButton('assets/icons/gmail.webp', member.email!),
            if (member.linkedin != null) getSocialButton('assets/icons/linkedin.png', member.linkedin!),
            if (member.github != null) getSocialButton('assets/icons/github.png', member.github!),
            if (member.lattes != null) getSocialButton('assets/icons/lattes.png', member.lattes!),
            if (member.orcid != null) getSocialButton('assets/icons/orcid.png', member.orcid!),
          ]))
    ]);
  }

  Widget getSocialButton(String assets, String url) {
    return Row(children: [
      SizedBox(
          width: 56,
          height: 56,
          child: ElevatedButton(
            onPressed: () async {
              await Future.delayed(const Duration(milliseconds: 250));
              await openUrl(url);
            },
            style: ButtonStyle(
                elevation: WidgetStateProperty.all<double>(8),
                shadowColor: WidgetStateProperty.all<Color>(Colors.black),
                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
                backgroundColor: WidgetStateProperty.all<Color>(AppColors.aboutButtons),
                overlayColor: WidgetStateProperty.all<Color>(Colors.white.withOpacity(0.5)),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: const BorderSide(color: Colors.transparent)))),
            child: Image.asset(assets, width: 36, height: 36),
          )),
      const SizedBox(width: 16)
    ]);
  }

  Future<void> openUrl(String url) async {
    Uri uri;
    if (url.contains('@')) {
      String body;
      if (user.isAuthenticated()) {
        body = "Olá me chamo ${user.getName()}. Gostaria de dar minha sugestão/critica sobre o app/projeto.";
      } else {
        body = "Olá sou um visitante do app. Gostaria de dar minha sugestão/critica sobre o app/projeto.";
      }
      uri = Uri(
        scheme: 'mailto',
        path: url,
        query: 'subject=Monitor de Queimadas Cariri&body=$body',
      );
    } else {
      uri = Uri.parse(url);
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) {
        throw Exception('Could not launch $url');
      }
    }
  }
}
