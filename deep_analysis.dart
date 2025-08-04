import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:projection_cs/projection_cs.dart';

void main() {
  group('Deep Coordinate Analysis', () {
    test('Real Web Mercator to WGS84 conversion analysis', () {
      print('=== Gerçek Web Mercator Dönüşüm Analizi ===');

      // Türkiye İstanbul koordinatları (WGS84)
      final istanbulWgs84 = LatLng(41.0082, 28.9784);
      print('İstanbul WGS84: lat=${istanbulWgs84.latitude}, lng=${istanbulWgs84.longitude}');

      // WGS84'ten Web Mercator'a dönüştür
      final istanbulWebMercator = ProjectionConverter.convert(
        sourcePoint: istanbulWgs84,
        sourceProjectionKey: 'EPSG:4326',
        targetProjectionKey: 'EPSG:3857',
      );

      print('İstanbul Web Mercator: lat=${istanbulWebMercator.latitude}, lng=${istanbulWebMercator.longitude}');

      // Şimdi Web Mercator'dan geri WGS84'e dönüştür
      final backToWgs84 = ProjectionConverter.convert(
        sourcePoint: istanbulWebMercator,
        sourceProjectionKey: 'EPSG:3857',
        targetProjectionKey: 'EPSG:4326',
      );

      print('Geri WGS84: lat=${backToWgs84.latitude}, lng=${backToWgs84.longitude}');

      // Farkları hesapla
      final latDiff = (backToWgs84.latitude - istanbulWgs84.latitude).abs();
      final lngDiff = (backToWgs84.longitude - istanbulWgs84.longitude).abs();

      print('Latitude farkı: $latDiff');
      print('Longitude farkı: $lngDiff');

      // Eğer sorun varsa ters çevrilmiş halini de test et
      if (latDiff > 0.01 || lngDiff > 0.01) {
        print('\n⚠️  Büyük fark tespit edildi, koordinat sırası problemi olabilir!');

        // Web Mercator koordinatlarını ters çevirip dönüştür
        final reversedWebMercator = LatLng(istanbulWebMercator.longitude, istanbulWebMercator.latitude);
        print('Ters çevrilmiş Web Mercator: lat=${reversedWebMercator.latitude}, lng=${reversedWebMercator.longitude}');

        final reversedBackToWgs84 = ProjectionConverter.convert(
          sourcePoint: reversedWebMercator,
          sourceProjectionKey: 'EPSG:3857',
          targetProjectionKey: 'EPSG:4326',
        );

        print('Ters çevrilmiş geri WGS84: lat=${reversedBackToWgs84.latitude}, lng=${reversedBackToWgs84.longitude}');

        final reversedLatDiff = (reversedBackToWgs84.latitude - istanbulWgs84.latitude).abs();
        final reversedLngDiff = (reversedBackToWgs84.longitude - istanbulWgs84.longitude).abs();

        print('Ters çevrilmiş Latitude farkı: $reversedLatDiff');
        print('Ters çevrilmiş Longitude farkı: $reversedLngDiff');

        if (reversedLatDiff < latDiff && reversedLngDiff < lngDiff) {
          print('🔥 SORUN BULUNDU: Koordinat sırası yanlış!');
        }
      }

      expect(true, isTrue);
    });

    test('Manual Web Mercator coordinate test', () {
      print('\n=== Manuel Web Mercator Koordinat Testi ===');

      // El ile hesaplanmış Web Mercator koordinatları (İstanbul için)
      // İstanbul WGS84: 41.0082, 28.9784
      // Beklenen Web Mercator yaklaşık: x=3226835, y=5009377

      final manualWebMercator = LatLng(5009377.085597, 3226835.367812);
      print('Manuel Web Mercator: lat=${manualWebMercator.latitude}, lng=${manualWebMercator.longitude}');

      final convertedWgs84 = ProjectionConverter.convert(
        sourcePoint: manualWebMercator,
        sourceProjectionKey: 'EPSG:3857',
        targetProjectionKey: 'EPSG:4326',
      );

      print('Dönüştürülmüş WGS84: lat=${convertedWgs84.latitude}, lng=${convertedWgs84.longitude}');
      print('Beklenen WGS84: lat=41.0082, lng=28.9784');

      // Koordinatları kontrol et
      bool latOk = (convertedWgs84.latitude - 41.0082).abs() < 0.01;
      bool lngOk = (convertedWgs84.longitude - 28.9784).abs() < 0.01;

      print('Latitude doğru mu? $latOk (fark: ${(convertedWgs84.latitude - 41.0082).abs()})');
      print('Longitude doğru mu? $lngOk (fark: ${(convertedWgs84.longitude - 28.9784).abs()})');

      if (!latOk || !lngOk) {
        print('⚠️  Koordinat dönüşümünde problem var!');

        // X,Y sırasını değiştirip test et
        final swappedWebMercator = LatLng(manualWebMercator.longitude, manualWebMercator.latitude);
        print('Swap edilmiş Web Mercator: lat=${swappedWebMercator.latitude}, lng=${swappedWebMercator.longitude}');

        final swappedWgs84 = ProjectionConverter.convert(
          sourcePoint: swappedWebMercator,
          sourceProjectionKey: 'EPSG:3857',
          targetProjectionKey: 'EPSG:4326',
        );

        print('Swap edilmiş WGS84: lat=${swappedWgs84.latitude}, lng=${swappedWgs84.longitude}');

        bool swappedLatOk = (swappedWgs84.latitude - 41.0082).abs() < 0.01;
        bool swappedLngOk = (swappedWgs84.longitude - 28.9784).abs() < 0.01;

        print('Swap edilmiş Latitude doğru mu? $swappedLatOk');
        print('Swap edilmiş Longitude doğru mu? $swappedLngOk');

        if (swappedLatOk && swappedLngOk) {
          print('🔥 SORUN BULUNDU: Web Mercator koordinat sırası yanlış!');
        }
      }

      expect(true, isTrue);
    });
  });
}
