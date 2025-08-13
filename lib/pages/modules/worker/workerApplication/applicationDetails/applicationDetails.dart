import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:face_camera/face_camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/congratPage.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/downloadFile.dart';
import 'package:pickme_mobile/config/firebase/firebaseService.dart';
import 'package:pickme_mobile/config/globalFunction.dart' hide getFilePath;
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/models/workersInfoModel.dart';
import 'package:pickme_mobile/pages/homepage/mainHomepage.dart';
import 'package:pickme_mobile/providers/vehicleTypesProvider.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/strings.dart';
import 'package:pickme_mobile/spec/styles.dart';
import 'package:pickme_mobile/spec/theme.dart';
import 'package:pickme_mobile/utils/captureImage.dart';
import 'package:pickme_mobile/utils/faceCapturing.dart';

import 'widget/applicationDetailsWidget.dart';

enum ApplicationDetailsPopup { textbox, date, selection, file, color }

class ApplicationDetails extends StatefulWidget {
  final WorkersInfoData data;

  const ApplicationDetails({super.key, required this.data});

  @override
  State<ApplicationDetails> createState() => _ApplicationDetailsState();
}

class _ApplicationDetailsState extends State<ApplicationDetails> {
  final ScrollController _scrollController = new ScrollController();
  final Repository _repo = new Repository();
  final FirebaseService _firebaseService = new FirebaseService();

  bool _isLoading = false, _isEdit = false;

  WorkersInfoData? _workersInfoData;

  Map<String, dynamic> _updateFieldMap = {};

