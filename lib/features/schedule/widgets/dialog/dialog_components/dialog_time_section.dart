import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/schedule/widgets/dialog/dialog_components/dialog_time_picker.dart';

class DialogTimeSection extends StatelessWidget {
  final TimeOfDay startTime;
  final TimeOfDay? endTime;
  final Function(TimeOfDay) onStartTimeChanged;
  final Function(TimeOfDay?) onEndTimeChanged;
  final VoidCallback onClearEndTime;

  const DialogTimeSection({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
    required this.onClearEndTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Godziny aktywności',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.grey, thickness: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DialogTimePicker(
                  label: 'Początek',
                  time: startTime,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: startTime,
                    );
                    if (time != null) onStartTimeChanged(time);
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_right_alt_outlined),
              ),
              Expanded(
                child: DialogTimePicker(
                  label: 'Koniec',
                  time: endTime,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: endTime ?? startTime,
                    );
                    if (time != null) onEndTimeChanged(time);
                  },
                  canClear: true,
                  onClear: onClearEndTime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
