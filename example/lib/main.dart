import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:projection_cs/projection_cs.dart';

void main() {
  runApp(const ProjectionTestApp());
}

class ProjectionTestApp extends StatelessWidget {
  const ProjectionTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Projection CS Test UI',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ProjectionTestScreen(),
    );
  }
}

class ProjectionTestScreen extends StatefulWidget {
  const ProjectionTestScreen({super.key});

  @override
  State<ProjectionTestScreen> createState() => _ProjectionTestScreenState();
}

class _ProjectionTestScreenState extends State<ProjectionTestScreen> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  final List<Polyline> _polylines = [];
  final List<Polygon> _polygons = [];
  final List<CircleMarker> _circles = [];

  String _resultText = 'Haritaya tıklayarak işlemleri test edin';
  String _selectedOperation = 'Point';
  String _sourceProjection = 'EPSG:4326';
  String _targetProjection = 'EPSG:3857';

  final List<LatLng> _selectedPoints = [];
  String? _currentWktGeometry;
  String? _secondWktGeometry;

  // Test için kullanılacak şehirler
  final List<LatLng> _turkishCities = [
    const LatLng(41.0082, 28.9784), // Istanbul
    const LatLng(39.9334, 32.8597), // Ankara
    const LatLng(38.4192, 27.1287), // Izmir
    const LatLng(37.0662, 37.3833), // Gaziantep
    const LatLng(36.8969, 30.7133), // Antalya
  ];

  final List<String> _operations = [
    'Point',
    'LineString',
    'Polygon',
    'MultiPoint',
    'MultiLineString',
    'MultiPolygon',
    'Buffer',
    'Convex Hull',
    'Centroid',
    'Envelope',
    'Union',
    'Intersection',
    'Difference',
    'Distance',
    'Area',
    'Length',
    'Simplify',
    'Intersects Test',
    'Contains Test',
    'Geometry Collection',
  ];

  final List<String> _projections = ['EPSG:4326', 'EPSG:3857', 'ITRF96_3DEG_TM30', 'ITRF96_3DEG_TM33', 'ITRF96_3DEG_TM36', 'ITRF96_3DEG_TM39', 'ITRF96_3DEG_TM42'];

  @override
  void initState() {
    super.initState();
    _addTurkishCityMarkers();
  }

  void _addTurkishCityMarkers() {
    final cityNames = ['Istanbul', 'Ankara', 'Izmir', 'Gaziantep', 'Antalya'];

    for (var i = 0; i < _turkishCities.length; i++) {
      _markers.add(
        Marker(
          point: _turkishCities[i],
          width: 80,
          height: 80,
          child: Column(
            children: [
              const Icon(Icons.location_city, color: Colors.red, size: 30),
              Text(
                cityNames[i],
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black, backgroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedPoints.add(point);

      // Add marker for selected point
      _markers.add(
        Marker(
          point: point,
          width: 40,
          height: 40,
          child: const Icon(Icons.place, color: Colors.blue, size: 30),
        ),
      );
    });

    _executeOperation();
  }

  void _executeOperation() {
    if (_selectedPoints.isEmpty) return;

    try {
      switch (_selectedOperation) {
        case 'Point':
          _testPoint();
        case 'LineString':
          _testLineString();
        case 'Polygon':
          _testPolygon();
        case 'MultiPoint':
          _testMultiPoint();
        case 'MultiLineString':
          _testMultiLineString();
        case 'MultiPolygon':
          _testMultiPolygon();
        case 'Buffer':
          _testBuffer();
        case 'Convex Hull':
          _testConvexHull();
        case 'Centroid':
          _testCentroid();
        case 'Envelope':
          _testEnvelope();
        case 'Union':
          _testUnion();
        case 'Intersection':
          _testIntersection();
        case 'Difference':
          _testDifference();
        case 'Distance':
          _testDistance();
        case 'Area':
          _testArea();
        case 'Length':
          _testLength();
        case 'Simplify':
          _testSimplify();
        case 'Intersects Test':
          _testIntersects();
        case 'Contains Test':
          _testContains();
        case 'Geometry Collection':
          _testGeometryCollection();
      }
    } catch (e) {
      setState(() {
        _resultText = 'Hata: $e';
      });
    }
  }

  void _testPoint() {
    if (_selectedPoints.isNotEmpty) {
      final wkt = WktGenerator.createPoint(coordinates: [_selectedPoints.last], sourceProjectionKey: _sourceProjection, targetProjectionKey: _targetProjection);

      _currentWktGeometry = wkt;

      setState(() {
        _resultText =
            'Point WKT: $wkt\n\n'
            'Koordinat: ${_selectedPoints.last.latitude.toStringAsFixed(6)}, '
            '${_selectedPoints.last.longitude.toStringAsFixed(6)}\n'
            'Kaynak: $_sourceProjection -> Hedef: $_targetProjection';
      });
    }
  }

  void _testLineString() {
    if (_selectedPoints.length >= 2) {
      final wkt = WktGenerator.createLineString(coordinates: _selectedPoints, sourceProjectionKey: _sourceProjection, targetProjectionKey: _targetProjection);

      _currentWktGeometry = wkt;

      // Add polyline to map
      _polylines
        ..clear()
        ..add(Polyline(points: _selectedPoints, color: Colors.red, strokeWidth: 3));

      final length = WktGenerator.getLength(wktGeometry: wkt);

      setState(() {
        _resultText =
            'LineString WKT: ${wkt.substring(0, 100)}...\n\n'
            'Nokta sayısı: ${_selectedPoints.length}\n'
            'Uzunluk: ${(length / 1000).toStringAsFixed(2)} km\n'
            'Kaynak: $_sourceProjection -> Hedef: $_targetProjection';
      });
    } else {
      setState(() {
        _resultText = 'LineString için en az 2 nokta seçin (Şu an: ${_selectedPoints.length})';
      });
    }
  }

  void _testPolygon() {
    if (_selectedPoints.length >= 3) {
      final wkt = WktGenerator.createPolygon(coordinates: _selectedPoints, sourceProjectionKey: _sourceProjection, targetProjectionKey: _targetProjection);

      _currentWktGeometry = wkt;

      // Add polygon to map
      _polygons
        ..clear()
        ..add(Polygon(points: _selectedPoints, color: Colors.blue.withValues(alpha: 0.3), borderColor: Colors.blue, borderStrokeWidth: 2));

      final area = WktGenerator.getArea(wktGeometry: wkt);

      setState(() {
        _resultText =
            'Polygon WKT: ${wkt.substring(0, 100)}...\n\n'
            'Nokta sayısı: ${_selectedPoints.length}\n'
            'Alan: ${(area / 1000000).toStringAsFixed(2)} km²\n'
            'Kaynak: $_sourceProjection -> Hedef: $_targetProjection';
      });
    } else {
      setState(() {
        _resultText = 'Polygon için en az 3 nokta seçin (Şu an: ${_selectedPoints.length})';
      });
    }
  }

  void _testMultiPoint() {
    if (_selectedPoints.isNotEmpty) {
      final wkt = WktGenerator.createMultiPoint(coordinates: _selectedPoints, sourceProjectionKey: _sourceProjection, targetProjectionKey: _targetProjection);

      _currentWktGeometry = wkt;

      setState(() {
        _resultText =
            'MultiPoint WKT: ${wkt.substring(0, 100)}...\n\n'
            'Nokta sayısı: ${_selectedPoints.length}\n'
            'Kaynak: $_sourceProjection -> Hedef: $_targetProjection';
      });
    }
  }

  void _testMultiLineString() {
    if (_selectedPoints.length >= 4) {
      // İlk yarısı bir linestring, ikinci yarısı başka bir linestring
      final mid = _selectedPoints.length ~/ 2;
      final line1 = _selectedPoints.sublist(0, mid);
      final line2 = _selectedPoints.sublist(mid);

      final wkt = WktGenerator.createMultiLineString(coordinateLists: [line1, line2], sourceProjectionKey: _sourceProjection, targetProjectionKey: _targetProjection);

      _currentWktGeometry = wkt;

      // Add multiple polylines to map
      _polylines
        ..clear()
        ..add(Polyline(points: line1, color: Colors.red, strokeWidth: 3))
        ..add(Polyline(points: line2, color: Colors.green, strokeWidth: 3));

      setState(() {
        _resultText =
            'MultiLineString WKT: ${wkt.substring(0, 100)}...\n\n'
            'Line 1 nokta sayısı: ${line1.length}\n'
            'Line 2 nokta sayısı: ${line2.length}\n'
            'Kaynak: $_sourceProjection -> Hedef: $_targetProjection';
      });
    } else {
      setState(() {
        _resultText = 'MultiLineString için en az 4 nokta seçin (Şu an: ${_selectedPoints.length})';
      });
    }
  }

  void _testMultiPolygon() {
    if (_selectedPoints.length >= 6) {
      // İlk yarısı bir polygon, ikinci yarısı başka bir polygon
      final mid = _selectedPoints.length ~/ 2;
      final poly1 = _selectedPoints.sublist(0, mid);
      final poly2 = _selectedPoints.sublist(mid);

      final wkt = WktGenerator.createMultiPolygon(coordinateLists: [poly1, poly2], sourceProjectionKey: _sourceProjection, targetProjectionKey: _targetProjection);

      _currentWktGeometry = wkt;

      // Add multiple polygons to map
      _polygons
        ..clear()
        ..add(Polygon(points: poly1, color: Colors.blue.withValues(alpha: 0.3), borderColor: Colors.blue, borderStrokeWidth: 2))
        ..add(Polygon(points: poly2, color: Colors.red.withValues(alpha: 0.3), borderColor: Colors.red, borderStrokeWidth: 2));

      setState(() {
        _resultText =
            'MultiPolygon WKT: ${wkt.substring(0, 100)}...\n\n'
            'Polygon 1 nokta sayısı: ${poly1.length}\n'
            'Polygon 2 nokta sayısı: ${poly2.length}\n'
            'Kaynak: $_sourceProjection -> Hedef: $_targetProjection';
      });
    } else {
      setState(() {
        _resultText = 'MultiPolygon için en az 6 nokta seçin (Şu an: ${_selectedPoints.length})';
      });
    }
  }

  void _testBuffer() {
    if (_currentWktGeometry != null) {
      final bufferWkt = WktGenerator.buffer(
        wktGeometry: _currentWktGeometry!,
        distance: 5000, // 5km
      );

      setState(() {
        _resultText =
            'Buffer (5km) WKT: ${bufferWkt.substring(0, 100)}...\n\n'
            'Orijinal geometri etrafında 5km buffer oluşturuldu.\n'
            'Buffer alanı: ${(WktGenerator.getArea(wktGeometry: bufferWkt) / 1000000).toStringAsFixed(2)} km²';
      });
    } else {
      setState(() {
        _resultText = 'Buffer için önce bir geometri oluşturun';
      });
    }
  }

  void _testConvexHull() {
    if (_selectedPoints.length >= 3) {
      final wkt = WktGenerator.createMultiPoint(coordinates: _selectedPoints, sourceProjectionKey: _sourceProjection, targetProjectionKey: _targetProjection);

      final convexHullWkt = WktGenerator.convexHull(wktGeometry: wkt);

      setState(() {
        _resultText =
            'Convex Hull WKT: ${convexHullWkt.substring(0, 100)}...\n\n'
            "Seçilen ${_selectedPoints.length} noktanın convex hull'u hesaplandı";
      });
    } else {
      setState(() {
        _resultText = 'Convex Hull için en az 3 nokta seçin';
      });
    }
  }

  void _testCentroid() {
    if (_currentWktGeometry != null) {
      final centroidWkt = WktGenerator.centroid(wktGeometry: _currentWktGeometry!);

      setState(() {
        _resultText =
            'Centroid WKT: $centroidWkt\n\n'
            'Geometrinin merkez noktası hesaplandı';
      });
    } else {
      setState(() {
        _resultText = 'Centroid için önce bir geometri oluşturun';
      });
    }
  }

  void _testEnvelope() {
    if (_currentWktGeometry != null) {
      final envelopeWkt = WktGenerator.envelope(wktGeometry: _currentWktGeometry!);

      setState(() {
        _resultText =
            'Envelope (Bounding Box) WKT: ${envelopeWkt.substring(0, 100)}...\n\n'
            'Geometriyi çevreleyen minimum dikdörtgen hesaplandı';
      });
    } else {
      setState(() {
        _resultText = 'Envelope için önce bir geometri oluşturun';
      });
    }
  }

  void _testUnion() {
    if (_currentWktGeometry != null && _secondWktGeometry != null) {
      final unionWkt = WktGenerator.union(wktGeometry1: _currentWktGeometry!, wktGeometry2: _secondWktGeometry!);

      setState(() {
        _resultText =
            'Union WKT: ${unionWkt.substring(0, 100)}...\n\n'
            'İki geometrinin birleşimi hesaplandı';
      });
    } else {
      setState(() {
        _resultText = 'Union için iki geometri gerekli. İkinci geometri için "İkinci Geometri Oluştur" butonunu kullanın';
      });
    }
  }

  void _testIntersection() {
    if (_currentWktGeometry != null && _secondWktGeometry != null) {
      final intersectionWkt = WktGenerator.intersection(wktGeometry1: _currentWktGeometry!, wktGeometry2: _secondWktGeometry!);

      setState(() {
        _resultText =
            'Intersection WKT: ${intersectionWkt.substring(0, 100)}...\n\n'
            'İki geometrinin kesişimi hesaplandı';
      });
    } else {
      setState(() {
        _resultText = 'Intersection için iki geometri gerekli';
      });
    }
  }

  void _testDifference() {
    if (_currentWktGeometry != null && _secondWktGeometry != null) {
      final differenceWkt = WktGenerator.difference(wktGeometry1: _currentWktGeometry!, wktGeometry2: _secondWktGeometry!);

      setState(() {
        _resultText =
            'Difference WKT: ${differenceWkt.substring(0, 100)}...\n\n'
            'İki geometrinin farkı hesaplandı';
      });
    } else {
      setState(() {
        _resultText = 'Difference için iki geometri gerekli';
      });
    }
  }

  void _testDistance() {
    if (_selectedPoints.length >= 2) {
      final point1Wkt = WktGenerator.createPoint(coordinates: [_selectedPoints.first], sourceProjectionKey: _sourceProjection, targetProjectionKey: _targetProjection);

      final point2Wkt = WktGenerator.createPoint(coordinates: [_selectedPoints.last], sourceProjectionKey: _sourceProjection, targetProjectionKey: _targetProjection);

      final distance = WktGenerator.distance(wktGeometry1: point1Wkt, wktGeometry2: point2Wkt);

      setState(() {
        _resultText =
            'Mesafe: ${(distance / 1000).toStringAsFixed(2)} km\n\n'
            'İlk nokta: ${_selectedPoints.first.latitude.toStringAsFixed(6)}, '
            '${_selectedPoints.first.longitude.toStringAsFixed(6)}\n'
            'Son nokta: ${_selectedPoints.last.latitude.toStringAsFixed(6)}, '
            '${_selectedPoints.last.longitude.toStringAsFixed(6)}';
      });
    } else {
      setState(() {
        _resultText = 'Mesafe hesabı için en az 2 nokta seçin';
      });
    }
  }

  void _testArea() {
    if (_currentWktGeometry != null) {
      final area = WktGenerator.getArea(wktGeometry: _currentWktGeometry!);

      setState(() {
        _resultText =
            'Alan: ${(area / 1000000).toStringAsFixed(2)} km²\n'
            'Alan: ${area.toStringAsFixed(2)} m²\n\n'
            'Geometri türü: ${WktGenerator.getGeometryType(wktGeometry: _currentWktGeometry!)}';
      });
    } else {
      setState(() {
        _resultText = 'Alan hesabı için önce bir geometri oluşturun';
      });
    }
  }

  void _testLength() {
    if (_currentWktGeometry != null) {
      final length = WktGenerator.getLength(wktGeometry: _currentWktGeometry!);

      setState(() {
        _resultText =
            'Uzunluk: ${(length / 1000).toStringAsFixed(2)} km\n'
            'Uzunluk: ${length.toStringAsFixed(2)} m\n\n'
            'Geometri türü: ${WktGenerator.getGeometryType(wktGeometry: _currentWktGeometry!)}';
      });
    } else {
      setState(() {
        _resultText = 'Uzunluk hesabı için önce bir geometri oluşturun';
      });
    }
  }

  void _testSimplify() {
    if (_currentWktGeometry != null) {
      final originalPoints = WktGenerator.getNumPoints(wktGeometry: _currentWktGeometry!);

      final simplifiedWkt = WktGenerator.simplify(
        wktGeometry: _currentWktGeometry!,
        tolerance: 1000, // 1km tolerance
      );

      final simplifiedPoints = WktGenerator.getNumPoints(wktGeometry: simplifiedWkt);

      setState(() {
        _resultText =
            'Simplify (1km tolerance):\n\n'
            'Orijinal nokta sayısı: $originalPoints\n'
            'Basitleştirilmiş nokta sayısı: $simplifiedPoints\n'
            'Azaltılan nokta: ${originalPoints - simplifiedPoints}\n\n'
            'Simplified WKT: ${simplifiedWkt.substring(0, 100)}...';
      });
    } else {
      setState(() {
        _resultText = 'Simplify için önce bir geometri oluşturun';
      });
    }
  }

  void _testIntersects() {
    if (_currentWktGeometry != null && _secondWktGeometry != null) {
      final intersects = WktGenerator.intersects(wktGeometry1: _currentWktGeometry!, wktGeometry2: _secondWktGeometry!);

      setState(() {
        _resultText =
            'Intersects Test: ${intersects ? "Geometriler kesişiyor" : "Geometriler kesişmiyor"}\n\n'
            'Geometri 1: ${WktGenerator.getGeometryType(wktGeometry: _currentWktGeometry!)}\n'
            'Geometri 2: ${WktGenerator.getGeometryType(wktGeometry: _secondWktGeometry!)}';
      });
    } else {
      setState(() {
        _resultText = 'Intersects test için iki geometri gerekli';
      });
    }
  }

  void _testContains() {
    if (_currentWktGeometry != null && _secondWktGeometry != null) {
      final contains = WktGenerator.contains(wktGeometry1: _currentWktGeometry!, wktGeometry2: _secondWktGeometry!);

      setState(() {
        _resultText =
            'Contains Test: ${contains ? "İlk geometri ikincisini içeriyor" : "İlk geometri ikincisini içermiyor"}\n\n'
            'Geometri 1: ${WktGenerator.getGeometryType(wktGeometry: _currentWktGeometry!)}\n'
            'Geometri 2: ${WktGenerator.getGeometryType(wktGeometry: _secondWktGeometry!)}';
      });
    } else {
      setState(() {
        _resultText = 'Contains test için iki geometri gerekli';
      });
    }
  }

  void _testGeometryCollection() {
    if (_selectedPoints.length >= 3) {
      final pointWkt = WktGenerator.createPoint(coordinates: [_selectedPoints.first], sourceProjectionKey: _sourceProjection, targetProjectionKey: _targetProjection);

      final lineWkt = WktGenerator.createLineString(coordinates: _selectedPoints.take(2).toList(), sourceProjectionKey: _sourceProjection, targetProjectionKey: _targetProjection);

      final polygonWkt = WktGenerator.createPolygon(coordinates: _selectedPoints, sourceProjectionKey: _sourceProjection, targetProjectionKey: _targetProjection);

      final collectionWkt = WktGenerator.createGeometryCollection(wktGeometries: [pointWkt, lineWkt, polygonWkt]);

      setState(() {
        _resultText =
            'Geometry Collection WKT: ${collectionWkt.substring(0, 150)}...\n\n'
            'Koleksiyon içeriği:\n'
            '- 1 Point\n'
            '- 1 LineString\n'
            '- 1 Polygon\n\n'
            'Toplam nokta sayısı: ${WktGenerator.getNumPoints(wktGeometry: collectionWkt)}';
      });
    } else {
      setState(() {
        _resultText = 'Geometry Collection için en az 3 nokta seçin';
      });
    }
  }

  void _createSecondGeometry() {
    if (_selectedPoints.length >= 2) {
      // Son seçilen nokta etrafında küçük bir polygon oluştur
      final center = _selectedPoints.last;
      const offset = 0.01; // ~1km

      final squarePoints = [
        LatLng(center.latitude - offset, center.longitude - offset),
        LatLng(center.latitude - offset, center.longitude + offset),
        LatLng(center.latitude + offset, center.longitude + offset),
        LatLng(center.latitude + offset, center.longitude - offset),
      ];

      _secondWktGeometry = WktGenerator.createPolygon(coordinates: squarePoints, sourceProjectionKey: _sourceProjection, targetProjectionKey: _targetProjection);

      // Add visual representation
      _polygons.add(Polygon(points: squarePoints, color: Colors.orange.withValues(alpha: 0.3), borderColor: Colors.orange, borderStrokeWidth: 2));

      setState(() {
        _resultText =
            'İkinci geometri oluşturuldu (turuncu kare)\n\n'
            'Geometri türü: ${WktGenerator.getGeometryType(wktGeometry: _secondWktGeometry!)}\n'
            'Artık iki geometri işlemlerini (Union, Intersection, vb.) test edebilirsiniz';
      });
    } else {
      setState(() {
        _resultText = 'İkinci geometri için en az 2 nokta seçin';
      });
    }
  }

  void _clearAll() {
    setState(() {
      _markers.clear();
      _polylines.clear();
      _polygons.clear();
      _circles.clear();
      _selectedPoints.clear();
      _currentWktGeometry = null;
      _secondWktGeometry = null;
      _resultText = 'Temizlendi. Haritaya tıklayarak yeni işlemler başlatın';
    });
    _addTurkishCityMarkers();
  }

  void _testProjectionConversion() {
    if (_selectedPoints.isNotEmpty) {
      final originalPoint = _selectedPoints.last;

      try {
        final convertedPoint = ProjectionConverter.convert(sourcePoint: originalPoint, sourceProjectionKey: _sourceProjection, targetProjectionKey: _targetProjection);

        final convertedBackPoint = ProjectionConverter.convert(sourcePoint: convertedPoint, sourceProjectionKey: _targetProjection, targetProjectionKey: _sourceProjection);

        setState(() {
          _resultText =
              'Projeksiyon Dönüşümü Test:\n\n'
              'Orijinal ($_sourceProjection):\n'
              'Lat: ${originalPoint.latitude.toStringAsFixed(8)}\n'
              'Lng: ${originalPoint.longitude.toStringAsFixed(8)}\n\n'
              'Dönüştürülmüş ($_targetProjection):\n'
              'X: ${convertedPoint.longitude.toStringAsFixed(2)}\n'
              'Y: ${convertedPoint.latitude.toStringAsFixed(2)}\n\n'
              'Geri Dönüştürülmüş ($_sourceProjection):\n'
              'Lat: ${convertedBackPoint.latitude.toStringAsFixed(8)}\n'
              'Lng: ${convertedBackPoint.longitude.toStringAsFixed(8)}\n\n'
              'Hassasiyet Kaybı:\n'
              'Lat farkı: ${(originalPoint.latitude - convertedBackPoint.latitude).abs().toStringAsFixed(10)}\n'
              'Lng farkı: ${(originalPoint.longitude - convertedBackPoint.longitude).abs().toStringAsFixed(10)}';
        });
      } catch (e) {
        setState(() {
          _resultText = 'Projeksiyon dönüşüm hatası: $e';
        });
      }
    } else {
      setState(() {
        _resultText = 'Projeksiyon testi için bir nokta seçin';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projection CS Test UI'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: Column(
        children: [
          // Controls Panel
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedOperation,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedOperation = newValue!;
                          });
                        },
                        items: _operations.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontSize: 12)),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _sourceProjection,
                        onChanged: (String? newValue) {
                          setState(() {
                            _sourceProjection = newValue!;
                          });
                        },
                        items: _projections.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontSize: 10)),
                          );
                        }).toList(),
                      ),
                    ),
                    const Icon(Icons.arrow_forward, size: 16),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _targetProjection,
                        onChanged: (String? newValue) {
                          setState(() {
                            _targetProjection = newValue!;
                          });
                        },
                        items: _projections.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontSize: 10)),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _clearAll,
                        child: const Text('Temizle', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _createSecondGeometry,
                        child: const Text('İkinci Geometri', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _testProjectionConversion,
                        child: const Text('Projeksiyon Test', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Map
          Expanded(
            flex: 2,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(39.9334, 32.8597), // Ankara
                initialZoom: 6,
                onTap: _onMapTap,
              ),
              children: [
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.projection_cs'),
                MarkerLayer(markers: _markers),
                PolylineLayer(polylines: _polylines),
                PolygonLayer(polygons: _polygons),
                CircleLayer(circles: _circles),
              ],
            ),
          ),

          // Results Panel
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              color: Colors.grey[50],
              child: SingleChildScrollView(
                child: Text(_resultText, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