  @override
  void initState() {
    super.initState();
    _updateFieldMap = widget.data.toJson();
    _workersInfoData = widget.data;

    _repo.fetchVehicleTypes(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (!_isEdit)
            Padding(
              padding: const EdgeInsets.all(10),
              child: CircleAvatar(
                backgroundColor: BColors.primaryColor,
                child: IconButton(
                  color: BColors.white,
                  onPressed: () => _onEditTap(),
                  icon: const Icon(Icons.edit),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          applicationDetailsWidget(
            context: context,
            scrollController: _scrollController,
            data: _workersInfoData!,
            updateApplication: () => _onUpdateApplication(),
            isEdit: _isEdit,
            onEditLayout: (
              String field,
              ApplicationDetailsPopup popup,
              String title,
            ) =>
                _onEditLayout(field, popup, title),
            onServiceRemove: (int index) => _onServiceRemove(index),
            onAddService: () => _onAddService(),
          ),
          if (_isLoading) customLoadingPage(),
        ],
      ),
    );
  }

  Future<void> _onUpdateApplication() async {
    setState(() => _isLoading = true);
    final dio = Dio();

    if (_workersInfoData!.picture!.contains("http")) {
      await downloadFile(
        _workersInfoData!.picture,
        filePath: await getFilePath(_workersInfoData!.picture!.split("/").last),
        onDownloadComplete: (String? savePath) async {
          _workersInfoData!.picture = savePath;
          setState(() {});
        },
      );
    }
    if (_workersInfoData!.licenseFront!.contains("http")) {
      await downloadFile(
        _workersInfoData!.licenseFront,
        filePath: await getFilePath(_workersInfoData!.licenseFront!.split("/").last),
        onDownloadComplete: (String? savePath) async {
          _workersInfoData!.licenseFront = savePath;
          setState(() {});
        },
      );
    }
    if (_workersInfoData!.licenseBack!.contains("http")) {
      await downloadFile(
        _workersInfoData!.licenseBack,
        filePath: await getFilePath(_workersInfoData!.licenseBack!.split("/").last),
        onDownloadComplete: (String? savePath) async {
          _workersInfoData!.licenseBack = savePath;
          setState(() {});
        },
      );
    }
    if (_workersInfoData!.ghanaCardFront!.contains("http")) {
      await downloadFile(
        _workersInfoData!.ghanaCardFront,
        filePath: await getFilePath(_workersInfoData!.ghanaCardFront!.split("/").last),
        onDownloadComplete: (String? savePath) async {
          _workersInfoData!.ghanaCardFront = savePath;
          setState(() {});
        },
      );
    }
    if (_workersInfoData!.ghanaCardBack!.contains("http")) {
      await downloadFile(
        _workersInfoData!.ghanaCardBack,
        filePath: await getFilePath(_workersInfoData!.ghanaCardBack!.split("/").last),
        onDownloadComplete: (String? savePath) async {
          _workersInfoData!.ghanaCardBack = savePath;
          setState(() {});
        },
      );
    }
    if (_workersInfoData!.insuranceImage!.contains("http")) {
      await downloadFile(
        _workersInfoData!.insuranceImage,
        filePath: await getFilePath(_workersInfoData!.insuranceImage!.split("/").last),
        onDownloadComplete: (String? savePath) async {
          _workersInfoData!.insuranceImage = savePath;
          setState(() {});
        },
      );
    }
    if (_workersInfoData!.roadWorthyImage!.contains("http")) {
      await downloadFile(
        _workersInfoData!.roadWorthyImage,
        filePath: await getFilePath(_workersInfoData!.roadWorthyImage!.split("/").last),
        onDownloadComplete: (String? savePath) async {
          _workersInfoData!.roadWorthyImage = savePath;
          setState(() {});
        },
      );
    }
    final formData = FormData.fromMap({
      "action": HttpActions.updateWorker,
      "userid": userModel!.data!.user!.userid,
      "name": _workersInfoData!.name,
      "dob": _workersInfoData!.dob,
      "gender": _workersInfoData!.gender,
      "licenseNumber": _workersInfoData!.licenseNumber,
      "expiryDate": _workersInfoData!.expiryDate,
      "vehicleType": _workersInfoData!.vehicleTypeId,
      "pickmeRollNo": _workersInfoData!.pickmeRollNo,
      "vehicleMake": _workersInfoData!.vehicleMake,
      "vehicleModel": _workersInfoData!.vehicleModel,
      "vehicleYear": _workersInfoData!.vehicleYear,
      "vehicleNumber": _workersInfoData!.vehicleNumber,
      "vehicleColor": _workersInfoData!.vehicleColor,
      "insuranceExpiryDate": _workersInfoData!.insuranceExpiryDate,
      "roadWorthyExpiryDate": _workersInfoData!.roadWorthyExpiryDate,
      for (int x = 0; x < _workersInfoData!.services!.length; ++x)
        "services[$x]": _workersInfoData!.services![x].toUpperCase(),
      "mainService": _workersInfoData!.services!.first,
      "ghanacardNo": _workersInfoData!.ghanacardNo,
      "picture": await MultipartFile.fromFile(
        _workersInfoData!.picture!,
        filename: _workersInfoData!.picture.toString().split("/").last,
      ),
      "licenseFrontImage": await MultipartFile.fromFile(
        _workersInfoData!.licenseFront!,
        filename: _workersInfoData!.licenseFront!.toString().split("/").last,
      ),
      "licenseBackImage": await MultipartFile.fromFile(
        _workersInfoData!.licenseBack!,
        filename: _workersInfoData!.licenseBack!.toString().split("/").last,
      ),
      "ghanaCardFrontImage": await MultipartFile.fromFile(
        _workersInfoData!.ghanaCardFront!,
        filename: _workersInfoData!.ghanaCardFront!.toString().split("/").last,
      ),
      "ghanaCardBackImage": await MultipartFile.fromFile(
        _workersInfoData!.ghanaCardBack!,
        filename: _workersInfoData!.ghanaCardBack!.toString().split("/").last,
      ),
      "insuranceImage": await MultipartFile.fromFile(
        _workersInfoData!.insuranceImage!,
        filename: _workersInfoData!.insuranceImage!.toString().split("/").last,
      ),
      "roadWorthyImage": await MultipartFile.fromFile(
        _workersInfoData!.roadWorthyImage!,
        filename: _workersInfoData!.roadWorthyImage!.toString().split("/").last,
      ),
    });

    try {
      final response = await dio.post(
        HttpServices.fullurl,
        data: formData,
        options: Options(
          headers: {"Authorization": "Bearer ${userModel!.data!.authToken}"},
        ),
      );
      var statusCode = response.statusCode;
      var data = response.data;
      await _repo.fetchWorkerInfo(true);
      log("body => $data");
      setState(() => _isLoading = false);
      if (statusCode == 200 && data["ok"]) {
        _onCongratPage();
      } else {
        toastContainer(
          text: data["msg"],
          backgroundColor: BColors.red,
        );
      }
    } catch (e) {
      log(e.toString());
      setState(() => _isLoading = false);
      toastContainer(
        text: e.toString(),
        backgroundColor: BColors.red,
      );
    }
  }

  void _onCongratPage() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => CongratPage(
            homeButtonText: "Ok",
            fillBottomButton: true,
            onHome: (context) => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const MainHomepage(selectedPage: 4),
                ),
                (Route<dynamic> route) => false),
            widget: Column(
              children: [
                Text(
                  "We're reviewing your document",
                  style: Styles.h3BlackBold,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Text(
                  "This process usually takes less than a day for us to complete ",
                  style: Styles.h5Black,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
        (Route<dynamic> route) => false);
  }

  void _onAddService() {
    List<String> servicesList = ["Rider", "Driver", "Shopper", "Delivery Guy"];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Service'),
          children: <Widget>[
            for (String service in servicesList) ...[
              SimpleDialogOption(
                onPressed: () {
                  if (_workersInfoData!.services.toString().toLowerCase().contains(service.toLowerCase())) {
                    toastContainer(
                      text: "Service already selected",
                      backgroundColor: BColors.red,
                    );
                    return;
                  }

                  setState(() {
                    _workersInfoData!.services!.add(service);
                  });
                  Navigator.of(context).pop();
                },
                child: Text(
                  service,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const Divider(),
            ],
          ],
        );
      },
    );
  }

  void _onServiceRemove(int index) {
    _workersInfoData!.services!.removeAt(index);
    setState(() {});
  }

  void _onEditLayout(
    String field,
    ApplicationDetailsPopup popup,
    String title,
  ) {
    if (popup == ApplicationDetailsPopup.file) {
      if (field == "picture") {
        _onSnap(field);
      } else {
        _onUploadDocument(field);
      }
    } else if (popup == ApplicationDetailsPopup.date) {
      _onDate(field, DateTime.parse(_workersInfoData!.toJson()[field]));
    } else if (popup == ApplicationDetailsPopup.selection) {
      if (field == "gender") _onGender(field);
      if (field == "vehicleTypeId") _onVehicleType(field);
      if (field == "vehicleYear") _onVehicleYear(field);
    } else if (popup == ApplicationDetailsPopup.color) {
      _onSelectVehicleColor(field, _workersInfoData!.toJson()[field]);
    } else if (popup == ApplicationDetailsPopup.textbox) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController controller = new TextEditingController(
            text: _workersInfoData!.toJson()[field],
          );
          FocusNode focusNode = new FocusNode();
          focusNode.requestFocus();

          return StatefulBuilder(
            builder: (context, dialogSetState) {
              return SimpleDialog(
                contentPadding: const EdgeInsets.all(10),
                title: Text(title, style: Styles.h5Black),
                children: [
                  textFormField(
                    hintText: "Enter $title",
                    controller: controller,
                    focusNode: focusNode,
                    validateMsg: Strings.requestField,
                    inputType: TextInputType.name,
                  ),
                  const SizedBox(height: 20),
                  button(
                    onPressed: () {
                      if (controller.text.isEmpty) {
                        toastContainer(
                          text: "text field cannot be empty",
                          backgroundColor: BColors.red,
                        );
                        return;
                      }
                      focusNode.unfocus();
                      _updateFieldMap[field] = controller.text;
                      _workersInfoData = WorkersInfoData.fromJson(_updateFieldMap);
                      dialogSetState(() {});
                      setState(() {});
                      Navigator.pop(context);
                    },
                    text: "Done",
                    color: BColors.primaryColor,
                    context: context,
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  Future<void> _onUploadDocument(String field) async {
    File imagePath = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ImageCapture(),
      ),
    );
    _updateFieldMap[field] = imagePath.path;
    _workersInfoData = WorkersInfoData.fromJson(_updateFieldMap);
    setState(() {});
  }

  Future<void> _onSnap(String field) async {
    await FaceCamera.initialize();
    if (!mounted) return;
    String imagePath = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FaceCapturing(),
      ),
    );
    _updateFieldMap[field] = imagePath;
    _workersInfoData = WorkersInfoData.fromJson(_updateFieldMap);
    setState(() {});
  }

  void _onSelectVehicleColor(String field, String color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pick a color!', style: Styles.h5BlackBold),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: convertToColor(color),
            onColorChanged: (Color color) {
              _updateFieldMap[field] = color.toHexString();
              _workersInfoData = WorkersInfoData.fromJson(_updateFieldMap);
              setState(() {});
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  void _onVehicleYear(String field) {
    showDialog(
      context: context,
      builder: (context) {
        final Size size = MediaQuery.of(context).size;
        return AlertDialog(
          title: const Text('Select a Year'),
          contentPadding: const EdgeInsets.all(10),
          content: SizedBox(
            height: size.height / 1.3,
            width: size.width,
            child: GridView.count(
              crossAxisCount: 3,
              children: [
                ...List.generate(
                  40,
                  (index) => InkWell(
                    onTap: () {
                      _updateFieldMap[field] = (DateTime.now().year - index).toString();
                      _workersInfoData = WorkersInfoData.fromJson(_updateFieldMap);
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: Chip(
                      label: Container(
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          (DateTime.now().year - index).toString(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onVehicleType(String field) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Select Vehicle Type'),
            children: <Widget>[
              for (var data in vehicleTypesModel!.data!) ...[
                SimpleDialogOption(
                  onPressed: () {
                    setState(() {
                      _updateFieldMap[field] = data.id;
                      _updateFieldMap["vehicleType"] = data.name;
                      _workersInfoData = WorkersInfoData.fromJson(_updateFieldMap);
                    });
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        getVehicleTypePicture(data.id!),
                        height: 30,
                        // ignore: deprecated_member_use
                        color: BColors.black,
                      ),
                      const SizedBox(width: 20),
                      Text(data.name!, style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
                const Divider(),
              ],
            ],
          );
        });
  }

  void _onGender(String field) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select gender'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _updateFieldMap[field] = "Male";
                  _workersInfoData = WorkersInfoData.fromJson(_updateFieldMap);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Male', style: TextStyle(fontSize: 20)),
            ),
            const Divider(),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _updateFieldMap[field] = "Female";
                  _workersInfoData = WorkersInfoData.fromJson(_updateFieldMap);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Female', style: TextStyle(fontSize: 20)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onDate(String field, DateTime date) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(field == "dob" ? 1900 : 2010),
      lastDate: DateTime(field == "dob" ? 2025 : 2050),
      builder: (BuildContext? context, Widget? child) {
        return Theme(
          data: Themes.datePickerTheme(),
          child: child!,
        );
      },
    );
    if (selected != null) {
      if (field == "dob") {
        _updateFieldMap[field] = selected.toIso8601String().split("T")[0];
      } else {
        if (field == "roadWorthyExpiryDate") {
          _updateFieldMap[field] = selected.toIso8601String().split("T")[0];
        } else if (field == "insuranceExpiryDate") {
          _updateFieldMap[field] = selected.toIso8601String().split("T")[0];
        } else {
          _updateFieldMap[field] = selected.toIso8601String().split("T")[0];
        }
      }
      _workersInfoData = WorkersInfoData.fromJson(_updateFieldMap);
      setState(() {});
    }
  }

  Future<void> _onEditTap() async {
    setState(() => _isLoading = true);

    // fetching vehicle type
    if (vehicleTypesModel == null) {
      await _repo.fetchVehicleTypes(true);
    }

    if (vehicleTypesModel != null) {
      String status = await FirebaseService().getWorkerStatus(userModel!.data!.user!.userid!);
      setState(() => _isLoading = false);
      if (status != "INACTIVE") {
        toastContainer(text: "You cannot edit profile while online", backgroundColor: BColors.red);
        return;
      }

      _isEdit = true;
      setState(() {});
    } else {
      toastContainer(text: "Error getting vehicle types, please report", backgroundColor: BColors.red);
      _firebaseService.reportErrors(
        "Error getting vehicle types at _onEditTap()/applicationDetails",
        "",
        requestBody: null,
      );
    }
  }
}
