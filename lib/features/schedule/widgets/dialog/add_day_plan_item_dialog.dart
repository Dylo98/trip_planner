import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/schedule/model/day_plan_item_model.dart';
import 'package:trip_planner/features/schedule/controller/activity_dialog_controller.dart';
import 'package:trip_planner/core/widgets/dialog/dialog_actions_bar.dart';
import 'package:trip_planner/core/widgets/dialog/dialog_header.dart';
import 'package:trip_planner/features/schedule/widgets/dialog/dialog_components/dialog_location_marker_tab.dart';
import 'package:trip_planner/features/schedule/widgets/dialog/dialog_components/dialog_time_section.dart';
import 'package:trip_planner/features/schedule/widgets/dialog/dialog_components/dialog_category_section.dart';
import 'package:trip_planner/features/schedule/widgets/dialog/dialog_components/dialog_location_section.dart';
import 'package:trip_planner/features/schedule/widgets/dialog/dialog_components/dialog_expenses_section.dart';
import 'package:trip_planner/features/schedule/widgets/dialog/dialog_components/dialog_title_description_section.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';

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
  late final ActivityDialogController _controller;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = ActivityDialogController(
      tripId: widget.tripId,
      date: widget.date,
      editItem: widget.editItem,
    );
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _controller.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool _canSave() {
    if (_tabController.index == 0) {
      return _controller.titleController.text.trim().isNotEmpty;
    } else {
      return _controller.selectedMarker != null;
    }
  }

  void _save() {
    final isMarkerTab = _tabController.index == 1;
    final item = isMarkerTab
        ? _controller.buildMarkerItem()
        : _controller.buildCustomItem();

    if (item != null) {
      Navigator.pop(context, item);
    }
  }

  Future<void> _showLocationPicker() async {
    final selected = await showDialog<MarkerPoint>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: SizedBox(
            height: 700,
            child: DialogLocationMarkerTab(
              tripId: widget.tripId,
              selectedMarker: _controller.selectedLocationMarker,
              onMarkerSelected: (marker) {
                Navigator.pop(context, marker);
              },
            ),
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        _controller.selectLocationMarker(selected);
      });
    }
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
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DialogHeader(
                title: widget.editItem != null
                    ? 'Edytuj aktywność'
                    : 'Dodaj aktywność',
                icon: Icons.schedule,
                onClose: () => Navigator.pop(context),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCustomEventTab(),
                    DialogLocationMarkerTab(
                      tripId: widget.tripId,
                      selectedMarker: _controller.selectedMarker,
                      onMarkerSelected: (marker) {
                        setState(() {
                          _controller.selectMarker(marker);
                        });
                      },
                    ),
                  ],
                ),
              ),
              DialogActionsBar(
                isEditing: _controller.isEditing,
                onCancel: () => Navigator.pop(context),
                onConfirm: _save,
                isConfirmEnabled: _canSave(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomEventTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          DialogTitleDescriptionSection(
            titleController: _controller.titleController,
            descriptionController: _controller.descriptionController,
            titleLabel: 'Nazwa aktywności',
            descriptionLabel: 'Opis (opcjonalnie)',
            onTitleChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          DialogLocationSection(
            tripId: widget.tripId,
            selectedMarker: _controller.selectedLocationMarker,
            onMarkerSelected: (marker) {
              setState(() {
                _controller.selectLocationMarker(marker);
              });
            },
            onShowPicker: () => _showLocationPicker(),
          ),
          const SizedBox(height: 16),
          DialogTimeSection(
            startTime: _controller.startTime,
            endTime: _controller.endTime,
            onStartTimeChanged: (time) {
              setState(() {
                _controller.updateStartTime(time);
              });
            },
            onEndTimeChanged: (time) {
              setState(() {
                _controller.updateEndTime(time);
              });
            },
            onClearEndTime: () {
              setState(() {
                _controller.clearEndTime();
              });
            },
          ),
          const SizedBox(height: 16),
          DialogCategorySection(
            selectedIcon: _controller.selectedIcon,
            onIconSelected: (icon) {
              setState(() {
                _controller.selectIcon(icon);
              });
            },
          ),
          const SizedBox(height: 24),
          DialogExpensesSection(
            item: DayPlanItem(
              id: widget.editItem?.id ?? '',
              type: DayPlanItemType.custom,
              startTime: DateTime.now(),
              title: '',
              order: 0,
              expenses: _controller.expenses,
            ),
            onExpensesChanged: (expenses) {
              setState(() {
                _controller.updateExpenses(expenses);
              });
            },
            tripId: widget.tripId,
          ),
        ],
      ),
    );
  }
}
