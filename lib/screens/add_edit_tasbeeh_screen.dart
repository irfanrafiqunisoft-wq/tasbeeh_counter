import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/tasbeeh.dart';

class AddEditTasbeehScreen extends StatefulWidget {
  final Tasbeeh? existing;

  const AddEditTasbeehScreen({super.key, this.existing});

  @override
  State<AddEditTasbeehScreen> createState() => _AddEditTasbeehScreenState();
}

class _AddEditTasbeehScreenState extends State<AddEditTasbeehScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _targetController;
  late TextEditingController _daysController;

  final List<int> _quickTargets = [33, 100, 1000];
  final List<int> _quickDays = [1, 7, 30];

  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _targetController =
        TextEditingController(text: existing?.totalTarget.toString() ?? '1000');
    _daysController =
        TextEditingController(text: existing?.totalDays.toString() ?? '7');
    _reminderEnabled = existing?.reminderEnabled ?? false;
    if (existing != null) {
      _reminderTime = TimeOfDay(hour: existing.reminderHour, minute: existing.reminderMinute);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  int get _previewDailyTarget {
    final target = int.tryParse(_targetController.text) ?? 0;
    final days = int.tryParse(_daysController.text) ?? 1;
    if (days <= 0) return target;
    final result = (target / days).ceil();
    return result < 1 ? 1 : result;
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final target = int.parse(_targetController.text);
    final days = int.parse(_daysController.text);

    final tasbeeh = Tasbeeh(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: name,
      totalTarget: target,
      totalDays: days,
      startDate: widget.existing?.startDate ?? DateTime.now(),
      dailyHistory: widget.existing?.dailyHistory ?? {},
      reminderEnabled: _reminderEnabled,
      reminderHour: _reminderTime.hour,
      reminderMinute: _reminderTime.minute,
    );

    Navigator.pop(context, tasbeeh);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Tasbeeh' : 'New Tasbeeh'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Tasbeeh Name', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g. SubhanAllah, Durood, Astaghfirullah',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Naam likhna zaroori hai';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),

            const Text('Total Target Count', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _quickTargets.map((value) {
                final selected = _targetController.text == value.toString();
                return ChoiceChip(
                  label: Text('$value'),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _targetController.text = value.toString();
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ya apna custom number likhein',
              ),
              validator: (value) {
                final n = int.tryParse(value ?? '');
                if (n == null || n <= 0) return 'Sahi number likhein (1 ya zyada)';
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),

            const Text('Kitne Din Mein Complete Karna Hai', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _quickDays.map((value) {
                final selected = _daysController.text == value.toString();
                return ChoiceChip(
                  label: Text('$value din'),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _daysController.text = value.toString();
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _daysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ya apne din likhein',
              ),
              validator: (value) {
                final n = int.tryParse(value ?? '');
                if (n == null || n <= 0) return 'Sahi number likhein (1 ya zyada)';
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calculate_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Daily target: $_previewDailyTarget / din',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Daily Reminder', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Roz ek waqt par notification aayegi'),
              value: _reminderEnabled,
              onChanged: (value) => setState(() => _reminderEnabled = value),
            ),
            if (_reminderEnabled)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time),
                title: const Text('Reminder Time'),
                trailing: Text(
                  _reminderTime.format(context),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: _pickReminderTime,
              ),

            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(_isEditing ? 'Update Tasbeeh' : 'Create Tasbeeh'),
            ),
          ],
        ),
      ),
    );
  }
}
