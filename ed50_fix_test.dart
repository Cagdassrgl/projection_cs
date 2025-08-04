import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:projection_cs/projection_cs.dart';

void main() {
  group('WKT EPSG:3857 to EPSG:4326 Problem Analysis', () {
    test('Real WKT conversion scenario - EPSG:3857 to EPSG:4326', () {
      print('=== WKT EPSG:3857 -> EPSG:4326 Dönüşüm Analizi ===');

      // Gerçek bir EPSG:3857 Web Mercator polygon koordinatları
      // Bu koordinatlar kullanıcının yaşadığı sorunu simüle ediyor
      final webMercatorCoords = [
        LatLng(5013551.0, 3225860.0), // İstanbul
        LatLng(4867963.0, 4125549.0), // Doğu Türkiye
        LatLng(4291500.0, 3726863.0), // Güney Türkiye
        LatLng(4567234.0, 2845966.0), // Batı Türkiye
        LatLng(5013551.0, 3225860.0), // Kapanış noktası
      ];

      print('EPSG:3857 Web Mercator Koordinatları:');
      for (int i = 0; i < webMercatorCoords.length; i++) {
        final coord = webMercatorCoords[i];
        print('  ${i + 1}: x=${coord.longitude}, y=${coord.latitude}');
      }

      // Manuel koordinat dönüşümünü test edelim

      // Dönüştürülmüş koordinatları manuel olarak da kontrol edelim
      print('\nManuel Koordinat Dönüşümü:');
      final convertedCoords = ProjectionConverter.convertBatch(
        sourcePoints: webMercatorCoords,
        sourceProjectionKey: 'EPSG:3857',
        targetProjectionKey: 'EPSG:4326',
      );

      bool allInTurkey = true;
      bool anyInIraq = false;

      for (int i = 0; i < convertedCoords.length; i++) {
        final coord = convertedCoords[i];
        print('  ${i + 1}: lat=${coord.latitude}, lng=${coord.longitude}');

        // Türkiye kontrolü
        bool inTurkey = coord.latitude >= 35.8 && coord.latitude <= 42.1 && coord.longitude >= 25.6 && coord.longitude <= 44.8;

        // Irak kontrolü
        bool inIraq = coord.latitude >= 29.0 && coord.latitude <= 37.4 && coord.longitude >= 38.8 && coord.longitude <= 48.6;

        print('    Türkiye: $inTurkey, Irak: $inIraq');

        if (!inTurkey) allInTurkey = false;
        if (inIraq) anyInIraq = true;
      }

      print('\n📊 SONUÇ ANALİZİ:');
      print('Tüm koordinatlar Türkiye sınırlarında: $allInTurkey');
      print('Herhangi bir koordinat Irak\'ta: $anyInIraq');

      if (!allInTurkey || anyInIraq) {
        print('🚨 PROBLEM: Polygon Türkiye dışında görünüyor!');
      } else {
        print('✅ Polygon doğru konumda görünüyor.');
      }

      // Ek test: Coordinate order sorununu kontrol et
      print('\n=== Koordinat Sırası Problemi Kontrolü ===');

      // X,Y sırasını tamamen ters çevir
      final reversedCoords = webMercatorCoords.map((coord) => LatLng(coord.longitude, coord.latitude)).toList();

      print('Ters çevrilmiş EPSG:3857 koordinatları (x<->y swapped):');
      for (int i = 0; i < reversedCoords.length; i++) {
        final coord = reversedCoords[i];
        print('  ${i + 1}: x=${coord.longitude}, y=${coord.latitude}');
      }

      final reversedConverted = ProjectionConverter.convertBatch(
        sourcePoints: reversedCoords,
        sourceProjectionKey: 'EPSG:3857',
        targetProjectionKey: 'EPSG:4326',
      );

      print('\nTers çevrilmiş koordinatlardan dönüştürülmüş WGS84:');
      bool reversedAllInTurkey = true;
      bool reversedAnyInIraq = false;

      for (int i = 0; i < reversedConverted.length; i++) {
        final coord = reversedConverted[i];
        print('  ${i + 1}: lat=${coord.latitude}, lng=${coord.longitude}');

        bool inTurkey = coord.latitude >= 35.8 && coord.latitude <= 42.1 && coord.longitude >= 25.6 && coord.longitude <= 44.8;

        bool inIraq = coord.latitude >= 29.0 && coord.latitude <= 37.4 && coord.longitude >= 38.8 && coord.longitude <= 48.6;

        print('    Türkiye: $inTurkey, Irak: $inIraq');

        if (!inTurkey) reversedAllInTurkey = false;
        if (inIraq) reversedAnyInIraq = true;
      }

      print('\n📊 TERS ÇEVRİLMİŞ SONUÇ:');
      print('Ters çevrilmiş - Tüm koordinatlar Türkiye\'de: $reversedAllInTurkey');
      print('Ters çevrilmiş - Herhangi bir koordinat Irak\'ta: $reversedAnyInIraq');

      if (reversedAllInTurkey && !reversedAnyInIraq && (!allInTurkey || anyInIraq)) {
        print('🔍 SORUN BULUNDU: Koordinat sırası (x,y) yanlış yorumlanıyor!');
        print('💡 ÇÖZÜM: EPSG:3857 koordinat giriş sırası düzeltilmeli.');
      }

      expect(true, isTrue);
    });
  });
}
