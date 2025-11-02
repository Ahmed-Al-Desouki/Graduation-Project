import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box settingsBox;
  bool isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    settingsBox = Hive.box('settings');
    isBiometricEnabled = settingsBox.get(
      'biometric_enabled',
      defaultValue: false,
    );
  }

  void _toggleBiometric(bool value) {
    settingsBox.put('biometric_enabled', value);
    setState(() => isBiometricEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SwitchListTile(
        title: const Text('تسجيل الدخول بالبصمة'),
        value: isBiometricEnabled,
        onChanged: _toggleBiometric,
      ),
    );
  }
}
