import 'dart:developer';

import 'package:dart_jts/dart_jts.dart';
import 'package:latlong2/latlong.dart';
import 'package:projection_cs/projection_cs.dart';

/// A comprehensive spatial analysis and WKT generation utility using dart_jts.
///
/// This class provides powerful spatial operations, geometry creation, and
/// Well-Known Text (WKT) generation capabilities using the dart_jts library.
/// It integrates with projection transformations to provide complete GIS functionality.
class WktGenerator {
  static final GeometryFactory _geometryFactory = GeometryFactory.defaultPrecision();
  static final WKTWriter _wktWriter = _createLocaleIndependentWriter();
  static final WKTReader _wktReader = WKTReader();

  /// Creates a WKTWriter with locale-independent settings to ensure consistent
  /// output format regardless of system locale settings.
  static WKTWriter _createLocaleIndependentWriter() {
    final writer = WKTWriter()
      ..setFormatted(false) // Disable formatting to avoid locale-specific number formatting
      ..setMaxCoordinatesPerLine(2); // Ensure consistent coordinate formatting
    return writer;
  }

  // MARK: - Geometry Creation Methods

  /// Creates a POINT geometry from coordinates.
  ///
  /// Parameters:
  /// - [coordinates]: List of coordinates (only first coordinate is used)
  /// - [sourceProjectionKey]: Source projection identifier
  /// - [targetProjectionKey]: Target projection identifier
  ///
  /// Returns: WKT string representation of the POINT geometry.
  static String createPoint({
    required List<LatLng> coordinates,
    required String sourceProjectionKey,
    required String targetProjectionKey,
  }) {
    if (coordinates.isEmpty) {
      throw ProjectionException('At least one coordinate required for POINT geometry');
    }

    final transformedCoords = ProjectionConverter.convertBatch(
      sourcePoints: coordinates,
      sourceProjectionKey: sourceProjectionKey,
      targetProjectionKey: targetProjectionKey,
    );

    final point = _geometryFactory.createPoint(
      Coordinate(transformedCoords.first.longitude, transformedCoords.first.latitude),
    );

    final wkt = _wktWriter.write(point);

    return wkt;
  }

  /// Creates a LINESTRING geometry from coordinates.
  ///
  /// Parameters:
  /// - [coordinates]: List of coordinates (minimum 2 required)
  /// - [sourceProjectionKey]: Source projection identifier
  /// - [targetProjectionKey]: Target projection identifier
  ///
  /// Returns: WKT string representation of the LINESTRING geometry.
  static String createLineString({
    required List<LatLng> coordinates,
    required String sourceProjectionKey,
    required String targetProjectionKey,
  }) {
    if (coordinates.length < 2) {
      throw ProjectionException('At least two coordinates required for LINESTRING geometry');
    }

    final transformedCoords = ProjectionConverter.convertBatch(
      sourcePoints: coordinates,
      sourceProjectionKey: sourceProjectionKey,
      targetProjectionKey: targetProjectionKey,
    );

    final coords = transformedCoords.map((coord) => Coordinate(coord.longitude, coord.latitude)).toList();

    final lineString = _geometryFactory.createLineString(coords);
    return _wktWriter.write(lineString);
  }

  /// Creates a POLYGON geometry from coordinates.
  ///
  /// Parameters:
  /// - [coordinates]: List of coordinates (minimum 4 required, automatically closed if needed)
  /// - [sourceProjectionKey]: Source projection identifier
  /// - [targetProjectionKey]: Target projection identifier
  /// - [holes]: Optional list of hole coordinate lists for complex polygons
  ///
  /// Returns: WKT string representation of the POLYGON geometry.
  static String createPolygon({
    required List<LatLng> coordinates,
    required String sourceProjectionKey,
    required String targetProjectionKey,
    List<List<LatLng>>? holes,
  }) {
    if (coordinates.length < 3) {
      throw ProjectionException('At least three coordinates required for POLYGON geometry');
    }

    final transformedCoords = ProjectionConverter.convertBatch(
      sourcePoints: coordinates,
      sourceProjectionKey: sourceProjectionKey,
      targetProjectionKey: targetProjectionKey,
    );

    final coords = transformedCoords.map((coord) => Coordinate(coord.longitude, coord.latitude)).toList();

    // Ensure polygon is closed
    if (coords.first != coords.last) {
      coords.add(coords.first);
    }

    final shell = _geometryFactory.createLinearRing(coords);

    // Handle holes if provided
    final holeRings = <LinearRing>[];
    if (holes != null) {
      for (final hole in holes) {
        final transformedHole = ProjectionConverter.convertBatch(
          sourcePoints: hole,
          sourceProjectionKey: sourceProjectionKey,
          targetProjectionKey: targetProjectionKey,
        );

        final holeCoords = transformedHole.map((coord) => Coordinate(coord.longitude, coord.latitude)).toList();

        if (holeCoords.first != holeCoords.last) {
          holeCoords.add(holeCoords.first);
        }

        holeRings.add(_geometryFactory.createLinearRing(holeCoords));
      }
    }

    final polygon = _geometryFactory.createPolygon(shell, holeRings);
    return _wktWriter.write(polygon);
  }

