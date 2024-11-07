// @Developed by @lucns

import 'dart:async';
import 'dart:developer';
import 'package:app_monitor_queimadas/models/FireOccurrence.model.dart';
import 'package:app_monitor_queimadas/repositories/BdQueimadas.repository.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:app_monitor_queimadas/utils/Notify.dart';
import 'package:app_monitor_queimadas/utils/Utils.dart';
import 'package:app_monitor_queimadas/widgets/MyDropdownMenu.widget.dart';
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

  void reposition() async {
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
      reposition();

      bdq.setOnUpdateListener(() async {
        await updateMarkers();
      }, () {
        updated = true;
        Utils.vibrate();
        Notify.showToast("Dados atualizados");
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
    log("size: ${dropDownItems.length}");

    return Stack(
      children: [
        GoogleMap(
            markers: markers,
            mapType: MapType.terrain,
            initialCameraPosition: const CameraPosition(target: LatLng(-10.0, -50.0), zoom: 3.0),
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              googleMapController = controller;
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
                                        const Text("Ocorrido hoje em:", style: TextStyle(color: AppColors.textAccent, fontSize: 18)),
                                        Row(
                                          children: [
                                            const Text(
                                              "Todas as cidades",
                                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 8),
                                            Transform.scale(
                                                scale: 1.25,
                                                child: const Icon(
                                                  Icons.keyboard_arrow_down_outlined,
                                                  color: Colors.white,
                                                ))
                                          ],
                                        )
                                      ])),
                                  items: dropDownItems),
                            ),
                          ))
                    ]))))
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
