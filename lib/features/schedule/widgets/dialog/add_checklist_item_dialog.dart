import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/schedule/model/day_plan_item_model.dart';
import 'package:trip_planner/features/schedule/widgets/dialog/dialog_components/dialog_header.dart';
import 'package:trip_planner/features/schedule/widgets/dialog/dialog_components/dialog_category_section.dart';
import 'package:trip_planner/features/schedule/widgets/dialog/dialog_components/dialog_title_description_section.dart';
import 'package:trip_planner/features/schedule/widgets/dialog/dialog_components/dialog_actions_bar.dart';
import 'package:uuid/uuid.dart';

class AddChecklistItemDialog extends StatefulWidget {
  final DateTime date;
  final DayPlanItem? editItem;

  const AddChecklistItemDialog({
    super.key,
    required this.date,
    this.editItem,
  });

  @override
  State<AddChecklistItemDialog> createState() => _AddChecklistItemDialogState();
}

class _AddChecklistItemDialogState extends State<AddChecklistItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedIcon;

  @override
  void initState() {
    super.initState();
    if (widget.editItem != null) {
      _titleController.text = widget.editItem!.title;
      _descriptionController.text = widget.editItem!.description ?? '';
      _selectedIcon = widget.editItem!.icon;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final item = DayPlanItem(
      id: widget.editItem?.id ?? const Uuid().v4(),
      type: DayPlanItemType.checklist,
      startTime: widget.date,
      endTime: null,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      icon: _selectedIcon,
      order: widget.editItem?.order ?? 0,
      isCompleted: widget.editItem?.isCompleted ?? false,
    );

    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    const radius = 24.0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DialogHeader(
                isEditing: widget.editItem != null,
                onClose: () => Navigator.pop(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dodaj aktywność bez konkretnej godziny',
                          style: AppTextStyles.bodyTextSecondary,
                        ),
                        const SizedBox(height: 24),
                        DialogTitleDescriptionSection(
                          titleController: _titleController,
                          descriptionController: _descriptionController,
                          titleLabel: 'Nazwa aktywności',
                          descriptionLabel: 'Opis (opcjonalnie)',
                          titleValidator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Podaj nazwę';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DialogCategorySection(
                          selectedIcon: _selectedIcon,
                          onIconSelected: (iconId) {
                            setState(() {
                              _selectedIcon = iconId;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              DialogActionsBar(
                isEditing: widget.editItem != null,
                onCancel: () => Navigator.pop(context),
                onConfirm: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