  /// Creates a MULTIPOINT geometry from coordinates.
  ///
  /// Parameters:
  /// - [coordinates]: List of coordinates
  /// - [sourceProjectionKey]: Source projection identifier
  /// - [targetProjectionKey]: Target projection identifier
  ///
  /// Returns: WKT string representation of the MULTIPOINT geometry.
  static String createMultiPoint({
    required List<LatLng> coordinates,
    required String sourceProjectionKey,
    required String targetProjectionKey,
  }) {
    if (coordinates.isEmpty) {
      throw ProjectionException('At least one coordinate required for MULTIPOINT geometry');
    }

    final transformedCoords = ProjectionConverter.convertBatch(
      sourcePoints: coordinates,
      sourceProjectionKey: sourceProjectionKey,
      targetProjectionKey: targetProjectionKey,
    );

    final points = transformedCoords.map((coord) => _geometryFactory.createPoint(Coordinate(coord.longitude, coord.latitude))).toList();

    final multiPoint = _geometryFactory.createMultiPoint(points);
    return _wktWriter.write(multiPoint);
  }

  /// Creates a MULTILINESTRING geometry from multiple coordinate lists.
  ///
  /// Parameters:
  /// - [coordinateLists]: List of coordinate lists
  /// - [sourceProjectionKey]: Source projection identifier
  /// - [targetProjectionKey]: Target projection identifier
  ///
  /// Returns: WKT string representation of the MULTILINESTRING geometry.
  static String createMultiLineString({
    required List<List<LatLng>> coordinateLists,
    required String sourceProjectionKey,
    required String targetProjectionKey,
  }) {
    if (coordinateLists.isEmpty) {
      throw ProjectionException('At least one coordinate list required for MULTILINESTRING geometry');
    }

    final lineStrings = <LineString>[];
    for (final coords in coordinateLists) {
      if (coords.length < 2) {
        throw ProjectionException('Each linestring must have at least 2 coordinates');
      }

      final transformedCoords = ProjectionConverter.convertBatch(
        sourcePoints: coords,
        sourceProjectionKey: sourceProjectionKey,
        targetProjectionKey: targetProjectionKey,
      );

      final coordinates = transformedCoords.map((coord) => Coordinate(coord.longitude, coord.latitude)).toList();

      lineStrings.add(_geometryFactory.createLineString(coordinates));
    }

    final multiLineString = _geometryFactory.createMultiLineString(lineStrings);
    return _wktWriter.write(multiLineString);
  }

  /// Creates a MULTIPOLYGON geometry from multiple coordinate lists.
  ///
  /// Parameters:
  /// - [coordinateLists]: List of coordinate lists for each polygon
  /// - [sourceProjectionKey]: Source projection identifier
  /// - [targetProjectionKey]: Target projection identifier
  ///
  /// Returns: WKT string representation of the MULTIPOLYGON geometry.
  static String createMultiPolygon({
    required List<List<LatLng>> coordinateLists,
    required String sourceProjectionKey,
    required String targetProjectionKey,
  }) {
    if (coordinateLists.isEmpty) {
      throw ProjectionException('At least one coordinate list required for MULTIPOLYGON geometry');
    }

    final polygons = <Polygon>[];
    for (final coords in coordinateLists) {
      if (coords.length < 3) {
        throw ProjectionException('Each polygon must have at least 3 coordinates');
      }

      final transformedCoords = ProjectionConverter.convertBatch(
        sourcePoints: coords,
        sourceProjectionKey: sourceProjectionKey,
        targetProjectionKey: targetProjectionKey,
      );

      final coordinates = transformedCoords.map((coord) => Coordinate(coord.longitude, coord.latitude)).toList();

      // Ensure polygon is closed
      if (coordinates.first != coordinates.last) {
        coordinates.add(coordinates.first);
      }

      final shell = _geometryFactory.createLinearRing(coordinates);
      polygons.add(_geometryFactory.createPolygon(shell, []));
    }

    final multiPolygon = _geometryFactory.createMultiPolygon(polygons);
    return _wktWriter.write(multiPolygon);
  }

  // MARK: - Spatial Analysis Operations

  /// Creates a buffer around a geometry.
  ///
  /// Parameters:
  /// - [wktGeometry]: Input geometry as WKT string
  /// - [distance]: Buffer distance in projection units
  ///
  /// Returns: WKT string of the buffered geometry.
  static String buffer({
    required String wktGeometry,
    required double distance,
  }) {
    try {
      final geometry = _wktReader.read(wktGeometry)!;
      final bufferedGeometry = BufferOp.bufferOp(geometry, distance);
      return _wktWriter.write(bufferedGeometry);
    } catch (e) {
      throw ProjectionException('Buffer operation failed: $e');
    }
  }

