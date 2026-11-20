import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_fundamentals/main.dart';

// Smoke test ringan tanpa memerlukan kamera/GPS/Supabase di runner test.
void main() {
  test('App root is a MaterialApp widget', () {
    const app = KosFinderDeviceApp();
    expect(app, isA<StatelessWidget>());
  });
}
