# Projection CS Flutter UI Test Uygulaması

Bu Flutter uygulaması, `projection_cs` paketinin tüm fonksiyonlarını interaktif olarak test etmenizi sağlar.

## Özellikler

### 🗺️ Harita Üzerinde Test

- Türkiye haritası üzerinde interaktif test
- Major şehirler (İstanbul, Ankara, İzmir, Gaziantep, Antalya) önceden işaretli
- Haritaya tıklayarak nokta seçimi

### 📐 Geometri Oluşturma

- **Point**: Tek nokta geometrisi
- **LineString**: Çizgi geometrisi (minimum 2 nokta)
- **Polygon**: Çokgen geometrisi (minimum 3 nokta)
- **MultiPoint**: Çoklu nokta geometrisi
- **MultiLineString**: Çoklu çizgi geometrisi
- **MultiPolygon**: Çoklu çokgen geometrisi

### 🔄 Projeksiyon Dönüşümleri

Desteklenen projeksiyon sistemleri:

- `EPSG:4326` (WGS84 - Lat/Lng)
- `EPSG:3857` (Web Mercator)
- `ITRF96_3DEG_TM30` (Türkiye)
- `ITRF96_3DEG_TM33` (Türkiye)
- `ITRF96_3DEG_TM36` (Türkiye)
- `ITRF96_3DEG_TM39` (Türkiye)
- `ITRF96_3DEG_TM42` (Türkiye)

### 🧮 Mekansal Analiz İşlemleri

#### Geometrik Dönüşümler

- **Buffer**: Geometri etrafında tampon oluşturma (5km)
- **Convex Hull**: Dış bükey zarf hesaplama
- **Centroid**: Merkez nokta bulma
- **Envelope**: Çevreleyen dikdörtgen (bounding box)
- **Simplify**: Douglas-Peucker algoritması ile basitleştirme

#### Overlay İşlemleri

- **Union**: İki geometrinin birleşimi
- **Intersection**: İki geometrinin kesişimi
- **Difference**: İki geometrinin farkı

#### Mekansal Sorgular

- **Intersects**: Kesişim testi
- **Contains**: İçerme testi
- **Distance**: Mesafe hesaplama
- **Area**: Alan hesaplama (km² ve m²)
- **Length**: Uzunluk hesaplama (km ve m)

#### Diğer İşlemler

- **Geometry Collection**: Karmaşık geometri koleksiyonu oluşturma
- **WKT Validation**: WKT formatı doğrulama
- **Geometry Type**: Geometri türü belirleme
- **Point Count**: Geometrideki nokta sayısı

## Kullanım

### 1. Uygulamayı Çalıştırma

```bash
cd example
flutter run flutter_ui_example.dart
```

### 2. Temel Kullanım

1. **İşlem Seçimi**: Üst panelden test etmek istediğiniz işlemi seçin
2. **Projeksiyon Ayarı**: Kaynak ve hedef projeksiyon sistemlerini belirleyin
3. **Nokta Seçimi**: Haritaya tıklayarak noktalar ekleyin
4. **Sonuç Görüntüleme**: Alt panelde detaylı sonuçları inceleyin

### 3. İki Geometri Gerektiren İşlemler

Union, Intersection, Difference gibi işlemler için:

1. İlk geometriyi oluşturun
2. "İkinci Geometri" butonuna tıklayın (son seçilen nokta etrafında otomatik kare oluşturur)
3. İstediğiniz overlay işlemini seçin

### 4. Projeksiyon Testi

1. Bir nokta seçin
2. "Projeksiyon Test" butonuna tıklayın
3. Dönüşüm hassasiyetini ve geri dönüş doğruluğunu inceleyin

## Görsel Göstergeler

### Renkler

- 🔴 **Kırmızı**: Şehir işaretleri ve LineString
- 🔵 **Mavi**: Seçilen noktalar ve Polygon
- 🟢 **Yeşil**: İkinci LineString (MultiLineString)
- 🟠 **Turuncu**: İkinci geometri (overlay işlemleri için)

### Harita Katmanları

- **Markers**: Nokta işaretleri
- **Polylines**: Çizgi geometrileri
- **Polygons**: Alan geometrileri
- **Circles**: Buffer sonuçları (gelecek versiyonda)

## Sonuç Paneli Bilgileri

Alt panelde şu bilgiler görüntülenir:

- **WKT String**: Oluşturulan geometrinin WKT formatı
- **Koordinatlar**: Seçilen noktaların koordinatları
- **Ölçümler**: Alan, uzunluk, mesafe değerleri
- **İstatistikler**: Nokta sayısı, geometri türü
- **Test Sonuçları**: Mekansal sorgu sonuçları

## Örnek Kullanım Senaryoları

### Senaryo 1: İstanbul-Ankara Arası Mesafe

1. İşlem: "Distance" seçin
2. İstanbul şehir işaretine tıklayın
3. Ankara şehir işaretine tıklayın
4. Sonuç: ~350 km mesafe görüntülenir

### Senaryo 2: Türkiye Grid Sistemi Testi

1. Projeksiyon: EPSG:4326 → ITRF96_3DEG_TM30
2. İşlem: "Point" seçin
3. İstanbul'a tıklayın
4. Sonuç: TM30 koordinatları görüntülenir

### Senaryo 3: Buffer Analizi

1. İşlem: "Point" seçin, bir nokta oluşturun
2. İşlem: "Buffer" seçin
3. Sonuç: 5km çapında tampon alan oluşturulur

### Senaryo 4: Çokgen Alan Hesabı

1. İşlem: "Polygon" seçin
2. Haritada 4-5 nokta ile bir alan çizin
3. İşlem: "Area" seçin
4. Sonuç: Alan km² ve m² cinsinden görüntülenir

## Hata Durumları

Uygulama şu durumlarda kullanıcıya rehberlik eder:

- Yetersiz nokta seçimi (örn: LineString için <2 nokta)
- Geçersiz WKT formatı
- Desteklenmeyen projeksiyon sistemi
- İki geometri gerektiren işlemler için eksik geometri

## Teknik Detaylar

- **Harita**: OpenStreetMap tile'ları
- **UI Framework**: Flutter Material Design 3
- **Harita Kütüphanesi**: flutter_map v6.2.1
- **Koordinat Sistemi**: latlong2 paketi

Bu uygulama, `projection_cs` paketinin tüm özelliklerini pratik ve görsel bir şekilde test etmenizi sağlar.
