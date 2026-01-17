import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:graduation_project/features/reminder/data/data_sources/local_occurrence_data_source.dart';

class RingingView extends StatefulWidget {
  final Map<String, String>? payload;
  const RingingView({super.key, this.payload});

  @override
  State<RingingView> createState() => _RingingViewState();
}

class _RingingViewState extends State<RingingView> {
  late Timer _autoDismissTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startAlarm();

    _autoDismissTimer = Timer(const Duration(minutes: 2), () {
      _handleAction(5);
    });
  }

  void _startAlarm() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('sounds/alarm_sound.m4a'));
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [500, 1000, 500, 1000], repeat: 0);
    }
  }

  void _stopAlarm() {
    _audioPlayer.stop();
    Vibration.cancel();
  }

  Future<void> _handleAction(int status) async {
    _stopAlarm();
    _autoDismissTimer.cancel();

    final int id = int.parse(widget.payload!['id']!);

    await LocalOccurrenceDataSource().updateOccurrenceActionOffline(
      id: id,
      newStatus: status,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B4E8C),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.alarm_on, size: 120, color: Colors.white),
            const SizedBox(height: 30),
            Text(
              widget.payload?['title'] ?? "Reminder",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "حان موعد جرعتك الآن",
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 60),

            _buildBigActionButton(
              label: "تم أخذ الدواء",
              icon: Icons.check_circle,
              color: Colors.green,
              onPressed: () => _handleAction(2),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildBigActionButton(
                    label: "غفوة",
                    icon: Icons.snooze,
                    color: Colors.orange,
                    onPressed: () => _handleAction(4),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildBigActionButton(
                    label: "تخطي",
                    icon: Icons.skip_next,
                    color: Colors.redAccent,
                    onPressed: () => _handleAction(3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBigActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 70,
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stopAlarm();
    _autoDismissTimer.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
