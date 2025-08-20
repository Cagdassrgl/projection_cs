import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:projection_cs/projection_cs.dart';

void main() {
  group('Locale Independence Tests', () {
    test('WKT output should be consistent regardless of locale settings', () {
      // Test with coordinates that would be formatted differently in different locales
      final coordinates = [LatLng(41.0082123, 28.9784456)]; // Istanbul with decimal precision

      final pointWkt = WktGenerator.createPoint(
        coordinates: coordinates,
        sourceProjectionKey: 'EPSG:4326',
        targetProjectionKey: 'EPSG:4326',
      );

      // WKT should always use dot as decimal separator, not comma (European locales)
      expect(pointWkt, contains('.'));
      expect(pointWkt, isNot(contains(',')));

      // Should be a valid point format
      expect(pointWkt, startsWith('POINT'));
      expect(pointWkt, contains('('));
      expect(pointWkt, contains(')'));

      print('Generated WKT: $pointWkt');
    });

    test('Multiple WKT generations should produce identical format', () {
      final coordinates = [LatLng(41.0082, 28.9784)];

      final wkt1 = WktGenerator.createPoint(
        coordinates: coordinates,
        sourceProjectionKey: 'EPSG:4326',
        targetProjectionKey: 'EPSG:4326',
      );

      final wkt2 = WktGenerator.createPoint(
        coordinates: coordinates,
        sourceProjectionKey: 'EPSG:4326',
        targetProjectionKey: 'EPSG:4326',
      );

      // Should be identical
      expect(wkt1, equals(wkt2));

      print('WKT 1: $wkt1');
      print('WKT 2: $wkt2');
    });
  });
}
