import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/input_style.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/auth/controller/user_provider.dart';
import 'package:trip_planner/features/budget/widgets/dialog/dialog_payer_option_tile.dart';
import 'package:trip_planner/features/budget/model/budget_payer_selection_model.dart';
import 'package:trip_planner/features/friends/controller/friends_provider.dart';
import 'package:trip_planner/features/friends/service/shared_trip_service.dart';

class DialogPayerSelector extends ConsumerStatefulWidget {
  const DialogPayerSelector({
    super.key,
    required this.tripId,
    required this.initialPayerName,
    required this.initialPayerUserId,
    required this.onChanged,
  });

  final String? tripId;
  final String? initialPayerName;
  final String? initialPayerUserId;
  final void Function(BudgetPayerSelection) onChanged;

  @override
  ConsumerState<DialogPayerSelector> createState() =>
      _BudgetPayerSelectorState();
}

class _BudgetPayerSelectorState extends ConsumerState<DialogPayerSelector> {
  late final TextEditingController _payerNameController;
  String? _selectedPayerUserId;
  _PayerMode _payerMode = _PayerMode.currentUser;

  @override
  void initState() {
    super.initState();

    _payerNameController = TextEditingController(
      text: widget.initialPayerName ?? '',
    );
    _selectedPayerUserId = widget.initialPayerUserId;

    if (widget.initialPayerUserId != null) {
      final currentUser = ref.read(authStateProvider).value;
      if (widget.initialPayerUserId == currentUser?.uid) {
        _payerMode = _PayerMode.currentUser;
      } else {
        _payerMode = _PayerMode.sharedMember;
      }
    } else if (widget.initialPayerName != null &&
        widget.initialPayerName!.isNotEmpty) {
      _payerMode = _PayerMode.customName;
    } else {
      _selectCurrentUser(notify: false);
    }

    _notifyParent();
  }

  @override
  void dispose() {
    _payerNameController.dispose();
    super.dispose();
  }

  void _notifyParent() {
    final name = _payerNameController.text.trim();
    final resolvedName = name.isEmpty ? null : name;

    widget.onChanged(
      BudgetPayerSelection(
        payerName: resolvedName,
        payerUserId: (_payerMode == _PayerMode.sharedMember ||
                _PayerMode.currentUser == _payerMode)
            ? _selectedPayerUserId
            : null,
      ),
    );
  }

  void _selectCurrentUser({bool notify = true}) {
    final currentUser = ref.read(authStateProvider).value;
    if (currentUser != null) {
      setState(() {
        _payerMode = _PayerMode.currentUser;
        _payerNameController.text =
            currentUser.displayName ?? currentUser.email ?? 'Ja';
        _selectedPayerUserId = currentUser.uid;
      });
      if (notify) _notifyParent();
    }
  }

