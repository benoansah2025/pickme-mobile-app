import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/colors.dart';

class PasswordField extends StatefulWidget {
  final Key? fieldKey;
  final String? hintText, labelText, validateMsg;
  final FormFieldSetter<String>? onSaved;
  final bool validate, removeBorder;
  final IconData? prefixIcon;
  final ValueChanged<String>? onFieldSubmitted;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType inputType;

  const PasswordField({
    super.key,
    this.fieldKey,
    @required this.hintText,
    this.onSaved,
    this.validate = true,
    this.removeBorder = false,
    this.onFieldSubmitted,
    this.labelText,
    @required this.controller,
    @required this.validateMsg,
    @required this.focusNode,
    this.prefixIcon,
    this.inputType = TextInputType.text,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.fieldKey,
      obscureText: _obscureText,
      onSaved: widget.onSaved,
      focusNode: widget.focusNode,
      keyboardType: widget.inputType,
      validator: (value) {
        if (value!.isEmpty && widget.validate) {
          return widget.validateMsg;
        }
        return null;
      },
      onFieldSubmitted: widget.onFieldSubmitted,
      style: const TextStyle(color: BColors.black, fontWeight: FontWeight.w600),
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: BColors.assDeep, fontSize: 13),
        labelText: widget.labelText,
        filled: true,
        fillColor: BColors.white,
        labelStyle: const TextStyle(color: BColors.assDeep),
        prefixIcon: widget.prefixIcon == null ? null : Icon(widget.prefixIcon, color: BColors.black),
        enabledBorder: widget.removeBorder
            ? InputBorder.none
            : OutlineInputBorder(
                borderSide: const BorderSide(color: BColors.assDeep, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
        focusedBorder: widget.removeBorder
            ? InputBorder.none
            : OutlineInputBorder(
                borderSide: const BorderSide(color: BColors.assDeep, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
        border: widget.removeBorder
            ? InputBorder.none
            : OutlineInputBorder(
                borderSide: const BorderSide(color: BColors.assDeep, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: BColors.black,
          ),
        ),
      ),
    );
  }
}
