// @Developed by @lucns

import 'dart:async';
import 'dart:developer';
import 'package:app_monitor_queimadas/models/FireOccurrence.model.dart';
import 'package:app_monitor_queimadas/repositories/BdQueimadas.repository.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:app_monitor_queimadas/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TabMapPage extends StatefulWidget {
  const TabMapPage({super.key});

  @override
  State<StatefulWidget> createState() => TabMapPageState();
}

class TabMapPageState extends State<TabMapPage> {
  GoogleMapController? googleMapController;
  Set<Marker> markers = {};

  void reposition() async {
    await Future.delayed(const Duration(seconds: 1));
    double latitude = -7.269365;
    double longitude = -39.598603;
    _goToPosition(latitude, longitude, zoom: 10);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      reposition();

      BitmapDescriptor icon = await BitmapDescriptor.asset(const ImageConfiguration(size: Size(24, 34)), 'assets/icons/pin_fire.png');
      BdQueimadasRepository bdq = BdQueimadasRepository();
      bdq.setOnUpdateConcluded(() {
        Utils.vibrate();
        markers.clear();
        for (FireOccurrenceModel occurrence in bdq.occurrences) {
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
      });
      await bdq.update();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                            child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          decoration: const BoxDecoration(
                            color: AppColors.fragmentBackground,
                            borderRadius: BorderRadius.all(Radius.circular(36)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset: Offset(0, -2),
                              ),
                            ],
                          ),
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
                          ]),
                        )),
                      )
                    ]))))
      ],
    );
  }

  Future<void> _goToPosition(double lat, double lon, {double zoom = 15}) async {
    if (googleMapController == null) return;
    CameraPosition p = CameraPosition(target: LatLng(lat, lon), zoom: zoom);
    await googleMapController!.animateCamera(CameraUpdate.newCameraPosition(p));
  }
}
