import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../models/tasbeeh.dart';
import '../services/ad_helper.dart';
import '../services/storage_service.dart';
import '../widgets/banner_ad_widget.dart';

class CounterScreen extends StatefulWidget {
  final Tasbeeh tasbeeh;
  final Function(Tasbeeh) onUpdate;

  const CounterScreen({
    super.key,
    required this.tasbeeh,
    required this.onUpdate,
  });

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  late Tasbeeh _tasbeeh;
  final InterstitialAdManager _interstitialAdManager = InterstitialAdManager();
  bool _vibrationEnabled = true;
  bool _targetAnnouncedToday = false;

  @override
  void initState() {
    super.initState();
    _tasbeeh = widget.tasbeeh;
    _interstitialAdManager.loadAd();
    _targetAnnouncedToday = _tasbeeh.isTodayTargetMet;
    _loadVibrationSetting();
  }

  Future<void> _loadVibrationSetting() async {
    final v = await StorageService.getVibration();
    setState(() {
      _vibrationEnabled = v;
    });
  }

  Future<void> _increment() async {
    setState(() {
      _tasbeeh.addCount(1);
    });
    widget.onUpdate(_tasbeeh);

    if (_vibrationEnabled) {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator) {
        Vibration.vibrate(duration: 25);
      } else {
        HapticFeedback.lightImpact();
      }
    }

    if (_tasbeeh.isTodayTargetMet && !_targetAnnouncedToday) {
      _targetAnnouncedToday = true;
      _onDailyTargetComplete();
    }
  }

  void _onDailyTargetComplete() {
    if (_vibrationEnabled) {
      Vibration.vibrate(duration: 200);
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mubarak ho! 🌿'),
        content: Text(
          'Aaj ka target (${_tasbeeh.dailyTarget} ${_tasbeeh.name}) mukamal ho gaya.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Theek hai'),
          ),
        ],
      ),
    ).then((_) {
      _interstitialAdManager.showAdIfAvailable();
    });
  }

  void _resetToday() {
    setState(() {
      _tasbeeh.resetToday();
      _targetAnnouncedToday = false;
    });
    widget.onUpdate(_tasbeeh);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _tasbeeh.dailyTarget > 0
        ? (_tasbeeh.todayCount / _tasbeeh.dailyTarget).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_tasbeeh.name),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatChip(label: 'Total', value: '${_tasbeeh.totalCompleted}/${_tasbeeh.totalTarget}'),
                  _StatChip(label: 'Overall', value: '${_tasbeeh.overallPercentage.toStringAsFixed(0)}%'),
                ],
              ),
            ),
            const Spacer(),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _tasbeeh.isTodayTargetMet
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.primary,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_tasbeeh.todayCount}',
                      style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '/ ${_tasbeeh.dailyTarget} aaj',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Remaining aaj: ${_tasbeeh.remainingToday}',
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _increment,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.touch_app, color: Colors.white, size: 56),
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: _resetToday,
              icon: const Icon(Icons.refresh),
              label: const Text("Reset Today's Count"),
            ),
            const SizedBox(height: 8),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