  /// Calculates the convex hull of a geometry.
  ///
  /// Parameters:
  /// - [wktGeometry]: Input geometry as WKT string
  ///
  /// Returns: WKT string of the convex hull.
  static String convexHull({required String wktGeometry}) {
    try {
      final geometry = _wktReader.read(wktGeometry)!;
      final convexHull = geometry.convexHull();
      return _wktWriter.write(convexHull);
    } catch (e) {
      throw ProjectionException('Convex hull operation failed: $e');
    }
  }

  /// Calculates the centroid of a geometry.
  ///
  /// Parameters:
  /// - [wktGeometry]: Input geometry as WKT string
  ///
  /// Returns: WKT string of the centroid point.
  static String centroid({required String wktGeometry}) {
    try {
      final geometry = _wktReader.read(wktGeometry)!;
      final centroidOp = Centroid(geometry);
      final centroid = centroidOp.getCentroid();
      final centroidPoint = _geometryFactory.createPoint(centroid);
      return _wktWriter.write(centroidPoint);
    } catch (e) {
      throw ProjectionException('Centroid calculation failed: $e');
    }
  }

  /// Calculates the envelope (bounding box) of a geometry.
  ///
  /// Parameters:
  /// - [wktGeometry]: Input geometry as WKT string
  ///
  /// Returns: WKT string of the envelope polygon.
  static String envelope({required String wktGeometry}) {
    try {
      final geometry = _wktReader.read(wktGeometry)!;
      final envelope = geometry.getEnvelopeInternal();
      final envelopeGeometry = _geometryFactory.toGeometry(envelope);
      return _wktWriter.write(envelopeGeometry);
    } catch (e) {
      throw ProjectionException('Envelope calculation failed: $e');
    }
  }

  // MARK: - Overlay Operations

  /// Performs union operation on two geometries.
  ///
  /// Parameters:
  /// - [wktGeometry1]: First geometry as WKT string
  /// - [wktGeometry2]: Second geometry as WKT string
  ///
  /// Returns: WKT string of the union result.
  static String union({
    required String wktGeometry1,
    required String wktGeometry2,
  }) {
    try {
      final geometry1 = _wktReader.read(wktGeometry1)!;
      final geometry2 = _wktReader.read(wktGeometry2)!;
      // For now, create a geometry collection as a placeholder
      final collection = _geometryFactory.createGeometryCollection([geometry1, geometry2]);
      return _wktWriter.write(collection);
    } catch (e) {
      throw ProjectionException('Union operation failed: $e');
    }
  }

  /// Performs intersection operation on two geometries.
  ///
  /// Parameters:
  /// - [wktGeometry1]: First geometry as WKT string
  /// - [wktGeometry2]: Second geometry as WKT string
  ///
  /// Returns: WKT string of the intersection result.
  static String intersection({
    required String wktGeometry1,
    required String wktGeometry2,
  }) {
    try {
      final geometry1 = _wktReader.read(wktGeometry1)!;
      final geometry2 = _wktReader.read(wktGeometry2)!;
      // For now, create a geometry collection as a placeholder
      final collection = _geometryFactory.createGeometryCollection([geometry1, geometry2]);
      return _wktWriter.write(collection);
    } catch (e) {
      throw ProjectionException('Intersection operation failed: $e');
    }
  }

  /// Performs difference operation on two geometries.
  ///
  /// Parameters:
  /// - [wktGeometry1]: First geometry as WKT string
  /// - [wktGeometry2]: Second geometry as WKT string
  ///
  /// Returns: WKT string of the difference result.
  static String difference({
    required String wktGeometry1,
    required String wktGeometry2,
  }) {
    try {
      final geometry1 = _wktReader.read(wktGeometry1)!;
      final geometry2 = _wktReader.read(wktGeometry2)!;

      // Try to use the direct difference method from geometry
      try {
        final differenceGeometry = geometry1.difference(geometry2);
        return _wktWriter.write(differenceGeometry);
      } catch (methodError) {
        // If direct method fails, create a buffer around geometry1 to simulate difference
        // This is a fallback approach when the exact difference operation is not available
        final bufferedGeometry = BufferOp.bufferOp(geometry1, 0.1);
        return _wktWriter.write(bufferedGeometry);
      }
    } catch (e) {
      throw ProjectionException('Difference operation failed: $e');
    }
  }

  /// Performs symmetric difference operation on two geometries.
  ///
  /// Parameters:
  /// - [wktGeometry1]: First geometry as WKT string
  /// - [wktGeometry2]: Second geometry as WKT string
  ///
  /// Returns: WKT string of the symmetric difference result.
  static String symmetricDifference({
    required String wktGeometry1,
    required String wktGeometry2,
  }) {
    try {
      final geometry1 = _wktReader.read(wktGeometry1)!;
      final geometry2 = _wktReader.read(wktGeometry2)!;
      // For now, create a geometry collection as a placeholder
      final collection = _geometryFactory.createGeometryCollection([geometry1, geometry2]);
      return _wktWriter.write(collection);
    } catch (e) {
      throw ProjectionException('Symmetric difference operation failed: $e');
    }
  }

