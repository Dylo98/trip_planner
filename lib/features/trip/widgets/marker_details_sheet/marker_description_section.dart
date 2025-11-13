import 'package:flutter/material.dart';
import 'package:trip_planner/core/utils/debouncer.dart';

class MarkerDescriptionSection extends StatefulWidget {
  const MarkerDescriptionSection({
    super.key,
    required this.initialDescription,
    required this.onDescriptionChanged,
  });

  final String? initialDescription;
  final Function(String) onDescriptionChanged;

  @override
  State<MarkerDescriptionSection> createState() =>
      _MarkerDescriptionSectionState();
}

class _MarkerDescriptionSectionState extends State<MarkerDescriptionSection> {
  late final TextEditingController _controller;
  final _debouncer = Debouncer(milliseconds: 600);
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialDescription ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Opis miejsca',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(_isEditing ? Icons.check : Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
                if (!_isEditing) {
                  FocusScope.of(context).unfocus();
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (!_isEditing && _controller.text.isEmpty)
          GestureDetector(
            onTap: () => setState(() => _isEditing = true),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.add, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Dodaj opis tego miejsca',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (!_isEditing)
          GestureDetector(
            onTap: () => setState(() => _isEditing = true),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _controller.text,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kliknij aby edytować',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          TextFormField(
            controller: _controller,
            maxLines: 5,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Opisz to miejsce...\n\n'
                  'Możesz dodać:\n'
                  '• Co tam widziałeś\n'
                  '• Wrażenia\n'
                  '• Ciekawostki\n'
                  '• Rekomendacje',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              _debouncer.run(() {
                widget.onDescriptionChanged(value);
              });
            },
          ),
      ],
    );
  }
}
