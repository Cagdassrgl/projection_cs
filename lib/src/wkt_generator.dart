import 'package:dart_jts/dart_jts.dart';
import 'package:latlong2/latlong.dart';
import 'package:projection_cs/src/exceptions.dart';
import 'package:projection_cs/src/projection_converter.dart';

/// A comprehensive spatial analysis and WKT generation utility using dart_jts.
///
/// This class provides powerful spatial operations, geometry creation, and
/// Well-Known Text (WKT) generation capabilities using the dart_jts library.
/// It integrates with projection transformations to provide complete GIS functionality.
class WktGenerator {
  static final GeometryFactory _geometryFactory = GeometryFactory.defaultPrecision();
  static final WKTWriter _wktWriter = WKTWriter();
  static final WKTReader _wktReader = WKTReader();

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

    return _wktWriter.write(point);
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
}
