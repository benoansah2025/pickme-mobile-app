import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget personalAddItemWidget({
  required BuildContext context,
  required void Function(String action, int index) onQtyAddSubtract,
  required void Function() onStartAddingItem,
  required void Function() onAddNewItem,
  required void Function(int index) onDeleteItem,
  required TextEditingController storeController,
  required FocusNode storeFocusNode,
  required List<Map<String, dynamic>> itemsMapList,
  required void Function(String text, int index) onItemPriceChange,
  required double totalPrice,
  required ScrollController scrollController,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: SingleChildScrollView(
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            "Make a list of items you need with their prices ",
            style: Styles.h3BlackBold,
          ),
          const SizedBox(height: 20),
          if (itemsMapList.isEmpty) ...[
            GestureDetector(
              onTap: onStartAddingItem,
              child: Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: BColors.primaryColor1.withOpacity(.2),
                  border: Border.all(color: BColors.primaryColor1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Add Item name, quantity and price ➤",
                  style: Styles.h5Primary1,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (itemsMapList.isNotEmpty) ...[
            for (int x = 0; x < itemsMapList.length; ++x) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: BColors.assDeep),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -3),
                      title: SizedBox(
                        width: MediaQuery.of(context).size.width * 65,
                        height: 40,
                        child: textFormField(
                          hintText: "Enter item name here",
                          controller: itemsMapList[x]["name"],
                          focusNode: itemsMapList[x]["nameFocus"],
                          borderColor: (itemsMapList[x]["nameFocus"] as FocusNode).hasFocus
                              ? BColors.primaryColor1
                              : BColors.assDeep,
                          inputType: TextInputType.text,
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () => onDeleteItem(x),
                        icon: const Icon(
                          FeatherIcons.trash2,
                          color: BColors.black,
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      horizontalTitleGap: 5,
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -3),
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("QTY", style: Styles.h5BlackBold),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () => onQtyAddSubtract("subtract", x),
                            icon: const Icon(Icons.remove_circle_outline),
                            color: BColors.primaryColor1,
                            iconSize: 30,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "${itemsMapList[x]["qty"]}",
                            style: Styles.h5Primary1,
                          ),
                          const SizedBox(width: 5),
                          IconButton(
                            onPressed: () => onQtyAddSubtract("add", x),
                            icon: const Icon(Icons.add_circle),
                            color: BColors.primaryColor1,
                            iconSize: 30,
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                            textAlign: TextAlign.right,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: Properties.curreny,
                                  style: Styles.h5BlackBold,
                                ),
                                TextSpan(
                                  text: "\nper qty",
                                  style: Styles.h7Black,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 70,
                            child: textFormField(
                              hintText: "",
                              controller: itemsMapList[x]["price"],
                              focusNode: itemsMapList[x]["priceFocus"],
                              inputType: const TextInputType.numberWithOptions(
                                signed: true,
                                decimal: true,
                              ),
                              borderColor: (itemsMapList[x]["priceFocus"] as FocusNode).hasFocus
                                  ? BColors.primaryColor1
                                  : BColors.assDeep,
                              onTextChange: (String text) => onItemPriceChange(text, x),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Text(
                        "Total: ${Properties.curreny} ${itemsMapList[x]["total"]}",
                        style: Styles.h5BlackBold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: button(
                onPressed: onAddNewItem,
                text: "Add New Item",
                color: BColors.black,
                context: context,
                useWidth: false,
                colorFill: false,
                textColor: BColors.black,
                postFixIcon: const Icon(
                  Icons.play_arrow_rounded,
                  color: BColors.black,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: Text("Grand Total", style: Styles.h4BlackBold),
              trailing: Text(
                "${Properties.curreny} $totalPrice",
                style: Styles.h3BlackBold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 50),
            Text(
              "Suggest where you want your items to be bought",
              style: Styles.h6BlackBold,
            ),
            const SizedBox(height: 10),
            textFormField(
              hintText: "Store/Place",
              controller: storeController,
              focusNode: storeFocusNode,
              maxLine: null,
              minLine: 4,
              inputType: TextInputType.text,
              backgroundColor: BColors.assDeep1.withOpacity(.7),
              borderColor: BColors.assDeep1.withOpacity(.7),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    ),
  );
}
