import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';

Widget textFormField({
  Function()? function,
  @required String? hintText,
  String? labelText,
  String? validateMsg,
  IconData? icon,
  IconData? prefixIcon,
  Color iconColor = BColors.black,
  Color prefixIconColor = BColors.black,
  Color? cursorColor,
  Color textColor = BColors.black,
  Color labelColor = BColors.assDeep,
  Color backgroundColor = BColors.white,
  @required TextEditingController? controller,
  bool validate = true,
  bool suggestion = true,
  TextInputType inputType = TextInputType.text,
  int? maxLine = 1,
  int minLine = 1,
  bool validateEmail = false,
  double? width,
  enable = true,
  bool removeBorder = false,
  void Function()? onIconTap,
  TextInputAction? inputAction,
  void Function()? onEditingComplete,
  void Function(String text)? onTextChange,
  @required FocusNode? focusNode,
  bool readOnly = false,
  bool showBorderRound = true,
  Color borderColor = BColors.assDeep,
  TextCapitalization textCapitalization = TextCapitalization.sentences,
  int? maxLength,
  double borderWidth = 1,
  double borderRadius = 10,
  bool isDense = false,
  double? iconSize,
  TextStyle hintTextStyle = const TextStyle(
    color: BColors.assDeep,
    fontSize: 13,
  ),
  EdgeInsets padding = EdgeInsets.zero,
  EdgeInsets? inputPadding,
  EdgeInsets? iconPadding,
  Color? containerColor,
  TextStyle? textStyle,
  TextAlign textAlign = TextAlign.start,
}) {
  return Container(
    width: width,
    padding: padding,
    color: containerColor,
    child: TextFormField(
      onTap: function,
      readOnly: readOnly,
      enableInteractiveSelection: true,
      enabled: enable,
      enableSuggestions: suggestion,
      keyboardType: minLine > 1 ? TextInputType.multiline : inputType,
      controller: controller,
      minLines: minLine,
      maxLines: maxLine,
      maxLength: maxLength,
      focusNode: focusNode,
      autofocus: false,
      textInputAction: inputAction,
      cursorColor: cursorColor,
      textCapitalization: validateEmail ? TextCapitalization.none : textCapitalization,
      textAlign: textAlign,
      style: textStyle ?? TextStyle(color: textColor, fontWeight: FontWeight.w600),
      onEditingComplete: onEditingComplete,
      onChanged: onTextChange == null ? null : (text) => onTextChange(text),
      decoration: InputDecoration(
        contentPadding: inputPadding,
        isDense: isDense,
        hintText: hintText,
        hintStyle: hintTextStyle,
        labelText: labelText,
        labelStyle: TextStyle(color: labelColor),
        filled: true,
        fillColor: backgroundColor,
        suffixIcon: icon == null
            ? null
            : IconButton(
                padding: iconPadding,
                onPressed: onIconTap,
                icon: Icon(icon, color: iconColor, size: iconSize),
              ),
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, color: prefixIconColor),
        enabledBorder: removeBorder
            ? InputBorder.none
            : showBorderRound
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: borderColor,
                      width: borderWidth,
                    ),
                  )
                : UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: borderColor,
                      width: borderWidth,
                    ),
                  ),
        disabledBorder: removeBorder
            ? InputBorder.none
            : showBorderRound
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: borderColor,
                      width: borderWidth,
                    ),
                  )
                : UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: borderColor,
                      width: borderWidth,
                    ),
                  ),
        focusedBorder: removeBorder
            ? InputBorder.none
            : showBorderRound
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: borderColor,
                      width: borderWidth,
                    ),
                  )
                : UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: borderColor,
                      width: borderWidth,
                    ),
                  ),
        border: removeBorder
            ? InputBorder.none
            : showBorderRound
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: borderColor,
                      width: borderWidth,
                    ),
                  )
                : UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: borderColor,
                      width: borderWidth,
                    ),
                  ),
        errorStyle: const TextStyle(
          color: Colors.red,
        ),
      ),
      validator: (value) {
        RegExp regex = RegExp(Properties.emailValidatingPattern);
        if (value!.isEmpty && validate) {
          return validateMsg;
        } else if (validateEmail && !regex.hasMatch(value.trim())) {
          return "Please enter a valid email address";
        }
        return null;
      },
    ),
  );
}
