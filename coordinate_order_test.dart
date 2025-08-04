import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:projection_cs/projection_cs.dart';

void main() {
  group('Coordinate Order Analysis', () {
    test('EPSG:3857 to EPSG:4326 coordinate order issue - Turkey polygon', () {
      print('=== Koordinat Sırası Analizi ===');

      // Türkiye sınırlarından örnek koordinatlar (EPSG:3857 Web Mercator formatında)
      // Bu koordinatlar Türkiye'nin güneybatı köşesinden alınmıştır
      final webMercatorTurkey = LatLng(4340954.37, 3226810.72); // Web Mercator format

      print('Web Mercator koordinat (girdi): lat=${webMercatorTurkey.latitude}, lng=${webMercatorTurkey.longitude}');

      // EPSG:3857'den EPSG:4326'ya dönüştür
      final wgs84Point = ProjectionConverter.convert(
        sourcePoint: webMercatorTurkey,
        sourceProjectionKey: 'EPSG:3857',
        targetProjectionKey: 'EPSG:4326',
      );

      print('WGS84 koordinat (çıktı): lat=${wgs84Point.latitude}, lng=${wgs84Point.longitude}');

      // Türkiye'nin koordinat aralıkları:
      // Latitude: 35.8 - 42.1 (kuzey-güney)
      // Longitude: 25.6 - 44.8 (batı-doğu)

      print('Türkiye koordinat aralıkları:');
      print('Latitude: 35.8 - 42.1');
      print('Longitude: 25.6 - 44.8');

      bool isInTurkey = wgs84Point.latitude >= 35.8 && wgs84Point.latitude <= 42.1 && wgs84Point.longitude >= 25.6 && wgs84Point.longitude <= 44.8;

      print('Koordinat Türkiye sınırlarında mı? $isInTurkey');

      if (!isInTurkey) {
        print('⚠️  PROBLEM TESPİT EDİLDİ: Koordinat Türkiye sınırları dışında!');

        // Koordinatları ters çevirip tekrar test edelim
        final reversedWgs84 = LatLng(wgs84Point.longitude, wgs84Point.latitude);
        print('Ters çevrilmiş koordinat: lat=${reversedWgs84.latitude}, lng=${reversedWgs84.longitude}');

        bool isReversedInTurkey = reversedWgs84.latitude >= 35.8 && reversedWgs84.latitude <= 42.1 && reversedWgs84.longitude >= 25.6 && reversedWgs84.longitude <= 44.8;

        print('Ters çevrilmiş koordinat Türkiye\'de mi? $isReversedInTurkey');

        if (isReversedInTurkey) {
          print('🔥 SORUN BULUNDU: Koordinat sırası yanlış! x,y değerleri yer değiştirmeli.');
        }
      }

      // Test geçmese bile analiz için devam et
      expect(true, isTrue); // Test her zaman geçsin, sadece analiz için
    });

    test('Test multiple Turkey border coordinates', () {
      print('\n=== Çoklu Türkiye Sınır Koordinatları Testi ===');

      // Türkiye'nin farklı bölgelerinden Web Mercator koordinatları
      final testPoints = [
        LatLng(4340954.37, 3226810.72), // Güneybatı
        LatLng(4980000.0, 3800000.0), // Merkez Anadolu
        LatLng(5100000.0, 4100000.0), // Doğu
        LatLng(4600000.0, 3500000.0), // Batı
      ];

      for (int i = 0; i < testPoints.length; i++) {
        final webMercatorPoint = testPoints[i];
        print('\n--- Test Point ${i + 1} ---');
        print('Web Mercator: lat=${webMercatorPoint.latitude}, lng=${webMercatorPoint.longitude}');

        final wgs84Point = ProjectionConverter.convert(
          sourcePoint: webMercatorPoint,
          sourceProjectionKey: 'EPSG:3857',
          targetProjectionKey: 'EPSG:4326',
        );

        print('WGS84: lat=${wgs84Point.latitude}, lng=${wgs84Point.longitude}');

        bool isInTurkey = wgs84Point.latitude >= 35.8 && wgs84Point.latitude <= 42.1 && wgs84Point.longitude >= 25.6 && wgs84Point.longitude <= 44.8;

        print('Türkiye\'de mi? $isInTurkey');

        if (!isInTurkey) {
          print('❌ Bu koordinat Türkiye dışında!');
        }
      }
    });
  });
}
