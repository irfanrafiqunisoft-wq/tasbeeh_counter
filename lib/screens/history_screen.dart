import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tasbeeh.dart';

class HistoryScreen extends StatelessWidget {
  final List<Tasbeeh> tasbeehs;

  const HistoryScreen({super.key, required this.tasbeehs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: tasbeehs.isEmpty
          ? const Center(child: Text('Abhi koi data nahi hai'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasbeehs.length,
              itemBuilder: (context, index) {
                return _TasbeehHistoryCard(tasbeeh: tasbeehs[index]);
              },
            ),
    );
  }
}

class _TasbeehHistoryCard extends StatelessWidget {
  final Tasbeeh tasbeeh;

  const _TasbeehHistoryCard({required this.tasbeeh});

  List<MapEntry<String, int>> get _sortedHistory {
    final entries = tasbeeh.dailyHistory.entries.toList();
    entries.sort((a, b) => b.key.compareTo(a.key)); // newest first
    return entries.take(14).toList(); // pichle 14 din dikhayen
  }

  String _formatDate(String dateKey) {
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateKey);
      return DateFormat('d MMM, EEE').format(date);
    } catch (e) {
      return dateKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final history = _sortedHistory;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tasbeeh.name,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Daily target: ${tasbeeh.dailyTarget}  •  Total: ${tasbeeh.totalCompleted}/${tasbeeh.totalTarget}',
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            const Divider(height: 20),
            if (history.isEmpty)
              const Text('Abhi tak koi din ka data nahi hai.')
            else
              ...history.map((entry) {
                final met = entry.value >= tasbeeh.dailyTarget;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(_formatDate(entry.key)),
                      ),
                      Text(
                        '${entry.value} / ${tasbeeh.dailyTarget}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: met ? theme.colorScheme.secondary : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        met ? Icons.check_circle : Icons.circle_outlined,
                        size: 16,
                        color: met
                            ? theme.colorScheme.secondary
                            : theme.textTheme.bodyMedium?.color?.withOpacity(0.3),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
