import 'package:flutter/material.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/models/workersAppreciationModel.dart';
import 'package:pickme_mobile/providers/workersAppreciationProvider.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

import 'widget/workerAppreciationWidget.dart';

class WorkerAppreciation extends StatefulWidget {
  const WorkerAppreciation({super.key});

  @override
  State<WorkerAppreciation> createState() => _WorkerAppreciationState();
}

class _WorkerAppreciationState extends State<WorkerAppreciation> {
  final Repository _repo = new Repository();
  final ScrollController _scrollController = ScrollController();

  List<Data> _allAppreciations = [];
  List<Data> _displayedAppreciation = [];
  int _displayCount = 15; // Number of items to display initially
  bool _isLoading = false, _isContainItems = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAllAppreciation();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: BColors.white),
        backgroundColor: BColors.primaryColor,
        title: Text("Promotions", style: Styles.h4WhiteBold),
      ),
      body: workerAppreciationWidget(
        context: context,
        appreciation: _displayedAppreciation,
        scrollController: _scrollController,
        isLoading: _isLoading,
        isContainItems: _isContainItems,
      ),
    );
  }

  // Fetch all appreciation at once
  void _fetchAllAppreciation() async {
    setState(() {
      _isLoading = true;
    });

    await _repo.fetchWorkersAppreciation(true);
    final appreciationData = workersAppreciationModel!.data;

    setState(() {
      _allAppreciations = appreciationData ?? [];
      _displayedAppreciation = _allAppreciations.take(_displayCount).toList(); // Display initial 15 items
      _isLoading = false;
      _isContainItems = _displayedAppreciation.isNotEmpty;
    });
  }

  // Handle scroll to load more items
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent &&
        !_isLoading &&
        _displayedAppreciation.length < _allAppreciations.length) {
      _loadMoreVendors();
    }
  }

  // Load more vendors into the display list
  void _loadMoreVendors() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        final nextCount = _displayCount + 15;
        _displayedAppreciation = _allAppreciations.take(nextCount).toList();
        _displayCount = nextCount;
        _isLoading = false;
      });
    });
  }
}
