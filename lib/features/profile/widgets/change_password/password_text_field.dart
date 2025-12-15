import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/input_style.dart';
import 'package:trip_planner/core/theme/colors.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;

  final String labelText;

  final String hintText;

  final String? Function(String?)? validator;

  final bool enabled;

  const PasswordTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.validator,
    this.enabled = true,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: AppInputStyle.underlineInputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
      ).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppColors.grey,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
      ),
      obscureText: _obscurePassword,
      validator: widget.validator,
      enabled: widget.enabled,
    );
  }
}
