import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:trip_planner/features/budget/model/trip_expense_item_model.dart';
import 'package:trip_planner/features/auth/controller/user_provider.dart';
import 'package:trip_planner/features/friends/controller/friends_provider.dart';
import 'package:trip_planner/features/friends/service/shared_trip_service.dart';

class TripExpenseDialog extends ConsumerStatefulWidget {
  const TripExpenseDialog({
    super.key,
    this.expenseItem,
    this.tripId,
  });

  final TripExpenseItem? expenseItem;
  final String? tripId;

  @override
  ConsumerState<TripExpenseDialog> createState() => _TripExpenseDialogState();
}

class _TripExpenseDialogState extends ConsumerState<TripExpenseDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _payerNameController;

  String? _selectedPayerUserId;
  bool _isEditMode = false;

  _PayerMode _payerMode = _PayerMode.currentUser;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.expenseItem != null;

    _titleController = TextEditingController(
      text: widget.expenseItem?.title ?? '',
    );
    _amountController = TextEditingController(
      text: widget.expenseItem?.amount.toStringAsFixed(2) ?? '',
    );
    _payerNameController = TextEditingController(
      text: widget.expenseItem?.payerName ?? '',
    );
    _selectedPayerUserId = widget.expenseItem?.payerUserId;

    if (widget.expenseItem != null) {
      if (widget.expenseItem!.payerUserId != null) {
        final currentUser = ref.read(authStateProvider).value;
        if (widget.expenseItem!.payerUserId == currentUser?.uid) {
          _payerMode = _PayerMode.currentUser;
        } else {
          _payerMode = _PayerMode.sharedMember;
        }
      } else if (widget.expenseItem!.payerName != null &&
          widget.expenseItem!.payerName!.isNotEmpty) {
        _payerMode = _PayerMode.customName;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _payerNameController.dispose();
    super.dispose();
  }

  void _selectCurrentUser() {
    final currentUser = ref.read(authStateProvider).value;
    if (currentUser != null) {
      setState(() {
        _payerMode = _PayerMode.currentUser;
        _payerNameController.text =
            currentUser.displayName ?? currentUser.email ?? 'Ja';
        _selectedPayerUserId = currentUser.uid;
      });
    }
  }

  void _selectSharedMember(SharedTripMember? member) {
    if (member == null) return;

    setState(() {
      _payerMode = _PayerMode.sharedMember;
      _payerNameController.text = member.displayName;
      _selectedPayerUserId = member.uid;
    });
  }

  void _selectCustomName() {
    setState(() {
      _payerMode = _PayerMode.customName;
      _payerNameController.clear();
      _selectedPayerUserId = null;
    });
  }

  void _saveExpense() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wpisz tytuł wydatku'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final amount = double.tryParse(
      _amountController.text.replaceAll(',', '.'),
    );

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wpisz poprawną kwotę'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final expense = TripExpenseItem(
      id: widget.expenseItem?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      amount: amount,
      payerName: _payerNameController.text.trim().isNotEmpty
          ? _payerNameController.text.trim()
          : null,
      payerUserId: _selectedPayerUserId,
      createdAt: widget.expenseItem?.createdAt ?? DateTime.now(),
    );

    Navigator.pop(context, expense);
  }

  @override
  Widget build(BuildContext context) {
    final sharedMembersAsync = widget.tripId != null
        ? ref.watch(sharedMembersProvider(widget.tripId!))
        : null;

    return AlertDialog(
      title: Text(_isEditMode ? 'Edytuj wydatek' : 'Dodaj wydatek ogólny'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wydatki ogólne to koszty nieprzypisane do konkretnych miejsc, np. paliwo, zakupy, opłaty parkingowe.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tytuł wydatku *',
                hintText: 'np. Paliwo, Zakupy, Parking',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Kwota (PLN) *',
                hintText: '0.00',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Kto płacił?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildPayerSelectionButtons(sharedMembersAsync),
            const SizedBox(height: 16),
            _buildPayerNameField(sharedMembersAsync),
            const SizedBox(height: 8),
            Text(
              '* Pole wymagane',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Anuluj'),
        ),
        FilledButton(
          onPressed: _saveExpense,
          child: Text(_isEditMode ? 'Zapisz' : 'Dodaj'),
        ),
      ],
    );
  }

  Widget _buildPayerSelectionButtons(
      AsyncValue<List<SharedTripMember>>? sharedMembersAsync) {
    final currentUser = ref.read(authStateProvider).value;
    final hasSharedMembers = sharedMembersAsync?.value?.isNotEmpty ?? false;

    return Column(
      children: [
        _buildPayerButton(
          icon: Icons.person,
          label: 'Ja',
          subtitle: currentUser?.displayName ?? currentUser?.email ?? '',
          isSelected: _payerMode == _PayerMode.currentUser,
          onTap: _selectCurrentUser,
        ),
        const SizedBox(height: 8),
        if (hasSharedMembers)
          _buildPayerButton(
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
            },
          ),
        if (hasSharedMembers) const SizedBox(height: 8),
        _buildPayerButton(
          icon: Icons.person_outline,
          label: 'Inna osoba',
          subtitle: 'Wpisz dowolne imię',
          isSelected: _payerMode == _PayerMode.customName,
          onTap: _selectCustomName,
        ),
      ],
    );
  }

  Widget _buildPayerButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.blue : Colors.black87,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildPayerNameField(
      AsyncValue<List<SharedTripMember>>? sharedMembersAsync) {
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
            });
          }

          return DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Wybierz osobę',
              prefixIcon: Icon(Icons.people),
              border: OutlineInputBorder(),
              helperText: 'Wybierz ze współdzielonych',
            ),
            value: allAvailableUids.contains(_selectedPayerUserId)
                ? _selectedPayerUserId
                : null,
            hint: const Text('Kliknij aby wybrać'),
            isExpanded: true,
            items: [
              if (currentUser != null)
                DropdownMenuItem(
                  value: currentUser.uid,
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 20, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Ja (${currentUser.displayName ?? currentUser.email})',
                        style: const TextStyle(fontWeight: FontWeight.w600),
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
                        backgroundColor: Colors.blue.shade100,
                        backgroundImage:
                            member.avatar != null && member.avatar!.isNotEmpty
                                ? NetworkImage(member.avatar!)
                                : null,
                        child: member.avatar == null || member.avatar!.isEmpty
                            ? Text(
                                member.displayName[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
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
            },
          );
        },
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const Text(
          'Błąd podczas ładowania członków',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return TextField(
      controller: _payerNameController,
      decoration: InputDecoration(
        labelText: 'Imię i nazwisko',
        hintText: 'np. Jan Kowalski',
        prefixIcon: const Icon(Icons.account_circle),
        border: const OutlineInputBorder(),
        helperText: _payerMode == _PayerMode.currentUser
            ? 'Wybrano: Ty'
            : 'Możesz wpisać dowolne imię',
      ),
      textCapitalization: TextCapitalization.words,
      enabled: _payerMode == _PayerMode.customName,
      onChanged: (value) {
        setState(() {});
      },
    );
  }
}

enum _PayerMode {
  currentUser,
  sharedMember,
  customName,
}
