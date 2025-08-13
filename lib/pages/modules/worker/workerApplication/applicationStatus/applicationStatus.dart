import 'package:flutter/material.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/models/businessListingsModel.dart';
import 'package:pickme_mobile/models/workersInfoModel.dart';
import 'package:pickme_mobile/pages/modules/worker/workerApplication/applicationDetails/applicationDetails.dart';
import 'package:pickme_mobile/pages/modules/vendors/vendorDetails/vendorDetails.dart';
import 'package:pickme_mobile/spec/arrays.dart';

import 'widget/applicationStatusWidget.dart';

class ApplicationStatus extends StatefulWidget {
  const ApplicationStatus({super.key});

  @override
  State<ApplicationStatus> createState() => _ApplicationStatusState();
}

class _ApplicationStatusState extends State<ApplicationStatus> {
  final Repository _repo = new Repository();

  int _currentToggle = 0;
  ApplicationStatusEnum _applicationStatus = ApplicationStatusEnum.active;

  @override
  void initState() {
    super.initState();
    _repo.fetchWorkerInfo(true);
    _repo.fetchBusinessListings(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: applicationStatusWidget(
        context: context,
        onApplication: (WorkersInfoData data) => _onApplication(data),
        onToggle: (int index) {
          _currentToggle = index;
          setState(() {});
        },
        currentToggle: _currentToggle,
        onVendorFilter: (ApplicationStatusEnum status) {
          _applicationStatus = status;
          setState(() {});
        },
        applicationStatus: _applicationStatus,
        onListingsDetails: (ListingDetails data) => _onListingsDetails(data),
      ),
    );
  }

  void _onListingsDetails(ListingDetails data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VendorDetails(data: data),
      ),
    );
  }

  void _onApplication(WorkersInfoData data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplicationDetails(data: data),
      ),
    );
  }
}
