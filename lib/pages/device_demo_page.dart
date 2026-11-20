import 'package:flutter/material.dart';

class DeviceDemoPage extends StatefulWidget {
  const DeviceDemoPage({super.key});

  @override
  State<DeviceDemoPage> createState() => _DeviceDemoPageState();
}

class _DeviceDemoPageState extends State<DeviceDemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KosFinder · Device Demo'),
      ),
      body: const Center(
        child: Text('Kerangka Aplikasi KosFinder Device Demo siap.'),
      ),
    );
  }
}
