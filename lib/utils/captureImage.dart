import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:path_provider/path_provider.dart';

enum ImageCaptureAutoUse { camera, gallery }

class ImageCapture extends StatefulWidget {
  final String? page;
  final ImageCaptureAutoUse? autoUse;
  final bool? compressImage, autoDone;

  const ImageCapture({
    super.key,
    this.page,
    this.autoUse,
    this.compressImage = true,
    this.autoDone = false,
  });

  @override
  State<ImageCapture> createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {
  final imagePicker = ImagePicker();

  /// Active image file
  File? _imageFile;
  bool _isLoading = false;

  /// Cropper plugin
  Future<void> _cropImage() async {
    CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: _imageFile!.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: BColors.primaryColor,
          toolbarWidgetColor: Colors.white,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            _CropAspectRatioPresetCustom(),
          ],
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            _CropAspectRatioPresetCustom(), // IMPORTANT: iOS supports only one custom aspect ratio in preset list
          ],
        ),
      ],
    );

    setState(() {
      _imageFile = cropped != null ? File(cropped.path) : _imageFile;
    });
  }

  /// Select an image via gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final picker = await imagePicker.pickImage(source: source);
    File selected = File(picker!.path);

    setState(() {
      _imageFile = selected;
    });

    if (widget.autoDone!) {
      if (!mounted) return;
      _done(context);
    }
  }

  /// Remove image
  void _clear() {
    setState(() => _imageFile = null);
  }

  Future<void> _done(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    final ByteData dbBytes = _imageFile!.readAsBytesSync().buffer.asByteData();
    try {
      File file = await writeToFile(dbBytes); // <= returns File
      if (kDebugMode) {
        print(file.path);
      }
      if (widget.compressImage!) {
        testCompressAndGetFile(_imageFile!, file.path).then(
          (XFile? path) {
            setState(() {
              _isLoading = false;
            });
            Navigator.pop(context, File(path!.path));
          },
        );
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pop(context, File(file.path));
      }
    } catch (e) {
      // catch errors here
      toastContainer(
        text: "Error uploading image",
        backgroundColor: BColors.red,
      );
    }
  }

  Future<XFile?> testCompressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 35,
      rotate: 0,
    );

    return result;
  }

  Future<File> writeToFile(ByteData data) async {
    final buffer = data.buffer;
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    final String currentTime = DateTime.now().microsecondsSinceEpoch.toString();
    var filePath = '$tempPath/$currentTime.jpg';
    return new File(filePath).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  @override
  void initState() {
    super.initState();
    if (widget.autoUse != null) {
      _pickImage(
        widget.autoUse == ImageCaptureAutoUse.camera ? ImageSource.camera : ImageSource.gallery,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            if (_imageFile != null) ...[
              Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _isLoading ? null : _clear,
                  ),
                  IconButton(
                    icon: const Icon(Icons.crop),
                    onPressed: _isLoading ? null : _cropImage,
                  ),
                  // ignore: deprecated_member_use
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BColors.primaryColor,
                        foregroundColor: BColors.white,
                      ),
                      child: const Text("Done"),
                      onPressed: () => _isLoading ? null : _done(context),
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),

        // Select an image from the camera or gallery
        bottomNavigationBar: Container(
          height: 100,
          color: BColors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: BColors.primaryColor,
                  foregroundColor: BColors.white,
                ),
                icon: const Icon(
                  Icons.photo_camera,
                  size: 50,
                ),
                label: const Text("Camera"),
                onPressed: () => _isLoading ? null : _pickImage(ImageSource.camera),
              ),
              const SizedBox(width: 50),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: BColors.primaryColor,
                  foregroundColor: BColors.white,
                ),
                label: const Text("Gallery"),
                icon: const Icon(
                  Icons.photo_library,
                  size: 50,
                ),
                onPressed: () => _isLoading ? null : _pickImage(ImageSource.gallery),
              ),
            ],
          ),
        ),

        body: Stack(
          children: <Widget>[
            Center(
              child: ListView(
                children: <Widget>[
                  if (_imageFile != null) ...[
                    Container(
                      height: MediaQuery.of(context).size.height * .7,
                      margin: const EdgeInsets.all(20),
                      child: Image.file(_imageFile!),
                    ),
                  ] else
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .7,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(20),
                              child: ClipOval(
                                child: Image.asset(
                                  Images.empty,
                                  width: 200,
                                  height: 200,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Upload picture",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: BColors.white.withOpacity(.8),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(BColors.black),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

class _CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
