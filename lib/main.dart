import 'dart:io';
import 'dart:math' as math;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:saver_gallery/saver_gallery.dart';

import 'native_ad.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<bool> _checkPermission({bool request = false}) async {
    PermissionStatus status = request
        ? await Permission.storage.request()
        : await Permission.storage.status;
    AppToast.showToast('status $status');
    return status == PermissionStatus.granted;
  }

  Future<String?> _openGallery() async {
    final result = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (result != null) return result.path;
    return null;
  }

  Future<void> saveToGallery() async {
    final imagePath = await _openGallery();
    if (imagePath != null) {
      await SaverGallery.saveImage(await File(imagePath).readAsBytes(),
          name: "${math.Random().nextInt(1000)}.png");
      AppToast.showToast('Image saved to gallery');
    }
  }

  void _checkConnection() async {
    ConnectivityResult connectivity = await Connectivity().checkConnectivity();
    AppToast.showToast(connectivity.name);
  }

  void _photoManager() async {
    if (await _checkPermission(request: true)) {
      final _albums =
          await PhotoManager.getAssetPathList(type: RequestType.image);
      String result = '';
      for (var element in _albums) {
        result += element.toString();
      }
      AppToast.showToast(result);
    }
  }

  void _showNativeAd() {
    showExitNativeAd(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () => _checkPermission(),
            title: const Text('Check Permission'),
          ),
          ListTile(
            onTap: () => _openGallery(),
            title: const Text('Open Gallery Picker'),
          ),
          ListTile(
            onTap: () => saveToGallery(),
            title: const Text('Save to Gallery'),
          ),
          ListTile(
            onTap: () => _checkConnection(),
            title: const Text('Check Connection'),
          ),
          ListTile(
            onTap: () => _photoManager(),
            title: const Text('Photo Manager'),
          ),
          ListTile(
            onTap: () => _showNativeAd(),
            title: const Text('Show Native Ad'),
          ),
        ],
      ),
    );
  }
}


class AppToast {
  static void showToast(String message) => Fluttertoast.showToast(msg: message);
}