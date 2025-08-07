import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:projection_cs/projection_cs.dart';

void main() {
  group('ProjectionConverter Tests', () {
    test('should convert WGS84 to Web Mercator correctly', () {
      const wgs84Point = LatLng(41.0082, 28.9784); // Istanbul coordinates

      final webMercatorPoint = ProjectionConverter.convert(
        sourcePoint: wgs84Point,
        sourceProjectionKey: 'EPSG:4326',
        targetProjectionKey: 'EPSG:3857',
      );

      // Web Mercator coordinates should be significantly larger numbers
      expect(webMercatorPoint.latitude.abs(), greaterThan(1000000));
      expect(webMercatorPoint.longitude.abs(), greaterThan(1000000));
    });

    test('should convert batch of coordinates correctly', () {
      const wgs84Points = [
        LatLng(41.0082, 28.9784), // Istanbul
        LatLng(39.9334, 32.8597), // Ankara
      ];

      final webMercatorPoints = ProjectionConverter.convertBatch(
        sourcePoints: wgs84Points,
        sourceProjectionKey: 'EPSG:4326',
        targetProjectionKey: 'EPSG:3857',
      );

      expect(webMercatorPoints.length, equals(2));
      expect(webMercatorPoints[0].latitude.abs(), greaterThan(1000000));
      expect(webMercatorPoints[1].latitude.abs(), greaterThan(1000000));
    });

    test('should throw ProjectionException for invalid projection key', () {
      const point = LatLng(41.0082, 28.9784);

      expect(
        () => ProjectionConverter.convert(
          sourcePoint: point,
          sourceProjectionKey: 'INVALID:PROJECTION',
          targetProjectionKey: 'EPSG:4326',
        ),
        throwsA(isA<ProjectionException>()),
      );
    });

    test('should throw ProjectionException for unsupported source projection', () {
      const point = LatLng(41.0082, 28.9784);

      expect(
        () => ProjectionConverter.convert(
          sourcePoint: point,
          sourceProjectionKey: 'UNSUPPORTED:SOURCE',
          targetProjectionKey: 'EPSG:4326',
        ),
        throwsA(isA<ProjectionException>()),
      );
    });

    test('should throw ProjectionException for unsupported target projection', () {
      const point = LatLng(41.0082, 28.9784);

      expect(
        () => ProjectionConverter.convert(
          sourcePoint: point,
          sourceProjectionKey: 'EPSG:4326',
          targetProjectionKey: 'UNSUPPORTED:TARGET',
        ),
        throwsA(isA<ProjectionException>()),
      );
    });

    test('should handle different coordinate order for EPSG:4326', () {
      const wgs84Point = LatLng(41.0082, 28.9784); // Istanbul in WGS84

      // Convert to Web Mercator and back to test coordinate order handling
      final webMercatorPoint = ProjectionConverter.convert(
        sourcePoint: wgs84Point,
        sourceProjectionKey: 'EPSG:4326',
        targetProjectionKey: 'EPSG:3857',
      );

      final backToWgs84Point = ProjectionConverter.convert(
        sourcePoint: webMercatorPoint,
        sourceProjectionKey: 'EPSG:3857',
        targetProjectionKey: 'EPSG:4326',
      );

      // Should return original coordinates within reasonable precision
      expect(backToWgs84Point.latitude, closeTo(41.0082, 0.01));
      expect(backToWgs84Point.longitude, closeTo(28.9784, 0.01));
    });

    test('should handle Turkish national coordinate systems', () {
      const wgs84Point = LatLng(41.0082, 28.9784); // Istanbul

      final itrf96Point = ProjectionConverter.convert(
        sourcePoint: wgs84Point,
        sourceProjectionKey: 'EPSG:4326',
        targetProjectionKey: 'ITRF96_3DEG_TM30',
      );

      // Should return x/y order for projected systems
      expect(itrf96Point.latitude.abs(), greaterThan(1000));
      expect(itrf96Point.longitude.abs(), greaterThan(1000));
    });
  });

  group('WktGenerator Tests', () {
    test('should create point geometry WKT', () {
      final pointWkt = WktGenerator.createPoint(
        coordinates: [const LatLng(41.0082, 28.9784)],
        sourceProjectionKey: 'EPSG:4326',
        targetProjectionKey: 'EPSG:3857',
      );

      expect(pointWkt, contains('POINT'));
      expect(pointWkt, isNotEmpty);
    });

    test('should create linestring geometry WKT', () {
      final lineWkt = WktGenerator.createLineString(
        coordinates: [
          const LatLng(41.0082, 28.9784),
          const LatLng(41.0090, 28.9790),
        ],
        sourceProjectionKey: 'EPSG:4326',
        targetProjectionKey: 'EPSG:3857',
      );

      expect(lineWkt, contains('LINESTRING'));
      expect(lineWkt, isNotEmpty);
    });

    test('should create polygon geometry WKT', () {
      final polygonWkt = WktGenerator.createPolygon(
        coordinates: [
          const LatLng(41.0082, 28.9784),
          const LatLng(41.0090, 28.9790),
          const LatLng(41.0080, 28.9800),
          const LatLng(41.0082, 28.9784),
        ],
        sourceProjectionKey: 'EPSG:4326',
        targetProjectionKey: 'EPSG:3857',
      );

      expect(polygonWkt, contains('POLYGON'));
      expect(polygonWkt, isNotEmpty);
    });

    test('should create multipoint geometry WKT', () {
      final multiPointWkt = WktGenerator.createMultiPoint(
        coordinates: [
          const LatLng(41.0082, 28.9784),
          const LatLng(41.0090, 28.9790),
        ],
        sourceProjectionKey: 'EPSG:4326',
        targetProjectionKey: 'EPSG:3857',
      );

      expect(multiPointWkt, contains('MULTIPOINT'));
      expect(multiPointWkt, isNotEmpty);
    });

    test('should perform buffer operation', () {
      const pointWkt = 'POINT(100 200)';
      final bufferedWkt = WktGenerator.buffer(
        wktGeometry: pointWkt,
        distance: 50,
      );

      expect(bufferedWkt, isNotEmpty);
    });

    test('should calculate convex hull', () {
      const multiPointWkt = 'MULTIPOINT(0 0, 1 1, 2 0, 1 2)';
      final convexHullWkt = WktGenerator.convexHull(
        wktGeometry: multiPointWkt,
      );

      expect(convexHullWkt, isNotEmpty);
    });

    test('should calculate centroid', () {
      const polygonWkt = 'POLYGON((0 0, 4 0, 4 4, 0 4, 0 0))';
      final centroidWkt = WktGenerator.centroid(
        wktGeometry: polygonWkt,
      );

      expect(centroidWkt, contains('POINT'));
    });

    test('should test spatial predicates', () {
      const polygon1 = 'POLYGON((0 0, 2 0, 2 2, 0 2, 0 0))';
      const polygon2 = 'POLYGON((1 1, 3 1, 3 3, 1 3, 1 1))';
      const point = 'POINT(1 1)';

      expect(
          WktGenerator.intersects(
            wktGeometry1: polygon1,
            wktGeometry2: polygon2,
          ),
          isTrue);

      expect(
          WktGenerator.contains(
            wktGeometry1: polygon1,
            wktGeometry2: point,
          ),
          isTrue);

      expect(
          WktGenerator.disjoint(
            wktGeometry1: 'POINT(0 0)',
            wktGeometry2: 'POINT(10 10)',
          ),
          isTrue);
    });

    test('should calculate measurements', () {
      const polygon = 'POLYGON((0 0, 4 0, 4 3, 0 3, 0 0))';
      const linestring = 'LINESTRING(0 0, 3 4)';

      final area = WktGenerator.getArea(wktGeometry: polygon);
      expect(area, greaterThan(0));

      final length = WktGenerator.getLength(wktGeometry: linestring);
      expect(length, greaterThan(0));

      final distance = WktGenerator.distance(
        wktGeometry1: 'POINT(0 0)',
        wktGeometry2: 'POINT(3 4)',
      );
      expect(distance, greaterThan(0));
    });

    test('should validate WKT strings', () {
      expect(WktGenerator.isValidWkt(wktGeometry: 'POINT(10 20)'), isTrue);
      expect(WktGenerator.isValidWkt(wktGeometry: 'INVALID WKT'), isFalse);
    });

    test('should get geometry type', () {
      final geometryType = WktGenerator.getGeometryType(
        wktGeometry: 'POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))',
      );
      expect(geometryType, equals('Polygon'));
    });

    test('should get number of points', () {
      final numPoints = WktGenerator.getNumPoints(
        wktGeometry: 'LINESTRING(0 0, 1 1, 2 2)',
      );
      expect(numPoints, equals(3));
    });

    test('should simplify geometry', () {
      const linestring = 'LINESTRING(0 0, 1 0.1, 2 0, 3 0.1, 4 0)';
      final simplified = WktGenerator.simplify(
        wktGeometry: linestring,
        tolerance: 0.2,
      );
      expect(simplified, isNotEmpty);
      expect(simplified, contains('LINESTRING'));
    });

    test('should create geometry collection', () {
      final collection = WktGenerator.createGeometryCollection(
        wktGeometries: [
          'POINT(10 20)',
          'LINESTRING(0 0, 10 10)',
          'POLYGON((0 0, 5 0, 5 5, 0 5, 0 0))',
        ],
      );
      expect(collection, contains('GEOMETRYCOLLECTION'));
    });

    test('should throw ProjectionException for invalid coordinates', () {
      expect(
        () => WktGenerator.createPoint(
          coordinates: [],
          sourceProjectionKey: 'EPSG:4326',
          targetProjectionKey: 'EPSG:3857',
        ),
        throwsA(isA<ProjectionException>()),
      );
    });

    test('should convert WKT to Geometry object', () {
      const wktPoint = 'POINT(10 20)';
      final geometry = WktGenerator.wktToGeometry(wktGeometry: wktPoint);

      expect(geometry.getGeometryType(), equals('Point'));
      expect(geometry.getNumPoints(), equals(1));
    });

    test('should convert WKT to Geometry object with projection conversion', () {
      // Web Mercator coordinates for Istanbul (approximately)
      const webMercatorWkt = 'POINT(3226883.8 5069429.0)';
      final geometry = WktGenerator.wktToGeometry(
        wktGeometry: webMercatorWkt,
        sourceProjectionKey: 'EPSG:3857',
      );

      expect(geometry.getGeometryType(), equals('Point'));

      // Get the converted coordinates
      final coord = geometry.getCoordinate()!;
      // Should be close to Istanbul coordinates in WGS84 (28.9784, 41.0082)
      expect(coord.x, closeTo(28.9, 1.0)); // longitude
      expect(coord.y, closeTo(41.0, 1.0)); // latitude
    });

    test('should convert LineString WKT with projection conversion', () {
      // Simple line in Web Mercator
      const webMercatorLineWkt = 'LINESTRING(3226883 5069429, 3227883 5070429)';
      final geometry = WktGenerator.wktToGeometry(
        wktGeometry: webMercatorLineWkt,
        sourceProjectionKey: 'EPSG:3857',
      );

      expect(geometry.getGeometryType(), equals('LineString'));
      expect(geometry.getNumPoints(), equals(2));

      // Verify coordinates are in reasonable WGS84 range
      final coords = geometry.getCoordinates();
      expect(coords[0].x, lessThan(180.0)); // longitude should be < 180
      expect(coords[0].y, lessThan(90.0)); // latitude should be < 90
    });

    test('should convert Geometry object to WKT', () {
      const originalWkt = 'POINT(10 20)';
      final geometry = WktGenerator.wktToGeometry(wktGeometry: originalWkt);
      final convertedWkt = WktGenerator.geometryToWkt(geometry: geometry);

      expect(convertedWkt, contains('POINT'));
      expect(convertedWkt, contains('10'));
      expect(convertedWkt, contains('20'));
    });

    test('should handle round-trip WKT to Geometry conversion', () {
      const originalWkt = 'LINESTRING(0 0, 10 10, 20 0)';
      final geometry = WktGenerator.wktToGeometry(wktGeometry: originalWkt);
      final roundTripWkt = WktGenerator.geometryToWkt(geometry: geometry);

      expect(geometry.getGeometryType(), equals('LineString'));
      expect(geometry.getNumPoints(), equals(3));
      expect(roundTripWkt, contains('LINESTRING'));
    });

    test('should throw ProjectionException for invalid WKT in wktToGeometry', () {
      expect(
        () => WktGenerator.wktToGeometry(wktGeometry: 'INVALID_WKT'),
        throwsA(isA<ProjectionException>()),
      );
    });
  });
  group('ProjectionDefinitions Tests', () {
    test('should return available projections list', () {
      final projections = ProjectionDefinitions.availableProjections;

      expect(projections, isNotEmpty);
      expect(projections, contains('EPSG:4326'));
      expect(projections, contains('EPSG:3857'));
    });

    test('should check if projection is supported', () {
      expect(ProjectionDefinitions.isSupported('EPSG:4326'), isTrue);
      expect(ProjectionDefinitions.isSupported('INVALID:PROJECTION'), isFalse);
    });

    test('should throw exception for unsupported projection', () {
      expect(
        () => ProjectionDefinitions.get('INVALID:PROJECTION'),
        throwsA(isA<ProjectionException>()),
      );
    });
  });
  const sourceProjection = 'EPSG:3857';
  const targetProjection = 'EPSG:4326';

  group('UniversalWKTParser Testleri - 3857 -> 4326', () {
    test('MULTIPOINT parse ve dönüşüm testi', () {
      const wkt = 'MULTIPOINT((1113194.91 4865942.28), (4452779.63 3503549.84))';
      final result = UniversalWKTParser.parse(
        wkt,
        sourceProjectionKey: sourceProjection,
        targetProjectionKey: targetProjection,
      );

      expect(result.isSuccess, true);
      final geom = result.geometry;
      expect(geom, isA<WKTMultiPoint>());
    });

    test('MULTILINESTRING parse ve dönüşüm testi', () {
      const wkt = 'MULTILINESTRING((1113194.91 1118889.97, 2226389.82 2486256.86), (4452779.63 4865942.28, 3339584.72 3503549.84))';
      final result = UniversalWKTParser.parse(
        wkt,
        sourceProjectionKey: sourceProjection,
        targetProjectionKey: targetProjection,
      );

      expect(result.isSuccess, true);
      expect(result.geometry, isA<WKTMultiLineString>());
    });

    test('MULTIPOLYGON parse ve dönüşüm testi', () {
      const wkt = '''
MULTIPOLYGON(((334111.47 2425281.77, 5009377.09 4865942.28, 1113194.91 4865942.28, 334111.47 2425281.77)),
                                    ((16702.72 557305.26, 4452779.63 1118889.97, 1113194.91 2425281.77, 5565.52 1118889.97, 16702.72 557305.26)))''';
      final result = UniversalWKTParser.parse(
        wkt,
        sourceProjectionKey: sourceProjection,
        targetProjectionKey: targetProjection,
      );

      expect(result.isSuccess, true);
      expect(result.geometry, isA<WKTPolygon>());
    });

    test('GEOMETRYCOLLECTION parse testi', () {
      const wkt = '''
GEOMETRYCOLLECTION(
        POINT(4452779.63 1118889.97),
        LINESTRING(1113194.91 1118889.97, 2226389.82 2486256.86),
        POLYGON((4452779.63 4865942.28, 2226389.82 5621521.49, 5009377.09 3503549.84, 4452779.63 4865942.28)),
        MULTIPOINT((1113194.91 4865942.28), (4452779.63 3503549.84))
      )''';

      final result = UniversalWKTParser.parse(
        wkt,
        sourceProjectionKey: sourceProjection,
        targetProjectionKey: targetProjection,
      );

      expect(result.isSuccess, true);
      expect(result.geometry, isA<WKTGeometryCollection>());
    });

    test('Projected MULTIPOINT dönüşüm testi', () {
      const wkt = 'MULTIPOINT((5565974.54 4649776.22), (6679163.76 4750000.00))';
      final result = UniversalWKTParser.parse(
        wkt,
        sourceProjectionKey: sourceProjection,
        targetProjectionKey: targetProjection,
      );

      expect(result.isSuccess, true);
      final geom = result.geometry! as WKTMultiPoint;
      expect(geom.pointCount, 2);
    });

    test('Geçersiz WKT yakalanmalı', () {
      const wkt = 'MULTIPOINT((INVALID))';
      final result = UniversalWKTParser.parse(
        wkt,
        sourceProjectionKey: sourceProjection,
        targetProjectionKey: targetProjection,
      );

      expect(result.isFailure, true);
    });

    test('Type-safe parsing başarısızlığı', () {
      const wkt = 'MULTIPOINT((1113194.91 1118889.97), (2226389.82 2486256.86))';
      final result = UniversalWKTParser.parseAsPoint(
        wkt,
        sourceProjectionKey: sourceProjection,
        targetProjectionKey: targetProjection,
      );

      expect(result.isFailure, true);
    });

    test('Nested GEOMETRYCOLLECTION testi', () {
      const wkt = '''
GEOMETRYCOLLECTION(
        GEOMETRYCOLLECTION(
          POINT(1113194.91 1118889.97),
          LINESTRING(2226389.82 2486256.86, 3339584.72 3503549.84)
        ),
        MULTIPOLYGON(((0 0, 1113194.91 0, 1113194.91 1118889.97, 0 1118889.97, 0 0)))
      )''';

      final result = UniversalWKTParser.parse(
        wkt,
        sourceProjectionKey: sourceProjection,
        targetProjectionKey: targetProjection,
      );

      expect(result.isSuccess, true);
      final nested = result.geometry! as WKTGeometryCollection;
      expect(nested.geometryCount, greaterThan(0));
      expect(nested.geometries.first, isA<WKTGeometryCollection>());
    });
  });
}
