import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget emergencyWidget({
  required BuildContext context,
  required void Function() onAddContact,
  required void Function(String? number) onCall,
  required void Function(int index) onRemoveContact,
  required List<Map> contactList,
}) {
  return Stack(
    children: [
      Container(
        height: MediaQuery.of(context).size.height * .4,
        width: double.maxFinite,
        color: BColors.primaryColor,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () => onCall(null),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(.1),
                  spreadRadius: 10,
                  blurRadius: 8,
                  offset: const Offset(0, 4), // Shadow position
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: BColors.red,
              radius: 80,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.call, color: BColors.white, size: 40),
                  const SizedBox(height: 10),
                  Text("Emergency", style: Styles.h6WhiteBold),
                ],
              ),
            ),
          ),
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * .54,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: button(
                  onPressed: onAddContact,
                  text: "+ Add Contact",
                  color: BColors.obGrade4,
                  context: context,
                  useWidth: false,
                  buttonRadius: 20,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 80),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () => onCall(null),
                       leading: CircleAvatar(
                            backgroundColor: BColors.assDeep1,
                            child: Text("1", style: Styles.h5BlackBold),
                          ),
                        title: Text(Properties.titleShort, style: Styles.h4BlackBold),
                        subtitle: Text(Properties.contactDetails["phone"]!, style: Styles.h5Black),
                        trailing: const Icon(Icons.phone, color: BColors.green),
                      ),
                      const Divider(),
                      for (int x = 0; x < contactList.length; ++x) ...[
                        ListTile(
                          onTap: () => onCall(contactList[x]["phone"]),
                          leading: CircleAvatar(
                            backgroundColor: BColors.assDeep1,
                            child: Text("${x + 2}", style: Styles.h5BlackBold),
                          ),
                          title: Text(contactList[x]["name"], style: Styles.h4BlackBold),
                          subtitle: Text(contactList[x]["phone"], style: Styles.h5Black),
                          trailing: IconButton(
                            onPressed: () => onRemoveContact(x),
                            icon: const Icon(Icons.remove_circle_outline_outlined),
                            color: BColors.red,
                          ),
                        ),
                        const Divider(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