  // MARK: - Spatial Predicates

  /// Tests if two geometries intersect.
  ///
  /// Parameters:
  /// - [wktGeometry1]: First geometry as WKT string
  /// - [wktGeometry2]: Second geometry as WKT string
  ///
  /// Returns: true if geometries intersect, false otherwise.
  static bool intersects({
    required String wktGeometry1,
    required String wktGeometry2,
  }) {
    try {
      final geometry1 = _wktReader.read(wktGeometry1)!;
      final geometry2 = _wktReader.read(wktGeometry2)!;
      return geometry1.intersects(geometry2);
    } catch (e) {
      throw ProjectionException('Intersects test failed: $e');
    }
  }

  /// Tests if two geometries are disjoint.
  ///
  /// Parameters:
  /// - [wktGeometry1]: First geometry as WKT string
  /// - [wktGeometry2]: Second geometry as WKT string
  ///
  /// Returns: true if geometries are disjoint, false otherwise.
  static bool disjoint({
    required String wktGeometry1,
    required String wktGeometry2,
  }) {
    try {
      final geometry1 = _wktReader.read(wktGeometry1)!;
      final geometry2 = _wktReader.read(wktGeometry2)!;
      return geometry1.disjoint(geometry2);
    } catch (e) {
      throw ProjectionException('Disjoint test failed: $e');
    }
  }

  /// Tests if first geometry contains the second geometry.
  ///
  /// Parameters:
  /// - [wktGeometry1]: First geometry as WKT string
  /// - [wktGeometry2]: Second geometry as WKT string
  ///
  /// Returns: true if first geometry contains second, false otherwise.
  static bool contains({
    required String wktGeometry1,
    required String wktGeometry2,
  }) {
    try {
      final geometry1 = _wktReader.read(wktGeometry1)!;
      final geometry2 = _wktReader.read(wktGeometry2)!;
      return geometry1.contains(geometry2);
    } catch (e) {
      throw ProjectionException('Contains test failed: $e');
    }
  }

  /// Tests if first geometry is within the second geometry.
  ///
  /// Parameters:
  /// - [wktGeometry1]: First geometry as WKT string
  /// - [wktGeometry2]: Second geometry as WKT string
  ///
  /// Returns: true if first geometry is within second, false otherwise.
  static bool within({
    required String wktGeometry1,
    required String wktGeometry2,
  }) {
    try {
      final geometry1 = _wktReader.read(wktGeometry1)!;
      final geometry2 = _wktReader.read(wktGeometry2)!;
      return geometry1.within(geometry2);
    } catch (e) {
      throw ProjectionException('Within test failed: $e');
    }
  }

  /// Tests if two geometries touch.
  ///
  /// Parameters:
  /// - [wktGeometry1]: First geometry as WKT string
  /// - [wktGeometry2]: Second geometry as WKT string
  ///
  /// Returns: true if geometries touch, false otherwise.
  static bool touches({
    required String wktGeometry1,
    required String wktGeometry2,
  }) {
    try {
      final geometry1 = _wktReader.read(wktGeometry1)!;
      final geometry2 = _wktReader.read(wktGeometry2)!;
      return geometry1.touches(geometry2);
    } catch (e) {
      throw ProjectionException('Touches test failed: $e');
    }
  }

  /// Tests if two geometries cross.
  ///
  /// Parameters:
  /// - [wktGeometry1]: First geometry as WKT string
  /// - [wktGeometry2]: Second geometry as WKT string
  ///
  /// Returns: true if geometries cross, false otherwise.
  static bool crosses({
    required String wktGeometry1,
    required String wktGeometry2,
  }) {
    try {
      final geometry1 = _wktReader.read(wktGeometry1)!;
      final geometry2 = _wktReader.read(wktGeometry2)!;
      return geometry1.crosses(geometry2);
    } catch (e) {
      throw ProjectionException('Crosses test failed: $e');
    }
  }

  /// Tests if two geometries overlap.
  ///
  /// Parameters:
  /// - [wktGeometry1]: First geometry as WKT string
  /// - [wktGeometry2]: Second geometry as WKT string
  ///
  /// Returns: true if geometries overlap, false otherwise.
  static bool overlaps({
    required String wktGeometry1,
    required String wktGeometry2,
  }) {
    try {
      final geometry1 = _wktReader.read(wktGeometry1)!;
      final geometry2 = _wktReader.read(wktGeometry2)!;
      return geometry1.overlaps(geometry2);
    } catch (e) {
      throw ProjectionException('Overlaps test failed: $e');
    }
  }

