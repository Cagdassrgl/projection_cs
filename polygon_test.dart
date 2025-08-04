import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:projection_cs/projection_cs.dart';

void main() {
  group('Turkey Polygon Problem Analysis', () {
    test('Turkey polygon EPSG:3857 to EPSG:4326 conversion issue', () {
      print('=== Türkiye Polygon EPSG:3857 -> EPSG:4326 Dönüşüm Sorunu ===');

      // Türkiye sınırlarından örnek koordinatlar (EPSG:3857 Web Mercator formatında)
      // Bu koordinatlar gerçek bir WKT string'den alınmış olabilir
      final turkeyPolygonWebMercator = [
        LatLng(5013551.0, 3225860.0), // İstanbul civarı
        LatLng(4980000.0, 3800000.0), // Ankara civarı
        LatLng(4500000.0, 4200000.0), // Doğu Anadolu
        LatLng(4300000.0, 3500000.0), // Güney batı
        LatLng(4800000.0, 2900000.0), // Batı sahil
      ];

      print('Web Mercator koordinatları (EPSG:3857):');
      for (int i = 0; i < turkeyPolygonWebMercator.length; i++) {
        final point = turkeyPolygonWebMercator[i];
        print('  Point ${i + 1}: lat=${point.latitude}, lng=${point.longitude}');
      }

      // EPSG:3857'den EPSG:4326'ya dönüştür
      final turkeyPolygonWgs84 = turkeyPolygonWebMercator
          .map((point) => ProjectionConverter.convert(
                sourcePoint: point,
                sourceProjectionKey: 'EPSG:3857',
                targetProjectionKey: 'EPSG:4326',
              ))
          .toList();

      print('\nWGS84 koordinatları (EPSG:4326):');
      bool allInTurkey = true;
      bool anyInIraq = false;

      for (int i = 0; i < turkeyPolygonWgs84.length; i++) {
        final point = turkeyPolygonWgs84[i];
        print('  Point ${i + 1}: lat=${point.latitude}, lng=${point.longitude}');

        // Türkiye sınırları: lat=35.8-42.1, lng=25.6-44.8
        bool inTurkey = point.latitude >= 35.8 && point.latitude <= 42.1 && point.longitude >= 25.6 && point.longitude <= 44.8;

        // Irak sınırları: lat=29.0-37.4, lng=38.8-48.6
        bool inIraq = point.latitude >= 29.0 && point.latitude <= 37.4 && point.longitude >= 38.8 && point.longitude <= 48.6;

        print('    Türkiye\'de: $inTurkey, Irak\'ta: $inIraq');

        if (!inTurkey) allInTurkey = false;
        if (inIraq) anyInIraq = true;
      }

      print('\nSONUÇ ANALİZİ:');
      print('Tüm koordinatlar Türkiye\'de mi? $allInTurkey');
      print('Herhangi bir koordinat Irak\'ta mı? $anyInIraq');

      if (anyInIraq || !allInTurkey) {
        print('\n🔥 PROBLEM BULUNDU: Türkiye polygon\'u Irak tarafında görünüyor!');
        print('Bu koordinat dönüşümü sorunundan kaynaklanıyor olabilir.');

        // Test için koordinatları ters çevirip dönüştürme deneyelim
        print('\n=== Alternatif Test: X,Y Sırasını Değiştirerek ===');

        final alternativeWgs84 = turkeyPolygonWebMercator.map((point) {
          // X,Y sırasını değiştir: LatLng(y, x) -> LatLng(x, y)
          final swappedPoint = LatLng(point.longitude, point.latitude);
          return ProjectionConverter.convert(
            sourcePoint: swappedPoint,
            sourceProjectionKey: 'EPSG:3857',
            targetProjectionKey: 'EPSG:4326',
          );
        }).toList();

        print('X,Y değiştirilmiş WGS84 koordinatları:');
        bool altAllInTurkey = true;
        bool altAnyInIraq = false;

        for (int i = 0; i < alternativeWgs84.length; i++) {
          final point = alternativeWgs84[i];
          print('  Point ${i + 1}: lat=${point.latitude}, lng=${point.longitude}');

          bool inTurkey = point.latitude >= 35.8 && point.latitude <= 42.1 && point.longitude >= 25.6 && point.longitude <= 44.8;

          bool inIraq = point.latitude >= 29.0 && point.latitude <= 37.4 && point.longitude >= 38.8 && point.longitude <= 48.6;

          print('    Türkiye\'de: $inTurkey, Irak\'ta: $inIraq');

          if (!inTurkey) altAllInTurkey = false;
          if (inIraq) altAnyInIraq = true;
        }

        print('\nALTERNATİF SONUÇ:');
        print('X,Y değiştirilmiş - Tüm koordinatlar Türkiye\'de mi? $altAllInTurkey');
        print('X,Y değiştirilmiş - Herhangi bir koordinat Irak\'ta mı? $altAnyInIraq');

        if (altAllInTurkey && !altAnyInIraq) {
          print('\n💡 ÇÖZÜM BULUNDU: X,Y sırasını değiştirmek sorunu çözüyor!');
          print('EPSG:3857 koordinat sistemi yorumlama hatası var.');
        }
      } else {
        print('\n✅ Koordinat dönüşümü doğru çalışıyor.');
      }

      expect(true, isTrue); // Test her zaman geçsin, sadece analiz için
    });
  });
}
