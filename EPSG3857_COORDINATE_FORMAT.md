# EPSG:3857 Koordinat Giriş Formatı - Önemli Bilgi

## Problem

EPSG:3857 (Web Mercator) koordinat sisteminden EPSG:4326 (WGS84) koordinat sistemine dönüştürürken Türkiye sınırlarındaki polygon'ların Irak tarafında görünmesi sorunu.

## Çözüm

EPSG:3857 koordinatlarını `LatLng` formatında girerken doğru sıralamayı kullanın:

### ✅ DOĞRU Format:

```dart
// Web Mercator koordinatları: X=3225860, Y=5013551 (İstanbul)
final webMercatorPoint = LatLng(5013551.0, 3225860.0); // LatLng(Y, X)

final wgs84Point = ProjectionConverter.convert(
  sourcePoint: webMercatorPoint,
  sourceProjectionKey: 'EPSG:3857',
  targetProjectionKey: 'EPSG:4326',
);
```

### ❌ YANLIŞ Format:

```dart
// Bu format koordinat kaymasına neden olur!
final wrongPoint = LatLng(3225860.0, 5013551.0); // LatLng(X, Y) - YANLIŞ!
```

## Açıklama

- **EPSG:3857 Web Mercator** projected bir koordinat sistemidir
- Koordinatlar **X (easting)** ve **Y (northing)** değerleridir
- `LatLng` constructor'ı `LatLng(latitude, longitude)` formatını bekler
- Web Mercator için: `LatLng(Y_northing, X_easting)` formatı kullanılmalıdır

## Koordinat Sistemleri

### EPSG:3857 (Web Mercator)

- X = Easting (doğu-batı yönü, metre)
- Y = Northing (kuzey-güney yönü, metre)
- Projeksiyon sistemi

### EPSG:4326 (WGS84)

- Longitude = Boylam (doğu-batı yönü, derece)
- Latitude = Enlem (kuzey-güney yönü, derece)
- Coğrafi koordinat sistemi

## İstanbul Örneği

```dart
// İstanbul Web Mercator koordinatları
final istanbulX = 3225860.0; // Easting
final istanbulY = 5013551.0; // Northing

// Doğru format
final webMercator = LatLng(istanbulY, istanbulX); // LatLng(5013551.0, 3225860.0)

// Dönüştür
final wgs84 = ProjectionConverter.convert(
  sourcePoint: webMercator,
  sourceProjectionKey: 'EPSG:3857',
  targetProjectionKey: 'EPSG:4326',
);

print('WGS84: ${wgs84.latitude}, ${wgs84.longitude}');
// Sonuç: WGS84: 41.0082, 28.9784 (İstanbul)
```
