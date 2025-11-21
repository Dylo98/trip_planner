import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/input_style.dart';
import 'package:trip_planner/core/utils/validators.dart';
import 'package:trip_planner/features/trip/providers/trip_form_provider.dart';
import 'package:trip_planner/features/trip/providers/trip_photo_provider.dart';
import 'package:trip_planner/core/utils/debouncer.dart';
import 'package:trip_planner/core/utils/action_lock.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';

class TripForm extends ConsumerStatefulWidget {
  const TripForm({super.key, required this.formKey});

  final GlobalKey<FormState> formKey;

  @override
  ConsumerState<TripForm> createState() => _TripFormState();
}

class _TripFormState extends ConsumerState<TripForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final _saveDebouncer = Debouncer(milliseconds: 350);
  final _uiLock = ActionLock();
  TripType _selectedTripType = TripType.planned;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    await _uiLock.run(() async {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;
      final image = File(pickedFile.path);
      if (!mounted) return;
      setState(() => _selectedImage = image);
      ref.read(tripPhotoProvider.notifier).state = image;
    });
  }

  void _debounced(void Function() fn) {
    _saveDebouncer.run(fn);
  }

  @override
  void dispose() {
    _saveDebouncer.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            maxLength: 40,
            decoration: AppInputStyle.inputDecoration(
                icon: Icons.title, labelText: 'Nazwa podróży'),
            validator: Validators.validateTripName,
            onChanged: (value) => _debounced(() {
              ref.read(tripFormProvider.notifier).setName(value);
            }),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _descriptionController,
            maxLength: 100,
            decoration: AppInputStyle.inputDecoration(
                icon: Icons.description, labelText: 'Opis podróży'),
            onChanged: (value) => _debounced(() {
              ref.read(tripFormProvider.notifier).setDescription(value);
            }),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Typ podróży',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<TripType>(
                        title: const Text('Zaplanowana'),
                        subtitle: const Text('Z datą końcową'),
                        value: TripType.planned,
                        groupValue: _selectedTripType,
                        onChanged: (value) {
                          setState(() {
                            _selectedTripType = value!;
                            ref
                                .read(tripFormProvider.notifier)
                                .setTripType(value);
                            if (value == TripType.ongoing) {
                              _endDateController.clear();
                              ref
                                  .read(tripFormProvider.notifier)
                                  .setEndDate(null);
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<TripType>(
                        title: const Text('Trwająca'),
                        subtitle: const Text('Na bieżąco'),
                        value: TripType.ongoing,
                        groupValue: _selectedTripType,
                        onChanged: (value) {
                          setState(() {
                            _selectedTripType = value!;
                            if (value == TripType.ongoing) {
                              _endDateController.clear();
                              ref
                                  .read(tripFormProvider.notifier)
                                  .setEndDate(null);
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Data podróży',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 65,
                  ),
                  child: _selectedTripType == TripType.planned
                      ? Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _startDateController,
                                decoration: AppInputStyle.inputDecoration(
                                  icon: Icons.calendar_today,
                                  labelText: 'Data rozpoczęcia',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Wymagane';
                                  }
                                  return null;
                                },
                                onTap: () async {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  await _uiLock.run(() async {
                                    final pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (pickedDate != null) {
                                      setState(() {
                                        _startDateController.text =
                                            DateFormat('yyyy.MM.dd')
                                                .format(pickedDate);
                                      });
                                      ref
                                          .read(tripFormProvider.notifier)
                                          .setStartDate(pickedDate);
                                    }
                                  });
                                },
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(Icons.arrow_right_alt_outlined),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _endDateController,
                                decoration: AppInputStyle.inputDecoration(
                                  icon: Icons.calendar_today,
                                  labelText: 'Data zakończenia',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Wymagane';
                                  }
                                  return null;
                                },
                                onTap: () async {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  await _uiLock.run(() async {
                                    final pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );

                                    if (pickedDate != null) {
                                      setState(() {
                                        _endDateController.text =
                                            DateFormat('yyyy.MM.dd')
                                                .format(pickedDate);
                                      });
                                      ref
                                          .read(tripFormProvider.notifier)
                                          .setEndDate(pickedDate);
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        )
                      : TextFormField(
                          controller: _startDateController,
                          decoration: AppInputStyle.inputDecoration(
                            icon: Icons.calendar_today,
                            labelText: 'Data rozpoczęcia',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Data rozpoczęcia jest wymagana';
                            }
                            return null;
                          },
                          onTap: () async {
                            FocusScope.of(context).requestFocus(FocusNode());
                            await _uiLock.run(() async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _startDateController.text =
                                      DateFormat('yyyy.MM.dd')
                                          .format(pickedDate);
                                });
                                ref
                                    .read(tripFormProvider.notifier)
                                    .setStartDate(pickedDate);
                              }
                            });
                          },
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[300],
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                      : Center(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.primaryGradient,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child:
                                  Icon(Icons.add_a_photo, color: Colors.white),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