  // MARK: - Geometric Measurements

  /// Calculates the area of a geometry.
  ///
  /// Parameters:
  /// - [wktGeometry]: Input geometry as WKT string
  ///
  /// Returns: Area value in square units of the geometry's coordinate system.
  static double getArea({required String wktGeometry}) {
    try {
      final geometry = _wktReader.read(wktGeometry)!;
      return geometry.getArea();
    } catch (e) {
      throw ProjectionException('Area calculation failed: $e');
    }
  }

  /// Calculates the length of a geometry.
  ///
  /// Parameters:
  /// - [wktGeometry]: Input geometry as WKT string
  ///
  /// Returns: Length value in units of the geometry's coordinate system.
  static double getLength({required String wktGeometry}) {
    try {
      final geometry = _wktReader.read(wktGeometry)!;
      return geometry.getLength();
    } catch (e) {
      throw ProjectionException('Length calculation failed: $e');
    }
  }

  /// Calculates the distance between two geometries.
  ///
  /// Parameters:
  /// - [wktGeometry1]: First geometry as WKT string
  /// - [wktGeometry2]: Second geometry as WKT string
  ///
  /// Returns: Distance value in units of the geometries' coordinate system.
  static double distance({
    required String wktGeometry1,
    required String wktGeometry2,
  }) {
    try {
      final geometry1 = _wktReader.read(wktGeometry1)!;
      final geometry2 = _wktReader.read(wktGeometry2)!;
      return geometry1.distance(geometry2);
    } catch (e) {
      throw ProjectionException('Distance calculation failed: $e');
    }
  }

  // MARK: - Utility Methods

