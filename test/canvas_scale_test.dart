import 'package:flutter_test/flutter_test.dart';

// AC6 — canvas scale clamp 0.3–4.0
double clampScale(double current, double gestureScale) {
  return (current * gestureScale).clamp(0.3, 4.0);
}

void main() {
  group('Canvas scale clamp', () {
    test('scale stays within 0.3–4.0 bounds', () {
      expect(clampScale(1.0, 0.1), 0.3);
      expect(clampScale(1.0, 5.0), 4.0);
      expect(clampScale(1.0, 2.0), 2.0);
    });

    test('pinch-in on min scale stays at 0.3', () {
      expect(clampScale(0.3, 0.5), 0.3);
    });

    test('pinch-out on max scale stays at 4.0', () {
      expect(clampScale(4.0, 2.0), 4.0);
    });

    test('normal scale operation', () {
      final result = clampScale(1.5, 1.5);
      expect(result, closeTo(2.25, 0.001));
    });
  });
}
