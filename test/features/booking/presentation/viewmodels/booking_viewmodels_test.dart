import 'package:cashier/features/booking/presentation/viewmodels/booking_viewmodels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaxiInfo', () {
    const driver = DriverInfo(
      name: 'Hassan',
      phone: '0600000000',
      licenseNumber: 'LIC-001',
      balance: 100.0,
    );

    const taxi = TaxiInfo(
      id: 't1',
      plateNumber: 'A-001-MA',
      totalSeats: 6,
      occupiedSeats: 4,
      status: 'En attente',
      driver: driver,
    );

    test('availableSeats = totalSeats - occupiedSeats', () {
      expect(taxi.availableSeats, 2);
    });

    test('copyWith overrides occupiedSeats', () {
      final updated = taxi.copyWith(occupiedSeats: 6);
      expect(updated.availableSeats, 0);
      expect(updated.plateNumber, taxi.plateNumber);
    });

    test('isFirst defaults to false', () {
      expect(taxi.isFirst, isFalse);
    });
  });

  group('LineInfo', () {
    test('taxiCount defaults to 0', () {
      const line = LineInfo(
        id: 'l1',
        origin: 'Marrakech',
        destination: 'Casablanca',
        price: 80,
      );
      expect(line.taxiCount, 0);
    });
  });
}
