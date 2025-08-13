import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget myServicesWidget({
  required BuildContext context,
  required List<Map<String, dynamic>> servicesList,
  required void Function(int index) onService,
}) {
  return SingleChildScrollView(
    child: Column(
      children: [
        ListTile(title: Text("My main service ", style: Styles.h5Black)),
        for (var data in servicesList.take(1))
          _layout(
            title: data["name"],
            isCheck: data["allow"],
            onChange: (bool value) => onService(0),
          ),
        const SizedBox(height: 20),
        if (servicesList.length > 1) ...[
          ListTile(
            title: Text("Other services ", style: Styles.h5Black),
          ),
          for (int x = 1; x < servicesList.length; ++x)
            _layout(
              title: servicesList[x]["name"],
              isCheck: servicesList[x]["allow"],
              onChange: (bool value) => onService(x),
            ),
          const SizedBox(height: 20),
        ],
      ],
    ),
  );
}

Widget _layout({
  required String title,
  required bool isCheck,
  required void Function(bool value) onChange,
}) {
  return SwitchListTile(
    title: Text(title, style: Styles.h4BlackBold),
    value: isCheck,
    onChanged: (bool value) => onChange(value),
    activeColor: BColors.primaryColor1,
  );
}
