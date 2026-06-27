import 'package:flutter/material.dart';
import '../models/tasbeeh.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/tasbeeh_card.dart';
import 'add_edit_tasbeeh_screen.dart';
import 'counter_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class TasbeehListScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeToggle;

  const TasbeehListScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<TasbeehListScreen> createState() => _TasbeehListScreenState();
}

class _TasbeehListScreenState extends State<TasbeehListScreen> {
  List<Tasbeeh> _tasbeehs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await StorageService.getTasbeehList();
    setState(() {
      _tasbeehs = list;
      _loading = false;
    });
  }

  Future<void> _saveData() async {
    await StorageService.saveTasbeehList(_tasbeehs);
  }

  Future<void> _addNewTasbeeh() async {
    final result = await Navigator.push<Tasbeeh>(
      context,
      MaterialPageRoute(builder: (context) => const AddEditTasbeehScreen()),
    );
    if (result != null) {
      setState(() {
        _tasbeehs.add(result);
      });
      await _saveData();
      if (result.reminderEnabled) {
        await NotificationService.scheduleDailyReminder(
          tasbeehId: result.id,
          tasbeehName: result.name,
          hour: result.reminderHour,
          minute: result.reminderMinute,
        );
      }
    }
  }

  Future<void> _editTasbeeh(Tasbeeh tasbeeh) async {
    final result = await Navigator.push<Tasbeeh>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTasbeehScreen(existing: tasbeeh),
      ),
    );
    if (result != null) {
      setState(() {
        final index = _tasbeehs.indexWhere((t) => t.id == result.id);
        if (index != -1) _tasbeehs[index] = result;
      });
      await _saveData();
      if (result.reminderEnabled) {
        await NotificationService.scheduleDailyReminder(
          tasbeehId: result.id,
          tasbeehName: result.name,
          hour: result.reminderHour,
          minute: result.reminderMinute,
        );
      } else {
        await NotificationService.cancelReminder(result.id);
      }
    }
  }

  Future<void> _deleteTasbeeh(Tasbeeh tasbeeh) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tasbeeh?'),
        content: Text('"${tasbeeh.name}" delete karna chahte hain? Sara progress data bhi delete ho jayega.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _tasbeehs.removeWhere((t) => t.id == tasbeeh.id);
      });
      await _saveData();
      await NotificationService.cancelReminder(tasbeeh.id);
    }
  }

  Future<void> _openCounter(Tasbeeh tasbeeh) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CounterScreen(
          tasbeeh: tasbeeh,
          onUpdate: (updated) async {
            setState(() {
              final index = _tasbeehs.indexWhere((t) => t.id == updated.id);
              if (index != -1) _tasbeehs[index] = updated;
            });
            await _saveData();
          },
        ),
      ),
    );
    setState(() {}); // refresh progress bars after returning
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          isDarkMode: widget.isDarkMode,
          onThemeToggle: widget.onThemeToggle,
        ),
      ),
    );
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryScreen(tasbeehs: _tasbeehs),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasbeehs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'History',
            onPressed: _openHistory,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: _openSettings,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTasbeeh,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: _tasbeehs.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            itemCount: _tasbeehs.length,
                            itemBuilder: (context, index) {
                              final tasbeeh = _tasbeehs[index];
                              return TasbeehCard(
                                tasbeeh: tasbeeh,
                                onTap: () => _openCounter(tasbeeh),
                                onEdit: () => _editTasbeeh(tasbeeh),
                                onDelete: () => _deleteTasbeeh(tasbeeh),
                              );
                            },
                          ),
                  ),
                  const BannerAdWidget(),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.self_improvement,
              size: 72,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'Abhi koi Tasbeeh nahi hai',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Neeche + button dabayen aur apni pehli Tasbeeh banayen - naam, target aur din set karein.',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
