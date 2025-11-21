import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:uuid/uuid.dart';
import 'package:trip_planner/features/trip/controller/watch_trip_provider.dart';
import 'package:trip_planner/features/trip/model/day_plan_item_model.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/model/expense_item_model.dart';
import 'package:trip_planner/features/trip/widgets/day_plan/day_plan_item_expenses_section.dart';

class AddDayPlanItemDialog extends ConsumerStatefulWidget {
  final String tripId;
  final DateTime date;
  final DayPlanItem? editItem;

  const AddDayPlanItemDialog({
    super.key,
    required this.tripId,
    required this.date,
    this.editItem,
  });

  @override
  ConsumerState<AddDayPlanItemDialog> createState() =>
      _AddDayPlanItemDialogState();
}

class _AddDayPlanItemDialogState extends ConsumerState<AddDayPlanItemDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay? _endTime;
  String? _selectedIcon;
  MarkerPoint? _selectedLocationMarker;

  MarkerPoint? _selectedMarker;

  List<ExpenseItem> _expenses = [];

  bool get _isEditing => widget.editItem != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (_isEditing) {
      final item = widget.editItem!;
      _titleController.text = item.title;
      _descriptionController.text = item.description ?? '';
      _startTime = TimeOfDay.fromDateTime(item.startTime);
      if (item.endTime != null) {
        _endTime = TimeOfDay.fromDateTime(item.endTime!);
      }
      _selectedIcon = item.icon;

      _expenses = item.expenses ?? [];

      if (item.type == DayPlanItemType.marker) {
        _tabController.index = 1;
      }

      if (item.type == DayPlanItemType.custom && item.markerId != null) {}
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCustomEventTab(),
                  _buildMarkerSelectionTab(),
                ],
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.borderPrimaryLight),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: AppColors.textPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isEditing ? 'Edytuj aktywność' : 'Dodaj aktywność',
              style: AppTextStyles.heading3,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomEventTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nazwa aktywności',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'np. Śniadanie, Spotkanie...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Opis (opcjonalny)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Dodatkowe informacje...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          _buildLocationSection(),
          const SizedBox(height: 16),
          _buildTimeSection(),
          const SizedBox(height: 16),
          _buildIconSelection(),
          const SizedBox(height: 24),
          DayPlanItemExpensesSection(
            item: DayPlanItem(
              id: widget.editItem?.id ?? '',
              type: DayPlanItemType.custom,
              startTime: DateTime.now(),
              title: '',
              order: 0,
              expenses: _expenses,
            ),
            onExpensesChanged: (expenses) {
              setState(() {
                _expenses = expenses;
              });
            },
            tripId: widget.tripId,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Czas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTimeButton(
                label: 'Początek',
                time: _startTime,
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _startTime,
                  );
                  if (time != null) {
                    setState(() => _startTime = time);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTimeButton(
                label: 'Koniec',
                time: _endTime,
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _endTime ?? _startTime,
                  );
                  setState(() => _endTime = time);
                },
                canClear: true,
                onClear: () => setState(() => _endTime = null),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeButton({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
    bool canClear = false,
    VoidCallback? onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall,
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderDark),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time,
                    size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    time != null ? time.format(context) : 'Brak',
                    style: AppTextStyles.labelHint,
                  ),
                ),
                if (canClear && time != null)
                  GestureDetector(
                    onTap: onClear,
                    child: Icon(
                      Icons.clear,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ikona',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildIconChip('restaurant', Icons.restaurant, 'Jedzenie'),
            _buildIconChip('local_cafe', Icons.local_cafe, 'Kawa'),
            _buildIconChip('hotel', Icons.hotel, 'Hotel'),
            _buildIconChip('shopping', Icons.shopping_bag, 'Zakupy'),
            _buildIconChip('event', Icons.event, 'Wydarzenie'),
          ],
        ),
      ],
    );
  }

  Widget _buildIconChip(String id, IconData icon, String label) {
    final isSelected = _selectedIcon == id;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        setState(() => _selectedIcon = selected ? id : null);
      },
    );
  }

  Widget _buildLocationSection() {
    final tripAsync = ref.watch(watchTripProvider(widget.tripId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Lokalizacja (opcjonalne)',
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(width: 8),
          ],
        ),
        const SizedBox(height: 8),
        tripAsync.when(
          data: (trip) {
            final markers = trip.markerPoints;

            if (markers.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_off, color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Brak punktów na mapie',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderDark),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  if (_selectedLocationMarker != null)
                    ListTile(
                      leading:
                          Icon(Icons.place, color: AppColors.textSecondary),
                      title: Text(
                        _selectedLocationMarker!.name ?? 'Bez nazwy',
                        style: AppTextStyles.bodyText,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.clear,
                            color: AppColors.textSecondary),
                        onPressed: () {
                          setState(() => _selectedLocationMarker = null);
                        },
                        tooltip: 'Usuń lokalizację',
                      ),
                    )
                  else
                    InkWell(
                      onTap: () => _showLocationPicker(markers),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.add_location,
                                color: AppColors.textSecondary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Wybierz lokalizację z mapy',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right,
                                color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
          loading: () => const SizedBox(
            height: 50,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderError),
            ),
            child: Text('Błąd: $e'),
          ),
        ),
      ],
    );
  }

  Future<void> _showLocationPicker(List<MarkerPoint> markers) async {
    final selected = await showDialog<MarkerPoint>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wybierz lokalizację'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: markers.length,
            itemBuilder: (context, index) {
              final marker = markers[index];
              return ListTile(
                leading: const Icon(Icons.place),
                title: Text(marker.name ?? 'Bez nazwy'),
                subtitle: marker.description != null
                    ? Text(
                        marker.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                onTap: () => Navigator.pop(context, marker),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
        ],
      ),
    );

    if (selected != null) {
      setState(() => _selectedLocationMarker = selected);
    }
  }

  Widget _buildMarkerSelectionTab() {
    final tripAsync = ref.watch(watchTripProvider(widget.tripId));

    return tripAsync.when(
      data: (trip) {
        final markers = trip.markerPoints;

        if (markers.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Brak markerów w podróży.\nDodaj markery na mapie.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: markers.length,
          itemBuilder: (context, index) {
            final marker = markers[index];
            final isSelected = _selectedMarker?.id == marker.id;

            return Card(
              color: isSelected ? Colors.blue.shade50 : null,
              child: ListTile(
                leading: Icon(
                  Icons.place,
                  color: isSelected ? Colors.blue.shade700 : null,
                ),
                title: Text(
                  marker.name ?? 'Bez nazwy',
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                ),
                subtitle: marker.description != null
                    ? Text(
                        marker.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: Colors.blue.shade700)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedMarker = isSelected ? null : marker;
                    if (_selectedMarker != null) {
                      _titleController.text = marker.name ?? '';
                      _descriptionController.text = marker.description ?? '';
                    }
                  });
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Błąd: $e')),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _canSave() ? _save : null,
            child: Text(_isEditing ? 'Zapisz' : 'Dodaj'),
          ),
        ],
      ),
    );
  }

  bool _canSave() {
    if (_tabController.index == 0) {
      return _titleController.text.trim().isNotEmpty;
    } else {
      return _selectedMarker != null;
    }
  }

  void _save() {
    final isMarkerTab = _tabController.index == 1;

    final startDateTime = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      _startTime.hour,
      _startTime.minute,
    );

    DateTime? endDateTime;
    if (_endTime != null) {
      endDateTime = DateTime(
        widget.date.year,
        widget.date.month,
        widget.date.day,
        _endTime!.hour,
        _endTime!.minute,
      );
    }

    String? finalMarkerId;
    LatLng? finalLocation;

    if (isMarkerTab && _selectedMarker != null) {
      finalMarkerId = _selectedMarker!.id;
      finalLocation = _selectedMarker!.position;
    } else if (!isMarkerTab && _selectedLocationMarker != null) {
      finalMarkerId = _selectedLocationMarker!.id;
      finalLocation = _selectedLocationMarker!.position;
    }

    final item = DayPlanItem(
      id: _isEditing ? widget.editItem!.id : const Uuid().v4(),
      type: isMarkerTab ? DayPlanItemType.marker : DayPlanItemType.custom,
      startTime: startDateTime,
      endTime: endDateTime,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      markerId: finalMarkerId,
      location: finalLocation,
      icon: _selectedIcon,
      order: _isEditing ? widget.editItem!.order : 0,
      expenses: _expenses,
    );

    Navigator.pop(context, item);
  }
}
