// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ui' show lerpDouble;

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'utils/colors.dart';
import 'utils/scanner_utils.dart';

enum AnimationState { search, barcodeNear, barcodeFound, endSearch }

class MaterialBarcodeScanner extends StatefulWidget {
  const MaterialBarcodeScanner({
    this.validRectangle = const Rectangle(width: 320, height: 144),
    this.frameColor = kShrineScrim,
    this.traceMultiplier = 1.2,
  });

  final Rectangle validRectangle;
  final Color frameColor;
  final double traceMultiplier;

  @override
  _MaterialBarcodeScannerState createState() => _MaterialBarcodeScannerState();
}

class _MaterialBarcodeScannerState extends State<MaterialBarcodeScanner>
    with TickerProviderStateMixin {
  CameraController _cameraController;
  AnimationController _animationController;
  String _scannerHint;
  bool _closeWindow = false;
  String _barcodePictureFilePath;
  Size _previewSize;
  AnimationState _currentState = AnimationState.search;
  CustomPainter _animationPainter;
  int _animationStart = DateTime.now().millisecondsSinceEpoch;
  final BarcodeDetector _barcodeDetector =
      FirebaseVision.instance.barcodeDetector();
  final List<Barcode> _barcodeds = [];

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIOverlays(<SystemUiOverlay>[]);
    SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[DeviceOrientation.portraitUp],
    );
    _initCameraAndScanner();
    _switchAnimationState(AnimationState.search);
  }

  void _initCameraAndScanner() {
    ScannerUtils.getCamera(CameraLensDirection.back).then(
      (CameraDescription camera) async {
        await _openCamera(camera);
        await _startStreamingImagesToScanner(camera.sensorOrientation);
      },
    );
  }

  void _initAnimation(Duration duration) {
    setState(() {
      _animationPainter = null;
    });

    _animationController?.dispose();
    _animationController = AnimationController(duration: duration, vsync: this);
  }

  void _switchAnimationState(AnimationState newState) {
    if (newState == AnimationState.search) {
      _initAnimation(const Duration(milliseconds: 750));

      _animationPainter = RectangleOutlinePainter(
        animation: RectangleTween(
          Rectangle(
            width: widget.validRectangle.width,
            height: widget.validRectangle.height,
            color: Colors.white,
          ),
          Rectangle(
            width: widget.validRectangle.width * widget.traceMultiplier,
            height: widget.validRectangle.height * widget.traceMultiplier,
            color: Colors.transparent,
          ),
        ).animate(_animationController),
      );

      _animationController.addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          Future<void>.delayed(const Duration(milliseconds: 1600), () {
            if (_currentState == AnimationState.search) {
              _animationController.forward(from: 0);
            }
          });
        }
      });
    } else if (newState == AnimationState.barcodeNear ||
        newState == AnimationState.barcodeFound ||
        newState == AnimationState.endSearch) {
      double begin;
      if (_currentState == AnimationState.barcodeNear) {
        begin = lerpDouble(0.0, 0.5, _animationController.value);
      } else if (_currentState == AnimationState.search) {
        _initAnimation(const Duration(milliseconds: 500));
        begin = 0.0;
      }

      _animationPainter = RectangleTracePainter(
        rectangle: Rectangle(
          width: widget.validRectangle.width,
          height: widget.validRectangle.height,
          color: newState == AnimationState.endSearch
              ? Colors.transparent
              : Colors.white,
        ),
        animation: Tween<double>(
          begin: begin,
          end: newState == AnimationState.barcodeNear ? 0.5 : 1.0,
        ).animate(_animationController),
      );

      if (newState == AnimationState.barcodeFound) {
        _animationController.addStatusListener((AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            Future<void>.delayed(const Duration(milliseconds: 300), () {
              if (_currentState != AnimationState.endSearch) {
                _switchAnimationState(AnimationState.endSearch);
                setState(() {});
                _showBottomSheet();
              }
            });
          }
        });
      }
    }

    _currentState = newState;
    if (newState != AnimationState.endSearch) {
      _animationController.forward(from: 0);
      _animationStart = DateTime.now().millisecondsSinceEpoch;
    }
  }

  Future<void> _openCamera(CameraDescription camera) async {
    final ResolutionPreset preset =
        defaultTargetPlatform == TargetPlatform.android
            ? ResolutionPreset.medium
            : ResolutionPreset.low;

    _cameraController = CameraController(camera, preset);
    await _cameraController.initialize();
    _previewSize = _cameraController.value.previewSize;
    setState(() {});
  }

  Future<void> _startStreamingImagesToScanner(int sensorOrientation) async {
    bool isDetecting = false;
    final MediaQueryData data = MediaQuery.of(context);

    _cameraController.startImageStream((CameraImage image) {
      if (isDetecting) {
        return;
      }

      isDetecting = true;

      ScannerUtils.detect(
        image: image,
        detectInImage: _barcodeDetector.detectInImage,
        imageRotation: sensorOrientation,
      ).then(
        (dynamic result) {
          _handleResult(
            barcodes: result as List<Barcode>,
            data: data,
            imageSize: Size(image.width.toDouble(), image.height.toDouble()),
          );
        },
      ).whenComplete(() => isDetecting = false);
    });
  }

  bool get _barcodeNearAnimationInProgress {
    return _currentState == AnimationState.barcodeNear &&
        DateTime.now().millisecondsSinceEpoch - _animationStart < 2500;
  }

  void _handleResult({
    @required List<Barcode> barcodes,
    @required MediaQueryData data,
    @required Size imageSize,
  }) {
    if (!_cameraController.value.isStreamingImages) {
      return;
    }

    final EdgeInsets padding = data.padding;
    final double maxLogicalHeight =
        data.size.height - padding.top - padding.bottom;

    // Width & height are flipped from CameraController.previewSize on iOS
    final double imageHeight = defaultTargetPlatform == TargetPlatform.iOS
        ? imageSize.height
        : imageSize.width;

    final double imageScale = imageHeight / maxLogicalHeight;
    final double halfWidth = imageScale * widget.validRectangle.width / 2;
    final double halfHeight = imageScale * widget.validRectangle.height / 2;

    final Offset center = imageSize.center(Offset.zero);
    final Rect validRect = Rect.fromLTRB(
      center.dx - halfWidth,
      center.dy - halfHeight,
      center.dx + halfWidth,
      center.dy + halfHeight,
    );

    for (Barcode barcode in barcodes) {
      final Rect intersection = validRect.intersect(barcode.boundingBox);

      final bool doesContain = intersection == barcode.boundingBox;

      if (doesContain) {
        _cameraController.stopImageStream().then((_) => _takePicture());

        if (_currentState != AnimationState.barcodeFound) {
          _closeWindow = true;
          _scannerHint = 'Loading Information...';

          final String rawValue = barcode.rawValue;
          print(rawValue);
          _barcodeds.clear();
          _barcodeds.add(barcode);

          _switchAnimationState(AnimationState.barcodeFound);
          setState(() {});
        }
        return;
      } else if (barcode.boundingBox.overlaps(validRect)) {
        if (_currentState != AnimationState.barcodeNear) {
          _scannerHint = 'Move closer to the barcode';
          _switchAnimationState(AnimationState.barcodeNear);
          setState(() {});
        }
        return;
      }
    }

    if (_barcodeNearAnimationInProgress) {
      return;
    }

    if (_currentState != AnimationState.search) {
      _scannerHint = null;
      _switchAnimationState(AnimationState.search);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _currentState = AnimationState.endSearch;
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _animationController?.dispose();
    _barcodeDetector.close();

    SystemChrome.setPreferredOrientations(<DeviceOrientation>[]);
    SystemChrome.setEnabledSystemUIOverlays(<SystemUiOverlay>[
      SystemUiOverlay.top,
      SystemUiOverlay.bottom,
    ]);

    super.dispose();
  }

  Future<void> _takePicture() async {
    final Directory extDir = await getApplicationDocumentsDirectory();

    final String dirPath = '${extDir.path}/Pictures/barcodePics';
    await Directory(dirPath).create(recursive: true);

    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    final String filePath = '$dirPath/$timestamp.jpg';

    try {
      await _cameraController.takePicture(filePath);
    } on CameraException catch (e) {
      print(e);
    }

    _cameraController.dispose();
    _cameraController = null;

    setState(() {
      _barcodePictureFilePath = filePath;
    });
  }

  Widget _buildCameraPreview() {
    return Container(
      color: Colors.black,
      child: Transform.scale(
        scale: _getImageZoom(MediaQuery.of(context)),
        child: Center(
          child: AspectRatio(
            aspectRatio: _cameraController.value.aspectRatio,
            child: CameraPreview(_cameraController),
          ),
        ),
      ),
    );
  }

  double _getImageZoom(MediaQueryData data) {
    final double logicalWidth = data.size.width;
    final double logicalHeight = _previewSize.aspectRatio * logicalWidth;

    final EdgeInsets padding = data.padding;
    final double maxLogicalHeight =
        data.size.height - padding.top - padding.bottom;

    return maxLogicalHeight / logicalHeight;
  }

  Map<String, String> _barcodeValueMap(Barcode barcode) {
    final valueType = barcode.valueType;
    final barcodeValuesMap = {'rawValue': barcode.rawValue};

    switch (valueType) {
      case BarcodeValueType.wifi:
        final wiFiEncryptionType = BarcodeWiFiEncryptionType.values
            .map((value) => value.toString().split('.')[1])
            .toList();
        barcodeValuesMap['BarcodeValueType'] = 'wifi';
        barcodeValuesMap['ssid'] = barcode.wifi.ssid;
        barcodeValuesMap['password'] = barcode.wifi.password;
        barcodeValuesMap['WiFiEncryptionType'] =
            wiFiEncryptionType[barcode.wifi.encryptionType.index];
        break;
      case BarcodeValueType.url:
        barcodeValuesMap['BarcodeValueType'] = 'url';
        barcodeValuesMap['title'] = barcode.url.title;
        barcodeValuesMap['url'] = barcode.url.url;
        break;
      case BarcodeValueType.unknown:
        barcodeValuesMap['BarcodeValueType'] = 'unknown';
        barcodeValuesMap['displayValue'] = barcode.displayValue;
        break;
      case BarcodeValueType.contactInfo:
        barcodeValuesMap['BarcodeValueType'] = 'contactInfo';
        barcodeValuesMap['addresses'] = barcode.contactInfo.addresses.join(',');
        barcodeValuesMap['emails'] = barcode.contactInfo.emails.join(',');
        barcodeValuesMap['jobTitle'] = barcode.contactInfo.jobTitle;
        barcodeValuesMap['firstName'] = barcode.contactInfo.name.first;
        barcodeValuesMap['middleName'] = barcode.contactInfo.name.middle;
        barcodeValuesMap['lastName'] = barcode.contactInfo.name.last;
        barcodeValuesMap['prefixName'] = barcode.contactInfo.name.prefix;
        barcodeValuesMap['suffixName'] = barcode.contactInfo.name.suffix;
        barcodeValuesMap['formattedName'] =
            barcode.contactInfo.name.formattedName;
        barcodeValuesMap['pronunciationName'] =
            barcode.contactInfo.name.pronunciation;
        barcodeValuesMap['pronunciationName'] =
            barcode.contactInfo.name.pronunciation;
        barcodeValuesMap['organization'] = barcode.contactInfo.organization;
        barcodeValuesMap['phones'] = barcode.contactInfo.phones.join(',');
        barcodeValuesMap['urls'] = barcode.contactInfo.urls.join(',');
        break;
      case BarcodeValueType.email:
        final emailType = BarcodeEmailType.values
            .map((value) => value.toString().split('.')[1])
            .toList();
        barcodeValuesMap['BarcodeValueType'] = 'email';
        barcodeValuesMap['address'] = barcode.email.address;
        barcodeValuesMap['subject'] = barcode.email.subject;
        barcodeValuesMap['body'] = barcode.email.body;
        barcodeValuesMap['type'] = emailType[barcode.email.type.index];
        break;
      case BarcodeValueType.isbn:
        barcodeValuesMap['BarcodeValueType'] = 'isbn';
        barcodeValuesMap['displayValue'] = barcode.displayValue;
        break;
      case BarcodeValueType.phone:
        final phoneType = BarcodePhoneType.values
            .map((value) => value.toString().split('.')[1])
            .toList();
        barcodeValuesMap['BarcodeValueType'] = 'phone';
        barcodeValuesMap['number'] = barcode.phone.number;
        barcodeValuesMap['type'] = phoneType[barcode.phone.type.index];
        break;
      case BarcodeValueType.product:
        barcodeValuesMap['BarcodeValueType'] = 'product';
        barcodeValuesMap['displayValue'] = barcode.displayValue;
        break;
      case BarcodeValueType.sms:
        barcodeValuesMap['BarcodeValueType'] = 'sms';
        barcodeValuesMap['phoneNumber'] = barcode.sms.phoneNumber;
        barcodeValuesMap['message'] = barcode.sms.message;
        break;
      case BarcodeValueType.text:
        barcodeValuesMap['BarcodeValueType'] = 'text';
        barcodeValuesMap['displayValue'] = barcode.displayValue;
        break;
      case BarcodeValueType.geographicCoordinates:
        barcodeValuesMap['BarcodeValueType'] = 'geographicCoordinates';
        barcodeValuesMap['latitude'] = barcode.geoPoint.latitude.toString();
        barcodeValuesMap['longitude'] = barcode.geoPoint.longitude.toString();
        break;
      case BarcodeValueType.calendarEvent:
        barcodeValuesMap['BarcodeValueType'] = 'calendarEvent';
        barcodeValuesMap['summary'] = barcode.calendarEvent.summary;
        barcodeValuesMap['eventDescription'] =
            barcode.calendarEvent.eventDescription;
        barcodeValuesMap['start'] =
            barcode.calendarEvent.start.toIso8601String();
        barcodeValuesMap['end'] = barcode.calendarEvent.end.toIso8601String();
        barcodeValuesMap['location'] = barcode.calendarEvent.location;
        barcodeValuesMap['organizer'] = barcode.calendarEvent.organizer;
        barcodeValuesMap['status'] = barcode.calendarEvent.status;
        break;
      case BarcodeValueType.driverLicense:
        barcodeValuesMap['BarcodeValueType'] = 'driverLicense';
        barcodeValuesMap['firstName'] = barcode.driverLicense.firstName;
        barcodeValuesMap['middleName'] = barcode.driverLicense.middleName;
        barcodeValuesMap['lastName'] = barcode.driverLicense.lastName;
        barcodeValuesMap['birthDate'] = barcode.driverLicense.birthDate;
        barcodeValuesMap['gender'] = barcode.driverLicense.gender;
        barcodeValuesMap['addressStreet'] = barcode.driverLicense.addressStreet;
        barcodeValuesMap['addressCity'] = barcode.driverLicense.addressCity;
        barcodeValuesMap['addressState'] = barcode.driverLicense.addressState;
        barcodeValuesMap['addressZip'] = barcode.driverLicense.addressZip;
        barcodeValuesMap['licenseNumber'] = barcode.driverLicense.licenseNumber;
        barcodeValuesMap['expiryDate'] = barcode.driverLicense.expiryDate;
        barcodeValuesMap['issuingDate'] = barcode.driverLicense.issuingDate;
        barcodeValuesMap['issuingCountry'] =
            barcode.driverLicense.issuingCountry;
        barcodeValuesMap['documentType'] = barcode.driverLicense.documentType;
        break;
    }
    return barcodeValuesMap;
  }

  Widget _showBarcodeValues() {
    final result = _barcodeds.map((e) {
      final barcodeMap = _barcodeValueMap(e);
      return Container(
          margin: const EdgeInsets.only(top: 10),
          child: Column(children: <Widget>[
            Table(
              children: barcodeMap.entries
                  .map((e) => TableRow(children: [
                        Text(e.key),
                        Text(e.value),
                      ]))
                  .toList(),
            ),
            Container(
                padding: const EdgeInsets.only(top: 20),
                alignment: Alignment.center,
                child: ButtonTheme(
                  minWidth: 312,
                  height: 48,
                  child: RaisedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    label: const Text('SAVE'),
                    icon: const Icon(Icons.save),
                    elevation: 8.0,
                    shape: const BeveledRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(7.0),
                      ),
                    ),
                  ),
                ))
          ]));
    });

    return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: result.toList(),
        ));
  }

  void _showBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          height: 368,
          child: Column(
            children: <Widget>[
              Container(
                height: 56,
                alignment: Alignment.centerLeft,
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '${_barcodeds.length} result found',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ),
              Expanded(child: _showBarcodeValues()),
            ],
          ),
        );
      },
    ).then((_) => _reset());
  }

  void _reset() {
    _initCameraAndScanner();
    setState(() {
      _closeWindow = false;
      _barcodePictureFilePath = null;
      _scannerHint = null;
      _switchAnimationState(AnimationState.search);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget background;
    if (_barcodePictureFilePath != null) {
      background = Container(
        color: Colors.black,
        child: Transform.scale(
          scale: _getImageZoom(MediaQuery.of(context)),
          child: Center(
            child: Image.file(
              File(_barcodePictureFilePath),
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      );
    } else if (_cameraController != null &&
        _cameraController.value.isInitialized) {
      background = _buildCameraPreview();
    } else {
      background = Container(
        color: Colors.black,
      );
    }

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            background,
            Container(
              constraints: const BoxConstraints.expand(),
              child: CustomPaint(
                painter: WindowPainter(
                  windowSize: Size(widget.validRectangle.width,
                      widget.validRectangle.height),
                  outerFrameColor: widget.frameColor,
                  closeWindow: _closeWindow,
                  innerFrameColor: _currentState == AnimationState.endSearch
                      ? Colors.transparent
                      : kShrineFrameBrown,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: const <Color>[Colors.black87, Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0.0,
              bottom: 0.0,
              right: 0.0,
              height: 56,
              child: Container(
                child: Center(
                  child: Text(
                    _scannerHint ?? 'Point your camera at a barcode',
                    style: Theme.of(context).textTheme.button,
                  ),
                ),
              ),
            ),
            Container(
              constraints: const BoxConstraints.expand(),
              child: CustomPaint(
                painter: _animationPainter,
              ),
            ),
            AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              actions: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.flash_off,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.help_outline,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WindowPainter extends CustomPainter {
  WindowPainter({
    @required this.windowSize,
    this.outerFrameColor = Colors.white54,
    this.innerFrameColor = const Color(0xFF442C2E),
    this.innerFrameStrokeWidth = 3,
    this.closeWindow = false,
  });

  final Size windowSize;
  final Color outerFrameColor;
  final Color innerFrameColor;
  final double innerFrameStrokeWidth;
  final bool closeWindow;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double windowHalfWidth = windowSize.width / 2;
    final double windowHalfHeight = windowSize.height / 2;

    final Rect windowRect = Rect.fromLTRB(
      center.dx - windowHalfWidth,
      center.dy - windowHalfHeight,
      center.dx + windowHalfWidth,
      center.dy + windowHalfHeight,
    );

    final Rect left =
        Rect.fromLTRB(0, windowRect.top, windowRect.left, windowRect.bottom);
    final Rect top = Rect.fromLTRB(0, 0, size.width, windowRect.top);
    final Rect right = Rect.fromLTRB(
      windowRect.right,
      windowRect.top,
      size.width,
      windowRect.bottom,
    );
    final Rect bottom = Rect.fromLTRB(
      0,
      windowRect.bottom,
      size.width,
      size.height,
    );

    canvas.drawRect(
        windowRect,
        Paint()
          ..color = innerFrameColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = innerFrameStrokeWidth);

    final Paint paint = Paint()..color = outerFrameColor;
    canvas.drawRect(left, paint);
    canvas.drawRect(top, paint);
    canvas.drawRect(right, paint);
    canvas.drawRect(bottom, paint);

    if (closeWindow) {
      canvas.drawRect(windowRect, paint);
    }
  }

  @override
  bool shouldRepaint(WindowPainter oldDelegate) =>
      oldDelegate.closeWindow != closeWindow;
}

class Rectangle {
  const Rectangle({this.width, this.height, this.color});

  final double width;
  final double height;
  final Color color;

  static Rectangle lerp(Rectangle begin, Rectangle end, double t) {
    Color color;
    if (t > .5) {
      color = Color.lerp(begin.color, end.color, (t - .5) / .25);
    } else {
      color = begin.color;
    }

    return Rectangle(
      width: lerpDouble(begin.width, end.width, t),
      height: lerpDouble(begin.height, end.height, t),
      color: color,
    );
  }
}

class RectangleTween extends Tween<Rectangle> {
  RectangleTween(Rectangle begin, Rectangle end)
      : super(begin: begin, end: end);

  @override
  Rectangle lerp(double t) => Rectangle.lerp(begin, end, t);
}

class RectangleOutlinePainter extends CustomPainter {
  RectangleOutlinePainter({
    @required this.animation,
    this.strokeWidth = 3,
  }) : super(repaint: animation);

  final Animation<Rectangle> animation;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Rectangle rectangle = animation.value;

    final Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = rectangle.color
      ..style = PaintingStyle.stroke;

    final Offset center = size.center(Offset.zero);
    final double halfWidth = rectangle.width / 2;
    final double halfHeight = rectangle.height / 2;

    final Rect rect = Rect.fromLTRB(
      center.dx - halfWidth,
      center.dy - halfHeight,
      center.dx + halfWidth,
      center.dy + halfHeight,
    );

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(RectangleOutlinePainter oldDelegate) => false;
}

class RectangleTracePainter extends CustomPainter {
  RectangleTracePainter({
    @required this.animation,
    @required this.rectangle,
    this.strokeWidth = 3,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Rectangle rectangle;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final double value = animation.value;

    final Offset center = size.center(Offset.zero);
    final double halfWidth = rectangle.width / 2;
    final double halfHeight = rectangle.height / 2;

    final Rect rect = Rect.fromLTRB(
      center.dx - halfWidth,
      center.dy - halfHeight,
      center.dx + halfWidth,
      center.dy + halfHeight,
    );

    final Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = rectangle.color;

    final double halfStrokeWidth = strokeWidth / 2;

    final double heightProportion = (halfStrokeWidth + rect.height) * value;
    final double widthProportion = (halfStrokeWidth + rect.width) * value;

    canvas.drawLine(
      Offset(rect.right, rect.bottom + halfStrokeWidth),
      Offset(rect.right, rect.bottom - heightProportion),
      paint,
    );

    canvas.drawLine(
      Offset(rect.right + halfStrokeWidth, rect.bottom),
      Offset(rect.right - widthProportion, rect.bottom),
      paint,
    );

    canvas.drawLine(
      Offset(rect.left, rect.top - halfStrokeWidth),
      Offset(rect.left, rect.top + heightProportion),
      paint,
    );

    canvas.drawLine(
      Offset(rect.left - halfStrokeWidth, rect.top),
      Offset(rect.left + widthProportion, rect.top),
      paint,
    );
  }

  @override
  bool shouldRepaint(RectangleTracePainter oldDelegate) => false;
}
