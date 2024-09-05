import 'dart:async';

import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:app_monitor_queimadas/utils/Utils.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class FireReportCameraPage extends StatefulWidget {
  final Function(XFile) onCapture;
  const FireReportCameraPage({required this.onCapture, super.key});

  @override
  State<FireReportCameraPage> createState() {
    return _CameraExampleHomeState();
  }
}

void _logError(String code, String? message) {
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}

class _CameraExampleHomeState extends State<FireReportCameraPage> with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? cameraController;
  XFile? imageFile;
  VoidCallback? videoPlayerListener;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  int _pointers = 0;
  double roundBorder = 56;
  List<CameraDescription> _cameras = <CameraDescription>[];

  void initCameras() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      _cameras = await availableCameras();
      CameraDescription? cameraDescription;
      for (CameraDescription camera in _cameras) {
        if (camera.lensDirection == CameraLensDirection.back) {
          cameraDescription = camera;
          break;
        }
      }
      if (cameraDescription != null) {
        _initializeCameraController(cameraDescription);
        cameraController!.setDescription(cameraDescription);
      }
    } on CameraException catch (e) {
      _logError(e.code, e.description);
    }
  }

  @override
  void initState() {
    initCameras();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController!.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController!.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.appBackground,
        body: SizedBox(
            width: double.maxFinite,
            height: double.maxFinite,
            child: Stack(children: [
              _cameraPreviewWidget(),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      height: (MediaQuery.of(context).size.height - MediaQuery.of(context).size.width * 1.777) + roundBorder,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(roundBorder), topRight: Radius.circular(roundBorder)),
                        color: AppColors.appBackground,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.3), spreadRadius: 4, blurRadius: 8),
                        ],
                      ),
                      child: Column(children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24), child: const Text("Foto da queimada", style: TextStyle(color: Colors.white, fontSize: 24))),
                        SizedBox(
                          width: 85,
                          height: 85,
                          child: ElevatedButton(
                            onPressed: () {
                              Utils.vibrate();
                              if (cameraController != null && cameraController!.value.isInitialized && !cameraController!.value.isRecordingVideo) {
                                onTakePictureButtonPressed();
                              }
                            },
                            style: ElevatedButton.styleFrom(shape: const CircleBorder(), backgroundColor: Colors.white.withOpacity(0.75), elevation: 0, shadowColor: Colors.transparent, foregroundColor: AppColors.accent),
                            child: const SizedBox(),
                          ),
                        )
                      ])))
            ])));
  }

  Widget _cameraPreviewWidget() {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return Container(height: (MediaQuery.of(context).size.width * 1.777), width: double.maxFinite, color: Colors.black);
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.width * 1.777,
            child: CameraPreview(
              cameraController!,
              child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onScaleStart: _handleScaleStart,
                  onScaleUpdate: _handleScaleUpdate,
                  onTapDown: (TapDownDetails details) => onViewFinderTap(details, constraints),
                );
              }),
            )),
      );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    if (cameraController == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale).clamp(_minAvailableZoom, _maxAvailableZoom);

    await cameraController!.setZoomLevel(_currentScale);
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (cameraController == null) {
      return;
    }

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController!.setExposurePoint(offset);
    cameraController!.setFocusPoint(offset);
  }

  Future<void> _initializeCameraController(CameraDescription cameraDescription) async {
    cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.veryHigh, // 1080p
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    cameraController!.addListener(() {
      if (cameraController!.value.hasError) {
        showInSnackBar('Camera error ${cameraController!.value.errorDescription}');
        return;
      }
      setState(() {});
    });

    try {
      await cameraController!.initialize();
      await Future.wait(<Future<Object?>>[
        cameraController!.getMaxZoomLevel().then((double value) => _maxAvailableZoom = value),
        cameraController!.getMinZoomLevel().then((double value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.');
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
        case 'AudioAccessRestricted':
          // iOS only
          showInSnackBar('Audio access is restricted.');
        default:
          _showCameraException(e);
          break;
      }
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((XFile? file) {
      Utils.vibrate();
      if (mounted) {
        imageFile = file;
        if (file != null) {
          widget.onCapture(file);
          //showInSnackBar('Picture saved to ${file.path}');
        }
      }
    });
  }

  Future<XFile?> takePicture() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController!.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
