import 'package:latlong2/latlong.dart';
import 'package:projection_cs/projection_cs.dart';

/// Example demonstrating the usage of the improved projection_cs package.
void main() {
  // MARK: Projection Example

  print('=== Projection CS Example ===\n');

  // Example coordinates (Istanbul, Turkey)
  const istanbulWgs84 = LatLng(41.0082, 28.9784);
  print('Original coordinates (WGS84): ${istanbulWgs84.latitude}, ${istanbulWgs84.longitude}');

  // Convert WGS84 to Web Mercator
  print('\n--- Converting WGS84 to Web Mercator ---');
  final webMercatorPoint = ProjectionConverter.convert(
    sourcePoint: istanbulWgs84,
    sourceProjectionKey: 'EPSG:4326',
    targetProjectionKey: 'EPSG:3857',
  );
  print('Web Mercator: ${webMercatorPoint.latitude}, ${webMercatorPoint.longitude}');

  // Convert WGS84 to Turkish National Grid (ITRF96 3-degree zone)
  print('\n--- Converting WGS84 to Turkish National Grid (ITRF96 TM30) ---');
  final turkishGridPoint = ProjectionConverter.convert(
    sourcePoint: istanbulWgs84,
    sourceProjectionKey: 'EPSG:4326',
    targetProjectionKey: 'ITRF96_3DEG_TM30',
  );
  print('Turkish Grid (TM30): ${turkishGridPoint.latitude}, ${turkishGridPoint.longitude}');

  // Batch conversion example
  print('\n--- Batch Conversion Example ---');
  const cities = [
    LatLng(41.0082, 28.9784), // Istanbul
    LatLng(39.9334, 32.8597), // Ankara
    LatLng(38.4192, 27.1287), // Izmir
  ];

  final convertedCities = ProjectionConverter.convertBatch(
    sourcePoints: cities,
    sourceProjectionKey: 'EPSG:4326',
    targetProjectionKey: 'EPSG:3857',
  );

  for (var i = 0; i < cities.length; i++) {
    print('City ${i + 1}: ${cities[i]} -> ${convertedCities[i]}');
  }

  // MARK: WKT Example

  // WKT Generation and Spatial Analysis Examples
  print('\n--- Spatial Analysis with WktGenerator ---');

  // Create geometries using the new WktGenerator API
  final pointWkt = WktGenerator.createPoint(
    coordinates: [istanbulWgs84],
    sourceProjectionKey: 'EPSG:4326',
    targetProjectionKey: 'EPSG:3857',
  );
  print('Istanbul Point WKT: ${pointWkt.substring(0, 60)}...');

  // Create a route linestring
  const route = [
    LatLng(41.0082, 28.9784), // Istanbul
    LatLng(40.7589, 29.9511), // Gebze
    LatLng(40.4167, 29.1333), // Bursa
  ];

  final routeWkt = WktGenerator.createLineString(
    coordinates: route,
    sourceProjectionKey: 'EPSG:4326',
    targetProjectionKey: 'EPSG:3857',
  );
  print('Route LineString WKT: ${routeWkt.substring(0, 60)}...');

  // Create a polygon around Istanbul
  const istanbulPolygon = [
    LatLng(41.0082, 28.9784), // Istanbul center
    LatLng(41.0200, 28.9800), // North point
    LatLng(41.0100, 29), // East point
    LatLng(40.9900, 28.9700), // South point
    LatLng(41.0082, 28.9784), // Close polygon
  ];

  final polygonWkt = WktGenerator.createPolygon(
    coordinates: istanbulPolygon,
    sourceProjectionKey: 'EPSG:4326',
    targetProjectionKey: 'EPSG:3857',
  );
  print('Istanbul Polygon WKT: ${polygonWkt.substring(0, 60)}...');

  print('\n--- Spatial Analysis Operations ---');

  // Buffer analysis around Istanbul point
  final bufferWkt = WktGenerator.buffer(
    wktGeometry: pointWkt,
    distance: 5000, // 5km buffer
  );
  print('5km Buffer around Istanbul: ${bufferWkt.substring(0, 60)}...');

  // Calculate convex hull of the polygon
  final convexHullWkt = WktGenerator.convexHull(
    wktGeometry: polygonWkt,
  );
  print('Convex Hull: ${convexHullWkt.substring(0, 60)}...');

  // Find centroid of the polygon
  final centroidWkt = WktGenerator.centroid(
    wktGeometry: polygonWkt,
  );
  print('Polygon Centroid: ${centroidWkt.substring(0, 60)}...');

  print('\n--- Spatial Measurements ---');

  // Calculate polygon area
  final area = WktGenerator.getArea(wktGeometry: polygonWkt);
  print('Istanbul polygon area: ${area.toStringAsFixed(2)} square meters');

  // Calculate route length
  final length = WktGenerator.getLength(wktGeometry: routeWkt);
  print('Route length: ${(length / 1000).toStringAsFixed(2)} kilometers');

  // Calculate distance between two points
  final distance = WktGenerator.distance(
    wktGeometry1: pointWkt,
    wktGeometry2: centroidWkt,
  );
  print('Distance from Istanbul to polygon centroid: ${distance.toStringAsFixed(2)} meters');

  print('\n--- Spatial Predicates ---');

  // Test if point intersects with buffer
  final intersects = WktGenerator.intersects(
    wktGeometry1: pointWkt,
    wktGeometry2: bufferWkt,
  );
  print('Point intersects with buffer: $intersects');

  // Test if buffer contains the point
  final contains = WktGenerator.contains(
    wktGeometry1: bufferWkt,
    wktGeometry2: pointWkt,
  );
  print('Buffer contains point: $contains');

  print('\n--- Multi-Geometry Examples ---');

  // Create multiple points
  final multiPointWkt = WktGenerator.createMultiPoint(
    coordinates: route,
    sourceProjectionKey: 'EPSG:4326',
    targetProjectionKey: 'EPSG:3857',
  );
  print('MultiPoint WKT: ${multiPointWkt.substring(0, 60)}...');

  // Create multiple line strings
  final multiLineWkt = WktGenerator.createMultiLineString(
    coordinateLists: [
      route,
      [const LatLng(40.4167, 29.1333), const LatLng(40.1826, 29.0665)], // Bursa to Yenişehir
    ],
    sourceProjectionKey: 'EPSG:4326',
    targetProjectionKey: 'EPSG:3857',
  );
  print('MultiLineString WKT: ${multiLineWkt.substring(0, 60)}...');

  print('\n--- Utility Functions ---');

  // Validate WKT strings
  print('Point WKT is valid: ${WktGenerator.isValidWkt(wktGeometry: pointWkt)}');
  print('Invalid WKT is valid: ${WktGenerator.isValidWkt(wktGeometry: "INVALID WKT")}');

  // Get geometry types
  print('Point geometry type: ${WktGenerator.getGeometryType(wktGeometry: pointWkt)}');
  print('Polygon geometry type: ${WktGenerator.getGeometryType(wktGeometry: polygonWkt)}');

  // Get number of points
  print('Route line points: ${WktGenerator.getNumPoints(wktGeometry: routeWkt)}');
  print('Polygon points: ${WktGenerator.getNumPoints(wktGeometry: polygonWkt)}');

  // Simplify geometry
  final simplifiedRoute = WktGenerator.simplify(
    wktGeometry: routeWkt,
    tolerance: 1000, // 1km tolerance
  );
  print('Simplified route: ${simplifiedRoute.substring(0, 60)}...');

  // Create geometry collection
  final collection = WktGenerator.createGeometryCollection(
    wktGeometries: [pointWkt, routeWkt, polygonWkt],
  );
  print('Geometry Collection: ${collection.substring(0, 80)}...');

  // Available projections
  print('\n--- Available Projections ---');
  final availableProjections = ProjectionDefinitions.availableProjections;
  print('Total available projections: ${availableProjections.length}');
  print('Some examples:');
  for (var i = 0; i < 5 && i < availableProjections.length; i++) {
    print('- ${availableProjections[i]}');
  }

  // Check projection support
  print('\n--- Projection Support Check ---');
  final testProjections = ['EPSG:4326', 'EPSG:3857', 'INVALID:PROJECTION'];
  for (final projection in testProjections) {
    final isSupported = ProjectionDefinitions.isSupported(projection);
    print('$projection: ${isSupported ? 'Supported' : 'Not supported'}');
  }

  print('\n=== Example completed successfully! ===');
}
