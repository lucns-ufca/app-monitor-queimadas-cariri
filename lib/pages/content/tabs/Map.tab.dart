// @Developed by @lucns

import 'dart:async';
import 'dart:developer';
import 'package:monitor_queimadas_cariri/models/FireOccurrence.model.dart';
import 'package:monitor_queimadas_cariri/repositories/BdQueimadas.repository.dart';
import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:monitor_queimadas_cariri/utils/Notify.dart';
import 'package:monitor_queimadas_cariri/utils/Utils.dart';
import 'package:monitor_queimadas_cariri/widgets/MyDropdownMenu.widget.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TabMapPage extends StatefulWidget {
  const TabMapPage({super.key});

  @override
  State<StatefulWidget> createState() => TabMapPageState();
}

class TabMapPageState extends State<TabMapPage> with AutomaticKeepAliveClientMixin<TabMapPage> {
  BdQueimadasRepository bdq = BdQueimadasRepository();
  GoogleMapController? googleMapController;
  Set<Marker> markers = {};
  bool updated = false;
  String? selectedCity;
  bool expanded = false;
  bool repositioned = false;
  bool loading = true;

  void reposition() async {
    repositioned = true;
    await Future.delayed(const Duration(milliseconds: 500));
    double latitude = -7.269365;
    double longitude = -39.598603;
    _goToPosition(latitude, longitude, zoom: 8);
  }

  Future<void> updateMarkers() async {
    markers.clear();
    List<FireOccurrenceModel> occurrences = [];
    if (selectedCity == null) {
      bdq.occurrences.forEach((key, list) {
        occurrences.addAll(list);
      });
    } else {
      occurrences = bdq.occurrences[selectedCity];
    }
    BitmapDescriptor icon = await BitmapDescriptor.asset(const ImageConfiguration(size: Size(24, 34)), 'assets/icons/pin_fire.png');
    for (FireOccurrenceModel occurrence in occurrences) {
      markers.add(Marker(
          icon: icon,
          consumeTapEvents: true,
          markerId: MarkerId("${markers.length}"),
          position: LatLng(occurrence.latitude!, occurrence.longitude!),
          onTap: () {
            Utils.vibrate();
            log("marker clicked");
          }));
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bdq.setOnUpdateListener(() async {
        if (!mounted) return;
        await updateMarkers();
      }, () {
        updated = true;
        Utils.vibrate();
        Notify.showToast("Dados atualizados");
        setState(() {
          loading = false;
        });
      }, () {
        Utils.vibrate();
        Notify.showToast("Sistema fora do ar!");
        setState(() {
          loading = false;
        });
      });
      Notify.showToast("Atualizando...");
      await bdq.update();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    List<MyDropdownMenuItem> dropDownItems = [];
    if (updated) {
      bdq.CITIES_IDS.forEach((key, value) {
        String s = bdq.occurrences[key].length == 1 ? "" : "s";
        dropDownItems.add(MyDropdownMenuItem(key, "${bdq.occurrences[key].length} foco$s"));
      });
    }

    return Stack(
      children: [
        GoogleMap(
            markers: markers,
            mapType: MapType.terrain,
            initialCameraPosition: const CameraPosition(target: LatLng(-10.0, -50.0), zoom: 3.0),
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) async {
              googleMapController = controller;
              if (repositioned) return;
              await Future.delayed(const Duration(seconds: 1));
              reposition();
            },
            onTap: (ll) {}),
        Align(
            alignment: Alignment.topCenter,
            child: IntrinsicHeight(
                child: SizedBox(
                    width: double.maxFinite,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.fragmentBackground, Colors.transparent])), width: double.maxFinite, height: 48),
                      Padding(
                          padding: const EdgeInsets.only(left: 16, top: 16),
                          child: IntrinsicWidth(
                            child: AnimatedOpacity(
                              opacity: updated ? 1 : 0,
                              duration: const Duration(milliseconds: 500),
                              child: MyDropdownMenu(
                                  buttonChild: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        const Text("Registrado nas últimas 24h:", style: TextStyle(color: AppColors.accent, fontSize: 18)),
                                        Row(
                                          children: [
                                            const Text(
                                              "Todas as cidades",
                                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 8),
                                            Transform.scale(
                                                scale: 1.25,
                                                child: Icon(
                                                  expanded ? Icons.keyboard_arrow_up_outlined : Icons.keyboard_arrow_down_outlined,
                                                  color: Colors.white,
                                                ))
                                          ],
                                        )
                                      ])),
                                  items: dropDownItems,
                                  onExpanded: (e) {
                                    setState(() {
                                      expanded = e;
                                    });
                                  }),
                            ),
                          ))
                    ])))),
        Center(
            child: IntrinsicHeight(
                child: Visibility(
                    visible: loading,
                    child: Container(
                        decoration: const BoxDecoration(color: AppColors.dialogBlack, borderRadius: BorderRadius.all(Radius.circular(24))),
                        padding: const EdgeInsets.all(24),
                        child: const Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, children: [
                          SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.accent)),
                          SizedBox(width: 16),
                          Flexible(
                              child: Text(
                            "Carregando pontos de focos...",
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: TextStyle(color: AppColors.textNormal, fontSize: 16, fontWeight: FontWeight.w500),
                          ))
                        ])))))
      ],
    );
  }

  Future<void> _goToPosition(double lat, double lon, {double zoom = 15}) async {
    if (googleMapController == null) return;
    CameraPosition p = CameraPosition(target: LatLng(lat, lon), zoom: zoom);
    await googleMapController!.animateCamera(CameraUpdate.newCameraPosition(p));
  }

  @override
  bool get wantKeepAlive => true;
}