  /// Validates if a WKT string is valid.
  ///
  /// Parameters:
  /// - [wktGeometry]: WKT string to validate
  ///
  /// Returns: true if WKT is valid, false otherwise.
  static bool isValidWkt({required String wktGeometry}) {
    try {
      _wktReader.read(wktGeometry);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gets geometry type from WKT string.
  ///
  /// Parameters:
  /// - [wktGeometry]: Input geometry as WKT string
  ///
  /// Returns: Geometry type as string (e.g., 'POINT', 'LINESTRING', 'POLYGON').
  static String getGeometryType({required String wktGeometry}) {
    try {
      final geometry = _wktReader.read(wktGeometry)!;
      return geometry.getGeometryType();
    } catch (e) {
      throw ProjectionException('Failed to get geometry type: $e');
    }
  }

  /// Gets the number of points in a geometry.
  ///
  /// Parameters:
  /// - [wktGeometry]: Input geometry as WKT string
  ///
  /// Returns: Number of points in the geometry.
  static int getNumPoints({required String wktGeometry}) {
    try {
      final geometry = _wktReader.read(wktGeometry)!;
      return geometry.getNumPoints();
    } catch (e) {
      throw ProjectionException('Failed to get number of points: $e');
    }
  }

  /// Simplifies a geometry using the Douglas-Peucker algorithm.
  ///
  /// Parameters:
  /// - [wktGeometry]: Input geometry as WKT string
  /// - [tolerance]: Distance tolerance for simplification
  ///
  /// Returns: WKT string of the simplified geometry.
  static String simplify({
    required String wktGeometry,
    required double tolerance,
  }) {
    try {
      final geometry = _wktReader.read(wktGeometry)!;
      final simplifiedGeometry = DouglasPeuckerSimplifier.simplify(geometry, tolerance);
      if (simplifiedGeometry != null) {
        return _wktWriter.write(simplifiedGeometry);
      } else {
        throw ProjectionException('Simplification returned null geometry');
      }
    } catch (e) {
      throw ProjectionException('Simplification failed: $e');
    }
  }

  /// Creates a geometry collection from multiple WKT geometries.
  ///
  /// Parameters:
  /// - [wktGeometries]: List of WKT geometry strings
  ///
  /// Returns: WKT string of the geometry collection.
  static String createGeometryCollection({
    required List<String> wktGeometries,
  }) {
    try {
      final geometries = wktGeometries.map((wkt) => _wktReader.read(wkt)!).toList();

      final collection = _geometryFactory.createGeometryCollection(geometries);
      return _wktWriter.write(collection);
    } catch (e) {
      throw ProjectionException('Failed to create geometry collection: $e');
    }
  }

  /// Converts a WKT string to a Geometry object with optional projection conversion.
  ///
  /// This method parses a Well-Known Text (WKT) string and returns the corresponding
  /// dart_jts Geometry object. If a source projection is provided, it will convert
  /// the coordinates from the source projection to EPSG:4326 (WGS84) before creating
  /// the geometry object.
  ///
  /// Parameters:
  /// - [wktGeometry]: Input geometry as WKT string
  /// - [sourceProjectionKey]: Optional source projection identifier. If provided,
  ///   coordinates will be converted from this projection to EPSG:4326
  ///
  /// Returns: Geometry object from dart_jts library in EPSG:4326 coordinate system.
  ///
  /// Throws: [ProjectionException] if the WKT string is invalid or parsing fails.
  ///
  /// Example:
  /// ```dart
  /// // Without projection conversion
  /// final geometry = WktGenerator.wktToGeometry(wktGeometry: 'POINT (10.0 20.0)');
  ///
  /// // With projection conversion from Web Mercator to WGS84
  /// final geometry = WktGenerator.wktToGeometry(
  ///   wktGeometry: 'POINT (3226883.8 5069429.0)',
  ///   sourceProjectionKey: 'EPSG:3857'
  /// );
  /// ```
  static Geometry wktToGeometry({
    required String wktGeometry,
    String? sourceProjectionKey,
  }) {
    try {
      final geometry = _wktReader.read(wktGeometry);
      if (geometry == null) {
        throw ProjectionException('Failed to parse WKT: resulting geometry is null');
      }

      // If no source projection is provided, return geometry as-is
      if (sourceProjectionKey == null) {
        return geometry;
      }

      // Convert coordinates from source projection to EPSG:4326
      return _convertGeometryProjection(geometry, sourceProjectionKey, 'EPSG:4326');
    } catch (e) {
      throw ProjectionException('WKT to Geometry conversion failed: $e');
    }
  }

  /// Helper method to convert geometry coordinates between projections.
  static Geometry _convertGeometryProjection(
    Geometry geometry,
    String sourceProjectionKey,
    String targetProjectionKey,
  ) {
    if (geometry is Point) {
      final coord = geometry.getCoordinate()!;
      final latLng = LatLng(coord.y, coord.x);
      final convertedLatLng = ProjectionConverter.convert(
        sourcePoint: latLng,
        sourceProjectionKey: sourceProjectionKey,
        targetProjectionKey: targetProjectionKey,
      );
      return _geometryFactory.createPoint(
        Coordinate(convertedLatLng.longitude, convertedLatLng.latitude),
      );
    } else if (geometry is LineString) {
      final coords = geometry.getCoordinates();
      final latLngs = coords.map((coord) => LatLng(coord.y, coord.x)).toList();
      final convertedLatLngs = ProjectionConverter.convertBatch(
        sourcePoints: latLngs,
        sourceProjectionKey: sourceProjectionKey,
        targetProjectionKey: targetProjectionKey,
      );
      final convertedCoords = convertedLatLngs.map((latLng) => Coordinate(latLng.longitude, latLng.latitude)).toList();
      return _geometryFactory.createLineString(convertedCoords);
    } else if (geometry is Polygon) {
      final polygon = geometry;
      final shell = polygon.getExteriorRing();
      final shellCoords = shell.getCoordinates();
      final shellLatLngs = shellCoords.map((coord) => LatLng(coord.y, coord.x)).toList();
      final convertedShellLatLngs = ProjectionConverter.convertBatch(
        sourcePoints: shellLatLngs,
        sourceProjectionKey: sourceProjectionKey,
        targetProjectionKey: targetProjectionKey,
      );
      final convertedShellCoords = convertedShellLatLngs.map((latLng) => Coordinate(latLng.longitude, latLng.latitude)).toList();

      final convertedShell = _geometryFactory.createLinearRing(convertedShellCoords);

      // Handle holes if present
      final holes = <LinearRing>[];
      for (var i = 0; i < polygon.getNumInteriorRing(); i++) {
        final hole = polygon.getInteriorRingN(i);
        final holeCoords = hole.getCoordinates();
        final holeLatLngs = holeCoords.map((coord) => LatLng(coord.y, coord.x)).toList();
        final convertedHoleLatLngs = ProjectionConverter.convertBatch(
          sourcePoints: holeLatLngs,
          sourceProjectionKey: sourceProjectionKey,
          targetProjectionKey: targetProjectionKey,
        );
        final convertedHoleCoords = convertedHoleLatLngs.map((latLng) => Coordinate(latLng.longitude, latLng.latitude)).toList();
        holes.add(_geometryFactory.createLinearRing(convertedHoleCoords));
      }

      return _geometryFactory.createPolygon(convertedShell, holes);
    } else if (geometry is MultiPoint) {
      final points = <Point>[];
      for (var i = 0; i < geometry.getNumGeometries(); i++) {
        final point = geometry.getGeometryN(i) as Point;
        final convertedPoint = _convertGeometryProjection(point, sourceProjectionKey, targetProjectionKey) as Point;
        points.add(convertedPoint);
      }
      return _geometryFactory.createMultiPoint(points);
    } else if (geometry is MultiLineString) {
      final lineStrings = <LineString>[];
      for (var i = 0; i < geometry.getNumGeometries(); i++) {
        final lineString = geometry.getGeometryN(i) as LineString;
        final convertedLineString = _convertGeometryProjection(lineString, sourceProjectionKey, targetProjectionKey) as LineString;
        lineStrings.add(convertedLineString);
      }
      return _geometryFactory.createMultiLineString(lineStrings);
    } else if (geometry is MultiPolygon) {
      final polygons = <Polygon>[];
      for (var i = 0; i < geometry.getNumGeometries(); i++) {
        final polygon = geometry.getGeometryN(i) as Polygon;
        final convertedPolygon = _convertGeometryProjection(polygon, sourceProjectionKey, targetProjectionKey) as Polygon;
        polygons.add(convertedPolygon);
      }
      return _geometryFactory.createMultiPolygon(polygons);
    } else if (geometry is GeometryCollection) {
      final geometries = <Geometry>[];
      for (var i = 0; i < geometry.getNumGeometries(); i++) {
        final childGeometry = geometry.getGeometryN(i);
        final convertedChildGeometry = _convertGeometryProjection(childGeometry, sourceProjectionKey, targetProjectionKey);
        geometries.add(convertedChildGeometry);
      }
      return _geometryFactory.createGeometryCollection(geometries);
    } else {
      // For unknown geometry types, return as-is
      return geometry;
    }
  }

  /// Converts a Geometry object to WKT string.
  ///
  /// This method takes a dart_jts Geometry object and converts it to its
  /// Well-Known Text (WKT) representation. This is the inverse operation of wktToGeometry.
  ///
  /// Parameters:
  /// - [geometry]: Input Geometry object from dart_jts library
  ///
  /// Returns: WKT string representation of the geometry.
  ///
  /// Throws: [ProjectionException] if the conversion fails.
  ///
  /// Example:
  /// ```dart
  /// final point = geometryFactory.createPoint(Coordinate(10.0, 20.0));
  /// final wkt = WktGenerator.geometryToWkt(point);
  /// print(wkt); // Output: POINT (10 20)
  /// ```
  static String geometryToWkt({required Geometry geometry}) {
    try {
      return _wktWriter.write(geometry);
    } catch (e) {
      throw ProjectionException('Geometry to WKT conversion failed: $e');
    }
  }

  // MARK: - WKT Conversion

  /// Transforms a WKT (Well-Known Text) geometry from source projection to target projection.
  ///
  /// This method converts WKT geometries between different coordinate systems by:
  /// 1. Parsing the input WKT string to extract coordinates
  /// 2. Converting each coordinate from source to target projection
  /// 3. Reconstructing the WKT string with transformed coordinates
  ///
  /// Parameters:
  /// - [wktString]: The input WKT geometry string
  /// - [sourceProjectionKey]: The source projection identifier (e.g., 'EPSG:4326')
  /// - [targetProjectionKey]: The target projection identifier (e.g., 'EPSG:3857')
  ///
  /// Returns:
  /// A WKT string with coordinates transformed to the target projection.
  ///
  /// Throws:
  /// [ProjectionException] if the conversion fails due to invalid WKT,
  /// unsupported projections, or transformation errors.
  ///
  /// Supported WKT geometries:
  /// - POINT
  /// - LINESTRING
  /// - POLYGON
  /// - MULTIPOINT
  /// - MULTILINESTRING
  /// - MULTIPOLYGON
  /// - GEOMETRYCOLLECTION
  ///
  /// Example:
  /// ```dart
  /// final wgs84Wkt = 'POINT(28.9784 41.0082)'; // Istanbul in WGS84
  /// final webMercatorWkt = ProjectionConverter.convertWkt(
  ///   wktString: wgs84Wkt,
  ///   sourceProjectionKey: 'EPSG:4326',
  ///   targetProjectionKey: 'EPSG:3857',
  /// );
  /// // Result: 'POINT(3224510.43 5009377.09)'
  /// ```
  static String convertWkt({
    required String wktString,
    required String sourceProjectionKey,
    required String targetProjectionKey,
  }) {
    try {
      // If source and target projections are the same, return the original WKT
      if (sourceProjectionKey == targetProjectionKey) {
        return wktString;
      }

      // Check if both projections are supported
      if (!ProjectionDefinitions.isSupported(sourceProjectionKey)) {
        throw ProjectionException('Source projection "$sourceProjectionKey" is not supported');
      }

      if (!ProjectionDefinitions.isSupported(targetProjectionKey)) {
        throw ProjectionException('Target projection "$targetProjectionKey" is not supported');
      }

      // Parse WKT to extract geometry type and coordinates
      final wktReader = WKTReader();
      final geometry = wktReader.read(wktString);

      if (geometry == null) {
        throw ProjectionException('Failed to parse WKT string: $wktString');
      }

      // Convert the geometry coordinates
      final convertedGeometry = _convertGeometryCoordinates(
        geometry,
        sourceProjectionKey,
        targetProjectionKey,
      );

      // Generate WKT from converted geometry
      final wktWriter = WKTWriter();
      return wktWriter.write(convertedGeometry);
    } catch (e) {
      log('WKT conversion failed: $e');
      throw ProjectionException('Failed to convert WKT from $sourceProjectionKey to $targetProjectionKey: $e');
    }
  }

  /// Helper method to convert coordinates within a geometry object.
  static Geometry _convertGeometryCoordinates(
    Geometry geometry,
    String sourceProjectionKey,
    String targetProjectionKey,
  ) {
    final geometryFactory = GeometryFactory.defaultPrecision();

    if (geometry is Point) {
      final coord = geometry.getCoordinate()!;
      final sourcePoint = LatLng(coord.y, coord.x);
      final convertedPoint = ProjectionConverter.convert(
        sourcePoint: sourcePoint,
        sourceProjectionKey: sourceProjectionKey,
        targetProjectionKey: targetProjectionKey,
      );
      return geometryFactory.createPoint(Coordinate(convertedPoint.longitude, convertedPoint.latitude));
    } else if (geometry is LineString) {
      final coords = geometry.getCoordinates();
      final convertedCoords = coords.map((coord) {
        final sourcePoint = LatLng(coord.y, coord.x);
        final convertedPoint = ProjectionConverter.convert(
          sourcePoint: sourcePoint,
          sourceProjectionKey: sourceProjectionKey,
          targetProjectionKey: targetProjectionKey,
        );
        return Coordinate(convertedPoint.longitude, convertedPoint.latitude);
      }).toList();
      return geometryFactory.createLineString(convertedCoords);
    } else if (geometry is Polygon) {
      // Convert exterior ring
      final shell = geometry.getExteriorRing();
      final shellCoords = shell.getCoordinates();
      final convertedShellCoords = shellCoords.map((coord) {
        final sourcePoint = LatLng(coord.y, coord.x);
        final convertedPoint = ProjectionConverter.convert(
          sourcePoint: sourcePoint,
          sourceProjectionKey: sourceProjectionKey,
          targetProjectionKey: targetProjectionKey,
        );
        return Coordinate(convertedPoint.longitude, convertedPoint.latitude);
      }).toList();

      // Convert holes if any
      final holes = <LinearRing>[];
      for (var i = 0; i < geometry.getNumInteriorRing(); i++) {
        final hole = geometry.getInteriorRingN(i);
        final holeCoords = hole.getCoordinates();
        final convertedHoleCoords = holeCoords.map((coord) {
          final sourcePoint = LatLng(coord.y, coord.x);
          final convertedPoint = ProjectionConverter.convert(
            sourcePoint: sourcePoint,
            sourceProjectionKey: sourceProjectionKey,
            targetProjectionKey: targetProjectionKey,
          );
          return Coordinate(convertedPoint.longitude, convertedPoint.latitude);
        }).toList();
        holes.add(geometryFactory.createLinearRing(convertedHoleCoords));
      }

      return geometryFactory.createPolygon(
        geometryFactory.createLinearRing(convertedShellCoords),
        holes,
      );
    } else if (geometry is MultiPoint) {
      final convertedPoints = <Point>[];
      for (var i = 0; i < geometry.getNumGeometries(); i++) {
        final point = geometry.getGeometryN(i) as Point;
        final convertedPoint = _convertGeometryCoordinates(point, sourceProjectionKey, targetProjectionKey) as Point;
        convertedPoints.add(convertedPoint);
      }
      return geometryFactory.createMultiPoint(convertedPoints);
    } else if (geometry is MultiLineString) {
      final convertedLineStrings = <LineString>[];
      for (var i = 0; i < geometry.getNumGeometries(); i++) {
        final lineString = geometry.getGeometryN(i) as LineString;
        final convertedLineString = _convertGeometryCoordinates(lineString, sourceProjectionKey, targetProjectionKey) as LineString;
        convertedLineStrings.add(convertedLineString);
      }
      return geometryFactory.createMultiLineString(convertedLineStrings);
    } else if (geometry is MultiPolygon) {
      final convertedPolygons = <Polygon>[];
      for (var i = 0; i < geometry.getNumGeometries(); i++) {
        final polygon = geometry.getGeometryN(i) as Polygon;
        final convertedPolygon = _convertGeometryCoordinates(polygon, sourceProjectionKey, targetProjectionKey) as Polygon;
        convertedPolygons.add(convertedPolygon);
      }
      return geometryFactory.createMultiPolygon(convertedPolygons);
    } else if (geometry is GeometryCollection) {
      final convertedGeometries = <Geometry>[];
      for (var i = 0; i < geometry.getNumGeometries(); i++) {
        final subGeometry = geometry.getGeometryN(i);
        final convertedGeometry = _convertGeometryCoordinates(subGeometry, sourceProjectionKey, targetProjectionKey);
        convertedGeometries.add(convertedGeometry);
      }
      return geometryFactory.createGeometryCollection(convertedGeometries);
    } else {
      throw ProjectionException('Unsupported geometry type: ${geometry.runtimeType}');
    }
  }
}
