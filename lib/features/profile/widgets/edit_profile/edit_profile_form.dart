import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/input_style.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/utils/validators.dart';

class EditProfileForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final String email;
  final bool isLoading;
  final VoidCallback onSave;

  const EditProfileForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.email,
    required this.isLoading,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: nameController,
            decoration: AppInputStyle.underlineInputDecoration(
              labelText: 'Imię',
              hintText: 'Podaj swoje imię',
            ),
            textCapitalization: TextCapitalization.words,
            validator: Validators.validateName,
            enabled: !isLoading,
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: email,
            decoration: AppInputStyle.underlineInputDecoration(
              labelText: 'Email',
            ),
            enabled: false,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          Text(
            'Email nie może być zmieniony',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Zapisz zmiany',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
