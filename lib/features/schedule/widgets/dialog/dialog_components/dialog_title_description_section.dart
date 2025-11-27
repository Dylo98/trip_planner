import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/input_style.dart';

class DialogTitleDescriptionSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  final String titleLabel;
  final String descriptionLabel;

  final IconData titleIcon;
  final IconData descriptionIcon;

  final int titleMaxLength;
  final int descriptionMaxLength;

  final String? Function(String?)? titleValidator;
  final ValueChanged<String>? onTitleChanged;

  const DialogTitleDescriptionSection({
    super.key,
    required this.titleController,
    required this.descriptionController,
    this.titleLabel = 'Nazwa aktywności',
    this.descriptionLabel = 'Opis (opcjonalnie)',
    this.titleIcon = Icons.title,
    this.descriptionIcon = Icons.description,
    this.titleMaxLength = 100,
    this.descriptionMaxLength = 200,
    this.titleValidator,
    this.onTitleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: titleController,
          decoration: AppInputStyle.inputDecoration(
            icon: titleIcon,
            labelText: titleLabel,
          ),
          validator: titleValidator,
          maxLength: titleMaxLength,
          textCapitalization: TextCapitalization.words,
          onChanged: onTitleChanged,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          decoration: AppInputStyle.inputDecoration(
            icon: descriptionIcon,
            labelText: descriptionLabel,
          ),
          maxLines: 1,
          maxLength: descriptionMaxLength,
        ),
      ],
    );
  }
}
