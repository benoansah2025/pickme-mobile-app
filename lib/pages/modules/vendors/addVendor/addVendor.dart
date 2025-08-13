import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:pickme_mobile/components/congratPage.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/infoDialog.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/downloadFile.dart';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/models/businessListingsModel.dart';
import 'package:pickme_mobile/models/subscriptionsModel.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/pages/homepage/mainHomepage.dart';
import 'package:pickme_mobile/pages/modules/vendors/addVendor/widget/vendorGPSWidget.dart';
import 'package:pickme_mobile/pages/modules/vendors/addVendor/widget/vendorSubscriptionWidget.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';
import 'package:pickme_mobile/utils/captureImage.dart';
import 'package:pickme_mobile/utils/webBrower.dart';

import 'widget/addVendorWidget.dart';
import 'widget/subscriptionInfoDialog.dart';
import 'widget/vendorPersonalDetailsWidget.dart';
import 'widget/vendorServiceDetailsWidget.dart';

class AddVendor extends StatefulWidget {
  final ListingDetails? listingDetails;

  const AddVendor({super.key, this.listingDetails});

  @override
  State<AddVendor> createState() => _AddVendorState();
}

class _AddVendorState extends State<AddVendor> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Repository _repo = new Repository();

  final ScrollController _scrollController = new ScrollController();

  int _currentStep = 1;

  final _serviceNameController = new TextEditingController();
  final _emailController = new TextEditingController();
  final _phoneController = new TextEditingController();
  final _vendorNameController = new TextEditingController();
  final _regionController = new TextEditingController();
  final _townController = new TextEditingController();
  final _districtController = new TextEditingController();
  final _streetnameController = new TextEditingController();
  final _gpsAddressController = new TextEditingController();
  final _longitudeController = new TextEditingController();
  final _latitudeController = new TextEditingController();
  final _codeController = new TextEditingController();

  final _serviceNameFocusNode = new FocusNode();
  final _emailFocusNode = new FocusNode();
  final _phoneFocusNode = new FocusNode();
  final _vendorNameFocusNode = new FocusNode();
  final _townFocusNode = new FocusNode();
  final _districtFocusNode = new FocusNode();
  final _streetnameFocusNode = new FocusNode();
  final _gpsAddressFocusNode = FocusNode();
  final _longitudeFocusNode = FocusNode();
  final _latitudeFocusNode = FocusNode();
  final _codeFocusNode = FocusNode();

  String? _imagePath;

  bool _isLoading = false;

  SubscriptionData? _selectedSubscription;

  String _paymentType = "";

  @override
  void initState() {
    super.initState();
    _repo.fetchSubscriptions(true);

    if (widget.listingDetails != null) {
      _serviceNameController.text = widget.listingDetails?.serviceName ?? "";
      _emailController.text = widget.listingDetails?.email ?? "";
      _phoneController.text = widget.listingDetails?.phone ?? "";
      _vendorNameController.text = widget.listingDetails?.businessName ?? "";
      _regionController.text = widget.listingDetails?.region ?? "";
      _townController.text = widget.listingDetails?.town ?? "";
      _districtController.text = widget.listingDetails?.district ?? "";
      _streetnameController.text = widget.listingDetails?.streetname ?? "";
      _gpsAddressController.text = widget.listingDetails?.gpsaddress ?? "";
      _longitudeController.text = widget.listingDetails?.longitude ?? "";
      _latitudeController.text = widget.listingDetails?.latitude ?? "";
      _imagePath = widget.listingDetails?.picture ?? "";
    }
  }

  @override
  void dispose() {
    _serviceNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _vendorNameFocusNode.dispose();
    _townFocusNode.dispose();
    _districtFocusNode.dispose();
    _streetnameFocusNode.dispose();
    _gpsAddressFocusNode.dispose();
    _longitudeFocusNode.dispose();
    _latitudeFocusNode.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool invoke) {
        if (invoke) {
          return;
        }
        if (_currentStep != 1) {
          --_currentStep;
          setState(() {});
        } else {
          navigation(context: context, pageName: "back");
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.listingDetails == null ? "Add Vendor" : "Edit Vendor")),
        body: Stack(
          children: [
            addVendorWidget(
              currentStep: _currentStep,
              onNextAction: () => _onNextAction(),
              context: context,
              isEdit: widget.listingDetails != null,
              child: _currentStep == 1
                  ? vendorServiceDetailsWidget(
                      context: context,
                      onServicePhoto: () => _onServicePhoto(),
                      key: _formKey,
                      serviceNameController: _serviceNameController,
                      emailController: _emailController,
                      phoneController: _phoneController,
                      serviceNameFocusNode: _serviceNameFocusNode,
                      emailFocusNode: _emailFocusNode,
                      imagePath: _imagePath,
                      scrollController: _scrollController,
                      phoneFocusNode: _phoneFocusNode,
                    )
                  : _currentStep == 2
                      ? vendorPersonalDetailsWidget(
                          context: context,
                          key: _formKey,
                          vendorNameController: _vendorNameController,
                          regionController: _regionController,
                          townController: _townController,
                          vendorNameFocusNode: _vendorNameFocusNode,
                          townFocusNode: _townFocusNode,
                          scrollController: _scrollController,
                          onRegion: () => _onRegions(),
                          districtController: _districtController,
                          streetnameController: _streetnameController,
                          districtFocusNode: _districtFocusNode,
                          streetnameFocusNode: _streetnameFocusNode,
                        )
                      : _currentStep == 3
                          ? vendorGPSWidget(
                              context: context,
                              key: _formKey,
                              gpsAddressController: _gpsAddressController,
                              longitudeController: _longitudeController,
                              latitudeController: _latitudeController,
                              gpsAddressFocusNode: _gpsAddressFocusNode,
                              longitudeFocusNode: _longitudeFocusNode,
                              latitudeFocusNode: _latitudeFocusNode,
                              scrollController: _scrollController,
                              onLocation: () => _onLocation(),
                            )
                          : vendorSubscriptionWidget(
                              context: context,
                              scrollController: _scrollController,
                              onSubscriptionInfo: (SubscriptionData data) => _onSubscriptionInfo(data),
                              onSubscription: (SubscriptionData data) => _onSubscription(data),
                              selectedSubscription: _selectedSubscription,
                              paymentType: _paymentType,
                              onPaymentType: (String type) {
                                _onScrollEnd();
                                _paymentType = type;
                                setState(() {});
                              },
                              codeController: _codeController,
                              codeFocusNode: _codeFocusNode,
                            ),
            ),
            if (_isLoading) customLoadingPage(),
          ],
        ),
      ),
    );
  }

  void _onNextAction() {
    _unFocusAllNodes();

    if (_imagePath == null) {
      toastContainer(text: "No image uploaded", backgroundColor: BColors.red);
      return;
    }

    if (widget.listingDetails == null) {
      if (_currentStep != 4 && !_formKey.currentState!.validate()) {
        _onScrollEnd();
        return;
      }

      if (_currentStep == 4) {
        _onScrollEnd();
        if (_selectedSubscription == null) {
          toastContainer(text: "Please select a subscription plan", backgroundColor: BColors.red);
          return;
        }

        if (_paymentType.isEmpty) {
          toastContainer(text: "Please select a payment type", backgroundColor: BColors.red);
          return;
        }

        if (_paymentType == "wallet" && _codeController.text.isEmpty) {
          toastContainer(text: "Please enter a code", backgroundColor: BColors.red);
          return;
        }

        _onConfirmDialog();
        return;
      }
    } else {
      if (_currentStep != 3 && !_formKey.currentState!.validate()) {
        _onScrollEnd();
        return;
      }

      if (_currentStep == 3) {
        _onScrollEnd();
        _onConfirmDialog();
        return;
      }
    }

    ++_currentStep;
    setState(() {});
  }

  void _onConfirmDialog() {
    infoDialog(
      context: context,
      type: PanaraDialogType.warning,
      text: "Please confirm your details before submit",
      confirmBtnText: "Sumbit",
      onConfirmBtnTap: () => widget.listingDetails == null ? _onConfirmNew() : _onConfirmUpdate(),
    );
  }

  Future<void> _onConfirmUpdate() async {
    _onScrollEnd();

    setState(() => _isLoading = true);

    if (_imagePath!.contains("http")) {
      await downloadFile(
        _imagePath,
        filePath: await getFilePath(_imagePath!.split("/").last),
        onDownloadComplete: (String? savePath) async {
          _imagePath = savePath;
          setState(() {});
        },
      );
    }

    final dio = Dio();

    final formData = FormData.fromMap({
      "action": HttpActions.updateBusinessListings,
      "listingId": widget.listingDetails?.businessId,
      "userid": userModel!.data!.user!.userid,
      "businessName": _vendorNameController.text,
      "serviceName": _serviceNameController.text,
      "phone": _phoneController.text,
      "email": _emailController.text,
      "region": _regionController.text,
      "district": _districtController.text,
      "town": _townController.text,
      "streetname": _streetnameController.text,
      "gpsaddress": _gpsAddressController.text,
      "latitude": _latitudeController.text,
      "longitude": _longitudeController.text,
      "picture": await MultipartFile.fromFile(
        _imagePath!,
        filename: _imagePath.toString().split("/").last,
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
      log("body => $data");
      setState(() => _isLoading = false);
      if (statusCode == 200 && data["ok"]) {
        toastContainer(
          text: data["msg"],
          backgroundColor: BColors.green,
        );
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const MainHomepage(selectedPage: 4),
            ),
            (Route<dynamic> route) => false);
        return;
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

  Future<void> _onConfirmNew() async {
    _onScrollEnd();

    setState(() => _isLoading = true);
    final dio = Dio();

    final formData = FormData.fromMap({
      "action": HttpActions.listBusiness,
      "userid": userModel!.data!.user!.userid,
      "subscriptionId": _selectedSubscription?.id,
      "businessName": _vendorNameController.text,
      "serviceName": _serviceNameController.text,
      "phone": _phoneController.text,
      "email": _emailController.text,
      "region": _regionController.text,
      "district": _districtController.text,
      "town": _townController.text,
      "streetname": _streetnameController.text,
      "gpsaddress": _gpsAddressController.text,
      "latitude": _latitudeController.text,
      "longitude": _longitudeController.text,
      "paymentMethod": _paymentType.toUpperCase(),
      "pin": _codeController.text,
      "picture": await MultipartFile.fromFile(
        _imagePath!,
        filename: _imagePath.toString().split("/").last,
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
      log("body => $data");
      setState(() => _isLoading = false);
      if (statusCode == 200 && data["ok"]) {
        if (_paymentType == "wallet") {
          toastContainer(
            text: data["msg"],
            backgroundColor: BColors.green,
          );
          if (!mounted) return;
          _onCongratPage();
          return;
        }

        String paymentUrl = data["data"]["authorization_url"];
        setState(() => _isLoading = false);

        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WebBrowser(
              previousPage: "addVendor",
              url: paymentUrl,
              title: "Make Payment",
              meta: {
                "payment": true,
                "reference": data["data"]["reference"],
              },
            ),
          ),
        );
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

  void _onSubscriptionInfo(SubscriptionData data) {
    showDialog(
      context: context,
      builder: (context) => subscriptionInfoDialog(context: context, data: data),
    );
  }

  void _onSubscription(SubscriptionData data) => setState(() => _selectedSubscription = data);

  Future<void> _onLocation() async {
    setState(() => _isLoading = true);
    Position currentLocation = await Geolocator.getCurrentPosition();
    _latitudeController.text = currentLocation.latitude.toString();
    _longitudeController.text = currentLocation.longitude.toString();
    if (mounted) setState(() => _isLoading = false);
  }

  void _onRegions() {
    _unFocusAllNodes();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Select Region'),
            children: <Widget>[
              for (String region in Arrays.regions) ...[
                SimpleDialogOption(
                  onPressed: () {
                    setState(() {
                      _regionController.text = region;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(region, style: TextStyle(fontSize: 15)),
                ),
                const Divider(),
              ]
            ],
          );
        });
  }

  Future<void> _onServicePhoto() async {
    _unFocusAllNodes();
    File? imagePath = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ImageCapture(),
      ),
    );

    if (imagePath != null) {
      setState(() {
        _imagePath = imagePath.path;
      });
    }
  }

  void _unFocusAllNodes() {
    _serviceNameFocusNode.unfocus();
    _emailFocusNode.unfocus();
    _phoneFocusNode.unfocus();
    _vendorNameFocusNode.unfocus();
    _townFocusNode.unfocus();
    _districtFocusNode.unfocus();
    _streetnameFocusNode.unfocus();
    _gpsAddressFocusNode.unfocus();
    _longitudeFocusNode.unfocus();
    _latitudeFocusNode.unfocus();
    _codeFocusNode.unfocus();
  }

  void _onScrollEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }
}
