import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';

class FormInput extends StatelessWidget {
  const FormInput({
    super.key,
    required this.labelText,
    required this.icon,
    this.onTap,
    this.controller,
    this.maxCharacters,
  });

  final String labelText;
  final IconData icon;
  final Function()? onTap;
  final TextEditingController? controller;
  final int? maxCharacters;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLength: maxCharacters,
      decoration: InputDecoration(
        prefixIcon: Container(
          margin: const EdgeInsets.only(left: 12, right: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, color: Colors.white),
          ),
        ),
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1,
          ),
        ),
      ),
      readOnly: onTap != null,
      onTap: onTap,
    );
  }
}
