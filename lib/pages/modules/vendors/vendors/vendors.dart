import 'package:flutter/material.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/models/vendorsModel.dart';
import 'package:pickme_mobile/pages/modules/vendors/vendors/widget/vendorAds.dart';
import 'package:pickme_mobile/pages/modules/vendors/vendors/widget/vendorsWidget.dart';
import 'package:pickme_mobile/providers/vendorsProvider.dart';
import 'package:pickme_mobile/spec/colors.dart';

import 'widget/vendorDetailsDialog.dart';

class Vendors extends StatefulWidget {
  final bool showAd;

  const Vendors({super.key, this.showAd = false});

  @override
  State<Vendors> createState() => _VendorsState();
}

class _VendorsState extends State<Vendors> {
  final Repository _repo = new Repository();
  final ScrollController _scrollController = ScrollController();

  FocusNode? _searchFocusNode;
  String _searchText = "";

  List<Data> _allVendors = [];
  List<Data> _displayedVendors = [];
  int _displayCount = 15; // Number of items to display initially
  bool _isLoading = false, _isContainItems = true;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = new FocusNode();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAllVendors();
    });
  }

  @override
  void dispose() {
    _searchFocusNode!.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.showAd
        ? _displayedVendors.isNotEmpty
            ? vendorAds(
                context: context,
                vendors: _displayedVendors,
                onVendor: (Data data) => _onVendor(data),
              )
            : SizedBox()
        : Scaffold(
            body: vendorsWidget(
              context: context,
              searchFocusNode: _searchFocusNode,
              onSearchChange: (String text) => _onSearchChange(text),
              onVentorFilter: () {},
              searchText: _searchText,
              vendors: _displayedVendors,
              scrollController: _scrollController,
              isLoading: _isLoading,
              isContainItems: _isContainItems,
              onVendor: (Data data) => _onVendor(data),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => navigation(context: context, pageName: "addvendor"),
              child: const Icon(Icons.add, color: BColors.white),
            ),
          );
  }

  void _onVendor(Data data) {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: BColors.white,
      builder: (context) => vendorDetailsDialog(
        data: data,
        context: context,
      ),
    );
  }

  // Fetch all vendors at once
  void _fetchAllVendors() async {
    setState(() {
      _isLoading = true;
    });
    await _repo.fetchVendors(false);
    List<Data>? vendorsData = vendorsModel?.data;

    if (vendorsData != null && vendorsData.isNotEmpty) {
      setState(() {
        _allVendors = vendorsData ?? [];
        _displayedVendors = _allVendors.take(_displayCount).toList(); // Display initial 15 items
        _isLoading = false;
        _isContainItems = _displayedVendors.isNotEmpty;
      });
    }

    await _repo.fetchVendors(true);
    vendorsData = vendorsModel?.data;

    if (vendorsData != null && vendorsData.isNotEmpty) {
      setState(() {
        _allVendors = vendorsData ?? [];
        _displayedVendors = _allVendors.take(_displayCount).toList(); // Display initial 15 items
        _isLoading = false;
        _isContainItems = _displayedVendors.isNotEmpty;
      });
    } else {
      _isContainItems = false;
      setState(() {});
    }
  }

  // Handle scroll to load more items
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent &&
        !_isLoading &&
        _displayedVendors.length < _allVendors.length) {
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
        _displayedVendors = _allVendors.take(nextCount).toList();
        _displayCount = nextCount;
        _isLoading = false;
      });
    });
  }

  // Search function to filter vendors based on search text
  void _onSearchChange(String text) {
    setState(() {
      _searchText = text;
      if (_searchText.isEmpty) {
        // If search text is empty, revert to lazy loading
        _displayedVendors = _allVendors.take(_displayCount).toList();
      } else {
        // Filter all vendors based on the search text
        _displayedVendors = _allVendors
            .where((data) =>
                data.vendorName!.toLowerCase().contains(_searchText.toLowerCase()) ||
                data.serviceName!.toLowerCase().contains(_searchText.toLowerCase()) ||
                data.streetname!.toLowerCase().contains(_searchText.toLowerCase()) ||
                data.district!.toLowerCase().contains(_searchText.toLowerCase()))
            .toList();
      }
    });
  }
}
