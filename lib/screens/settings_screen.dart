import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeToggle;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _vibration = true;

  @override
  void initState() {
    super.initState();
    _loadVibration();
  }

  Future<void> _loadVibration() async {
    final v = await StorageService.getVibration();
    setState(() => _vibration = v);
  }

  Future<void> _updateVibration(bool value) async {
    setState(() => _vibration = value);
    await StorageService.setVibration(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Vibration Feedback', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            value: _vibration,
            onChanged: _updateVibration,
          ),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            value: widget.isDarkMode,
            onChanged: widget.onThemeToggle,
          ),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Tasbeeh Counter v1.0\nSara data aap ke device mein hi save hota hai.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