  void _selectCustomName() {
    setState(() {
      _payerMode = _PayerMode.customName;
      _selectedPayerUserId = null;
      if (_payerNameController.text.isEmpty) {
        _payerNameController.clear();
      }
    });
    _notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    final sharedMembersAsync = widget.tripId != null
        ? ref.watch(sharedMembersProvider(widget.tripId!))
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kto płacił?',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 12),
        _buildPayerSelectionButtons(sharedMembersAsync),
        const SizedBox(height: 16),
        _buildPayerNameField(sharedMembersAsync),
      ],
    );
  }

  Widget _buildPayerSelectionButtons(
    AsyncValue<List<SharedTripMember>>? sharedMembersAsync,
  ) {
    final currentUser = ref.read(authStateProvider).value;
    final hasSharedMembers = sharedMembersAsync?.value?.isNotEmpty ?? false;

    return Column(
      children: [
        BudgetPayerOptionTile(
          icon: Icons.person,
          label: 'Ja',
          subtitle: currentUser?.displayName ?? currentUser?.email ?? '',
          isSelected: _payerMode == _PayerMode.currentUser,
          onTap: _selectCurrentUser,
        ),
        const SizedBox(height: 8),
        if (hasSharedMembers)
          BudgetPayerOptionTile(
            icon: Icons.people,
            label: 'Osoba współdzieląca podróż',
            subtitle: 'Wybierz ze znajomych',
            isSelected: _payerMode == _PayerMode.sharedMember,
            onTap: () {
              setState(() {
                _payerMode = _PayerMode.sharedMember;
                _selectedPayerUserId = null;
                _payerNameController.clear();
              });
              _notifyParent();
            },
          ),
        if (hasSharedMembers) const SizedBox(height: 8),
        BudgetPayerOptionTile(
          icon: Icons.person_outline,
          label: 'Inna osoba',
          subtitle: 'Wpisz dowolne imię',
          isSelected: _payerMode == _PayerMode.customName,
          onTap: _selectCustomName,
        ),
      ],
    );
  }

  Widget _buildPayerNameField(
    AsyncValue<List<SharedTripMember>>? sharedMembersAsync,
  ) {
    if (_payerMode == _PayerMode.sharedMember && widget.tripId != null) {
      if (sharedMembersAsync == null) {
        return const Text(
          'Brak danych o współdzielonych członkach',
          style: TextStyle(color: Colors.grey),
        );
      }

      return sharedMembersAsync.when(
        data: (members) {
          if (members.isEmpty) {
            return const Text(
              'Brak współdzielonych członków',
              style: TextStyle(color: Colors.grey),
            );
          }

          final currentUser = ref.read(authStateProvider).value;

          final allAvailableUids = <String>[
            if (currentUser != null) currentUser.uid,
            ...members.map((m) => m.uid),
          ];

          if (_selectedPayerUserId != null &&
              !allAvailableUids.contains(_selectedPayerUserId)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _selectedPayerUserId = null;
              });
              _notifyParent();
            });
          }

          return DropdownButtonFormField<String>(
            decoration: AppInputStyle.inputDecoration(
              icon: Icons.people,
              labelText: 'Wybierz osobę',
              hintText: null,
            ).copyWith(
              helperText: 'Wybierz ze współdzielonych',
            ),
            value: allAvailableUids.contains(_selectedPayerUserId)
                ? _selectedPayerUserId
                : null,
            hint: const Text(
              'Kliknij aby wybrać',
              style: AppTextStyles.labelHint,
            ),
            isExpanded: true,
            items: [
              if (currentUser != null)
                DropdownMenuItem(
                  value: currentUser.uid,
                  child: Row(
                    children: [
                      const Icon(Icons.person,
                          size: 20, color: AppColors.limeSliceDark),
                      const SizedBox(width: 8),
                      Text(
                        'Ja (${currentUser.displayName ?? currentUser.email})',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ...members.map((member) {
                return DropdownMenuItem(
                  value: member.uid,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor:
                            AppColors.limeSliceDark.withValues(alpha: 0.1),
                        backgroundImage:
                            member.avatar != null && member.avatar!.isNotEmpty
                                ? NetworkImage(member.avatar!)
                                : null,
                        child: member.avatar == null || member.avatar!.isEmpty
                            ? Text(
                                member.displayName[0].toUpperCase(),
                                style: AppTextStyles.bodySmall,
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          member.displayName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _selectedPayerUserId = value;

                if (value == currentUser?.uid) {
                  _payerNameController.text =
                      currentUser!.displayName ?? currentUser.email ?? 'Ja';
                } else {
                  final member = members.firstWhere((m) => m.uid == value);
                  _payerNameController.text = member.displayName;
                }
              });
              _notifyParent();
            },
          );
        },
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const Text(
          'Błąd podczas ładowania członków',
          style: TextStyle(color: AppColors.red),
        ),
      );
    }

    return TextField(
      controller: _payerNameController,
      decoration: AppInputStyle.inputDecoration(
        icon: Icons.account_circle,
        labelText: 'Imię i nazwisko',
        hintText: 'np. Jan Kowalski',
      ).copyWith(
        helperText: _payerMode == _PayerMode.currentUser
            ? 'Wybrano: Ty'
            : 'Możesz wpisać dowolne imię',
      ),
      textCapitalization: TextCapitalization.words,
      enabled: _payerMode == _PayerMode.customName,
      onChanged: (value) {
        setState(() {});
        _notifyParent();
      },
    );
  }
}

enum _PayerMode {
  currentUser,
  sharedMember,
  customName,
}
