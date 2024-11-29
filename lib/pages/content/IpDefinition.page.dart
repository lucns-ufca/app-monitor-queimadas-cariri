import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:monitor_queimadas_cariri/utils/Notify.dart';
import 'package:monitor_queimadas_cariri/widgets/RadioGroup.widget.dart';
import 'package:monitor_queimadas_cariri/widgets/TextField.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IpDefinitionPage extends StatefulWidget {
  const IpDefinitionPage({super.key});

  @override
  State<StatefulWidget> createState() => IpDefinitionPageState();
}

class IpDefinitionPageState extends State<IpDefinitionPage> {
  SharedPreferences? preferences;
  String? ip, port;
  bool? useLocal;
  int sentType = 0;

  void showSnackBar() {
    Notify.showSnackbarSucess(context, "Salvo", duration: const Duration(seconds: 1));
  }

  void initializePreferences() async {
    preferences = await SharedPreferences.getInstance();
    ip = preferences!.getString("ip");
    port = preferences!.getString("port");
    useLocal = preferences!.getBool("use_local");
    sentType = preferences!.getInt("sent_type") ?? 0;
  }

  @override
  void initState() {
    initializePreferences();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvoked: (didPop) async {
          if (ip == null || ip!.isEmpty) {
            await preferences!.remove("ip");
            await preferences!.remove("port");
          } else {
            await preferences!.setString("ip", ip!);
            await preferences!.setString("port", port!);
          }
          //FocusManager.instance.primaryFocus?.unfocus(); // hide keyboard
          showSnackBar();
          //Navigator.pop(context);
        },
        child: Scaffold(
            backgroundColor: AppColors.fragmentBackground,
            body: SingleChildScrollView(
                child: Container(
                    padding: const EdgeInsets.all(24),
                    width: double.maxFinite,
                    height: double.maxFinite,
                    child: Column(children: [
                      const SizedBox(height: 72),
                      const Text("Definir IP Local", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300, fontSize: 36)),
                      const SizedBox(height: 56),
                      Row(children: [
                        const Expanded(child: Padding(padding: EdgeInsets.only(left: 8), child: Text("ip:", style: TextStyle(color: AppColors.white_3)))),
                        const SizedBox(width: 18),
                        Container(
                            padding: const EdgeInsets.only(left: 8),
                            width: 96,
                            child: const Text(
                              "porta:",
                              style: TextStyle(color: AppColors.white_3),
                            ))
                      ]),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                              child: MyFieldText(
                            text: ip ?? "",
                            hintText: '192.168.1.1',
                            action: TextInputAction.next,
                            inputType: TextInputType.number,
                            onInput: (text) {
                              setState(() {
                                ip = text;
                              });
                            },
                          )),
                          const SizedBox(width: 8),
                          const Text(":", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                          const SizedBox(width: 8),
                          SizedBox(
                              width: 96,
                              child: MyFieldText(
                                text: port ?? "",
                                hintText: '1234',
                                action: TextInputAction.next,
                                inputType: TextInputType.number,
                                onInput: (text) {
                                  setState(() {
                                    port = text;
                                  });
                                },
                              )),
                        ],
                      ),
                      const SizedBox(height: 48),
                      Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: AppColors.buttonDisabled),
                            borderRadius: const BorderRadius.all(Radius.circular(24)),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: RadioGroup(
                              onCheckChanged: (selectedRadioButton) {
                                preferences!.setInt("sent_type", selectedRadioButton.title == 'Usar Form-Data' ? 0 : 1);
                              },
                              radios: [RadioButton(title: "Usar Form-Data", checked: sentType == 0, enabled: true), RadioButton(title: "Usar JSON", checked: sentType == 1, enabled: true)])),
                    ])))));
  }

  bool isValidIp() {
    if (ip != null) {
      if (ip!.contains(".")) {
        List<String> segments = ip!.split(".");
        return segments.length == 4;
      }
    }
    return false;
  }

  bool isValidPort() {
    return port != null && port!.isNotEmpty;
  }
}
