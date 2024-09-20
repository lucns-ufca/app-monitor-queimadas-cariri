import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:app_monitor_queimadas/utils/PermissionData.dart';
import 'package:app_monitor_queimadas/widgets/CustomCheckBox.widget.dart';
import 'package:flutter/material.dart';

class FireReportIntroductionPage extends StatefulWidget {
  final List<PermissionData> permissions;
  final Function onPermissionChanged;
  const FireReportIntroductionPage({required this.permissions, required this.onPermissionChanged, super.key});

  @override
  State<StatefulWidget> createState() => FireReportIntroductionPageState();
}

class FireReportIntroductionPageState extends State<FireReportIntroductionPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 5),
        width: MediaQuery.of(context).size.width,
        height: double.maxFinite,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
          const Text("Permissões necessárias", style: TextStyle(fontSize: 24, color: AppColors.accent, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.permissions.map((permission) {
                CustomCheckBoxController controller = CustomCheckBoxController();
                return Row(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  CustomCheckBox(
                    controller: controller,
                    lockManuallyCheck: true,
                    checked: permission.granted,
                    onCheck: (checked) async {
                      if (permission.granted) return;
                      if (await permission.request) {
                        controller.setChecked(true);
                        widget.onPermissionChanged();
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(permission.name, style: const TextStyle(fontSize: 20, color: AppColors.textNormal, fontWeight: FontWeight.w500))
                ]);
              }).toList())
        ]));
  }
}
