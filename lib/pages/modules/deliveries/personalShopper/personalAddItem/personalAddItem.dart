import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/pages/modules/deliveries/personalShopper/deliveryAddress/deliveryAddress.dart';
import 'package:pickme_mobile/spec/colors.dart';

import 'widget/personalAddItemDialog.dart';
import 'widget/personalAddItemWidget.dart';

class PersonalAdditem extends StatefulWidget {
  const PersonalAdditem({super.key});

  @override
  State<PersonalAdditem> createState() => _PersonalAdditemState();
}

class _PersonalAdditemState extends State<PersonalAdditem> {
  final _scrollController = ScrollController();

  final _storeController = new TextEditingController();
  final _storeFocusNode = new FocusNode();

  final List<Map<String, dynamic>> _itemsMapList = [];

  bool _errorInBuildup = false;
  double _totalPrice = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: personalAddItemWidget(
        context: context,
        onStartAddingItem: () => _onStartAddingItem(),
        onAddNewItem: () => _onStartAddingItem(),
        storeController: _storeController,
        storeFocusNode: _storeFocusNode,
        onQtyAddSubtract: (String action, int index) => _onQtyAddSubtract(
          action,
          index,
        ),
        onDeleteItem: (int index) => _onDeleteItem(index),
        itemsMapList: _itemsMapList,
        onItemPriceChange: (String text, int index) => _onItemPriceChange(text, index),
        totalPrice: _totalPrice,
        scrollController: _scrollController,
      ),
      bottomNavigationBar: _itemsMapList.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(10),
              child: button(
                onPressed: () => _onSelectDelivery(true),
                text: "Select delivery address",
                color: BColors.primaryColor,
                context: context,
                buttonRadius: 20,
              ),
            ),
    );
  }

  void _onSelectDeliveryDialog() {
    showDialog(
      context: context,
      builder: (context) => personalAddItemDialog(
        context: context,
        onDialogAction: (String action) {
          if (action == "no") {
            _onSelectDelivery(false);
          } else {
            navigation(context: context, pageName: "back");
            _storeFocusNode.requestFocus();
          }
        },
      ),
    );
  }

  void _onSelectDelivery(bool checkStoreSuggest) {
    _storeFocusNode.unfocus();
    if (_itemsMapList.isNotEmpty) {
      if ((_itemsMapList[_itemsMapList.length - 1]["name"] as TextEditingController).text.isEmpty) {
        toastContainer(
          text: "Enter item ${_itemsMapList.length} name",
          backgroundColor: BColors.red,
        );
        return;
      }

      if ((_itemsMapList[_itemsMapList.length - 1]["price"] as TextEditingController).text.isEmpty) {
        toastContainer(
          text: "Enter item ${_itemsMapList.length} price",
          backgroundColor: BColors.red,
        );
        return;
      }

      if (_storeController.text.isEmpty && checkStoreSuggest) {
        _onSelectDeliveryDialog();
        return;
      }
    }

    List<Map<String, dynamic>> decodeItemItem = [];
    for (var data in _itemsMapList) {
      Map<String, dynamic> item = {
        "name": (data["name"] as TextEditingController).text,
        "qty": data["qty"],
        "price": (data["price"] as TextEditingController).text,
      };
      decodeItemItem.add(item);
    }

    Map<String, dynamic> meta = {
      "items": decodeItemItem,
      "storeSuggested": _storeController.text,
      "total": _totalPrice,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryAddress(itemsMap: meta),
      ),
    );
  }

  void _onItemPriceChange(String text, int index) {
    if (text.isEmpty) return;

    double incomingPrice = 0;
    try {
      incomingPrice = double.parse(text);
      _errorInBuildup = false;
    } catch (e) {
      debugPrint("invalid => ${e.toString()}");
      _errorInBuildup = true;
      toastContainer(
        text: "Invalid price entered",
        backgroundColor: BColors.red,
      );
    }

    if (_itemsMapList[index]["qty"] != 1) {
      toastContainer(
        text: "Qty reset",
        backgroundColor: BColors.red,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
    _itemsMapList[index]["qty"] = 1;
    _itemsMapList[index]["total"] = incomingPrice;
    _calculateGrandTotal();
    setState(() {});
  }

  void _calculateGrandTotal() {
    double totalPreviousPrice = 0;
    // getting all prices in itemList
    for (int x = 0; x < _itemsMapList.length; ++x) {
      double total = _itemsMapList[x]["qty"] *
          double.parse(
            (_itemsMapList[x]["price"] as TextEditingController).text,
          );
      _itemsMapList[x]["total"] = total;
      totalPreviousPrice = total + totalPreviousPrice;
    }
    _totalPrice = totalPreviousPrice;
    setState(() {});
  }

  void _onQtyAddSubtract(String action, int index) {
    if ((_itemsMapList[index]["price"] as TextEditingController).text.isEmpty) {
      toastContainer(text: "Enter price first", backgroundColor: BColors.red);
      return;
    }

    (_itemsMapList[index]["priceFocus"] as FocusNode).unfocus();
    (_itemsMapList[index]["nameFocus"] as FocusNode).unfocus();

    int qty = _itemsMapList[index]["qty"];
    if (action == "add") {
      ++qty;
    } else {
      if (qty > 1) --qty;
    }
    _itemsMapList[index]["qty"] = qty;
    _calculateGrandTotal();

    setState(() {});
  }

  void _onDeleteItem(int index) {
    _itemsMapList.removeAt(index);

    double totalPreviousPrice = 0;
    for (int x = 0; x < _itemsMapList.length; ++x) {
      totalPreviousPrice = totalPreviousPrice +
          double.parse(
            (_itemsMapList[x]["price"] as TextEditingController).text,
          );
    }
    _totalPrice = totalPreviousPrice;

    setState(() {});
    _errorInBuildup = false;
  }

  void _onStartAddingItem() {
    if (_errorInBuildup) {
      toastContainer(
        text: "Invalid price entered",
        backgroundColor: BColors.red,
      );
      return;
    }

    if (_itemsMapList.isNotEmpty) {
      if ((_itemsMapList[_itemsMapList.length - 1]["name"] as TextEditingController).text.isEmpty) {
        toastContainer(
          text: "Enter item name",
          backgroundColor: BColors.red,
        );
        return;
      }

      if ((_itemsMapList[_itemsMapList.length - 1]["price"] as TextEditingController).text.isEmpty) {
        toastContainer(
          text: "Enter price",
          backgroundColor: BColors.red,
        );
        return;
      }
    }

    Map<String, dynamic> itemMap = {
      "name": new TextEditingController(),
      "nameFocus": FocusNode(),
      "qty": 1,
      "price": new TextEditingController(),
      "priceFocus": FocusNode(),
      "total": 0,
    };

    _itemsMapList.add(itemMap);
    setState(() {});
    (_itemsMapList[_itemsMapList.length - 1]["nameFocus"] as FocusNode).requestFocus();
    _errorInBuildup = false;
  }
}
