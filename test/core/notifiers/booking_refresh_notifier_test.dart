import 'package:cashier/core/notifiers/booking_refresh_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('refresh notifies listeners', () {
    final notifier = BookingRefreshNotifier();
    int callCount = 0;
    notifier.addListener(() => callCount++);

    notifier.refresh();

    expect(callCount, 1);
  });

  test('refresh notifies multiple times', () {
    final notifier = BookingRefreshNotifier();
    int callCount = 0;
    notifier.addListener(() => callCount++);

    notifier.refresh();
    notifier.refresh();
    notifier.refresh();

    expect(callCount, 3);
  });
}
