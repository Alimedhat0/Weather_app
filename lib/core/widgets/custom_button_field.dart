import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/style/colors.dart';

class CustomButtonField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final bool obscureText;
  final String hintText;
  final Function(String)? onChange;
  final bool readOnly;
  final VoidCallback? onTap;
  final int? maxLines;
  const CustomButtonField({
    super.key,
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.obscureText = false,
    required this.hintText,
    this.onChange,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.text30Color),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.text50Color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      validator: validator,
      obscureText: obscureText,
      onChanged: onChange,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
    );
  }
}
