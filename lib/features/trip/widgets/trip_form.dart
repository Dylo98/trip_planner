import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/features/trip/controller/trip_form_notifier.dart';
import 'package:trip_planner/features/trip/controller/trip_photo_provider.dart';
import 'package:trip_planner/features/trip/widgets/form_input.dart';

class TripForm extends ConsumerStatefulWidget {
  const TripForm({super.key});

  @override
  ConsumerState<TripForm> createState() => _TripFormState();
}

class _TripFormState extends ConsumerState<TripForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final image = File(pickedFile.path);
      setState(() {
        _selectedImage = image;
      });
      ref.read(tripPhotoProvider.notifier).state = image;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          FormInput(
            controller: _nameController,
            labelText: 'Nazwa podróży',
            icon: Icons.title,
            maxCharacters: 40,
            onChanged: (value) {
              ref.read(tripFormProvider.notifier).setName(value);
            },
          ),
          const SizedBox(height: 20),
          FormInput(
            controller: _descriptionController,
            labelText: 'Opis podróży',
            icon: Icons.description,
            maxCharacters: 100,
            onChanged: (value) {
              ref.read(tripFormProvider.notifier).setDescription(value);
            },
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const SizedBox(height: 5),
                Text(
                  'Data podróży',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                Row(
                  children: [
                    Expanded(
                      child: FormInput(
                        controller: _startDateController,
                        labelText: 'Data rozpoczęcia',
                        icon: Icons.calendar_today,
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _startDateController.text =
                                  DateFormat('yyyy.MM.dd').format(pickedDate);
                            });
                            ref
                                .read(tripFormProvider.notifier)
                                .setStartDate(pickedDate);
                          }
                        },
                      ),
                    ),
                    Icon(Icons.arrow_right_alt_outlined),
                    Expanded(
                      child: FormInput(
                        controller: _endDateController,
                        labelText: 'Data zakończenia',
                        icon: Icons.calendar_today,
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _endDateController.text =
                                  DateFormat('yyyy.MM.dd').format(pickedDate);
                            });
                            ref
                                .read(tripFormProvider.notifier)
                                .setEndDate(pickedDate);
                          }
                        },
                      ),
                    ),
                  ],
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
