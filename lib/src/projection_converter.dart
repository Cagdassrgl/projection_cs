import 'dart:developer';

import 'package:latlong2/latlong.dart';
import 'package:proj4dart/proj4dart.dart' as proj4;
import 'package:projection_cs/src/exceptions.dart';
import 'package:projection_cs/src/projection_definitions.dart';

/// A utility class for converting coordinates between different projection systems.
///
/// This class provides static methods to transform geographic coordinates from one
/// coordinate reference system (CRS) to another using PROJ4 definitions.
class ProjectionConverter {
  // MARK: - Single Point Conversion

  /// Transforms a single coordinate point from source projection to target projection.
  ///
  /// This method handles the conversion between different coordinate systems by:
  /// 1. Loading or creating the source and target projections
  /// 2. Creating a projection tuple for transformation
  /// 3. Applying the forward transformation
  /// 4. Handling coordinate order based on the target projection type
  ///
  /// Parameters:
  /// - [sourcePoint]: The input coordinate as a [LatLng] object
  /// - [sourceProjectionKey]: The source projection identifier (e.g., 'EPSG:4326')
  /// - [targetProjectionKey]: The target projection identifier (e.g., 'EPSG:3857')
  ///
  /// Returns:
  /// A transformed [LatLng] coordinate in the target projection system.
  ///
  /// Throws:
  /// [ProjectionException] if the conversion fails due to invalid projections
  /// or transformation errors.
  ///
  /// Example:
  /// ```dart
  /// final wgs84Point = LatLng(41.0082, 28.9784); // Istanbul in WGS84
  /// final webMercatorPoint = ProjectionConverter.convert(
  ///   sourcePoint: wgs84Point,
  ///   sourceProjectionKey: 'EPSG:4326',
  ///   targetProjectionKey: 'EPSG:3857',
  /// );
  /// ```
  static LatLng convert({
    required LatLng sourcePoint,
    required String sourceProjectionKey,
    required String targetProjectionKey,
  }) {
    try {
      // If source and target projections are the same, return the original point
      if (sourceProjectionKey == targetProjectionKey) {
        return sourcePoint;
      }

      // Check if both projections are supported
      if (!ProjectionDefinitions.isSupported(sourceProjectionKey)) {
        throw ProjectionException('Source projection "$sourceProjectionKey" is not supported');
      }

      if (!ProjectionDefinitions.isSupported(targetProjectionKey)) {
        throw ProjectionException('Target projection "$targetProjectionKey" is not supported');
      }

      // Get or create source projection
      final sourceProj = proj4.Projection.get(sourceProjectionKey) ?? proj4.Projection.add(sourceProjectionKey, ProjectionDefinitions.get(sourceProjectionKey));

      // Get or create target projection
      final targetProj = proj4.Projection.get(targetProjectionKey) ?? proj4.Projection.add(targetProjectionKey, ProjectionDefinitions.get(targetProjectionKey));

      // Create projection transformation tuple
      final transformationTuple = proj4.ProjectionTuple(fromProj: sourceProj, toProj: targetProj);

      // Create source point - need to handle coordinate order for source projection too
      final sourceCoordinate = _createSourcePoint(sourceProjectionKey, sourcePoint);

      // Apply forward transformation
      final transformedCoordinate = transformationTuple.forward(sourceCoordinate);

      // Handle coordinate order based on target projection type
      return _handleCoordinateOrder(targetProjectionKey, transformedCoordinate);
    } catch (e) {
      log('Coordinate conversion failed: $e');
      throw ProjectionException('Failed to convert coordinate from $sourceProjectionKey to $targetProjectionKey: $e');
    }
  }

  // MARK: - Source Point Creation

  /// Creates a proj4.Point from a LatLng based on the source projection type.
  ///
  /// For geographic coordinate systems (like EPSG:4326):
  /// - sourcePoint.longitude -> x (easting)
  /// - sourcePoint.latitude -> y (northing)
  ///
  /// For projected coordinate systems (like EPSG:3857):
  /// - WARNING: LatLng constructor expects LatLng(latitude, longitude)
  /// - But for Web Mercator, we store projected coordinates where:
  ///   * sourcePoint.latitude should contain the Y value (northing)
  ///   * sourcePoint.longitude should contain the X value (easting)
  /// - This creates potential confusion in coordinate input format
  ///
  /// IMPORTANT: For EPSG:3857 inputs, users should create LatLng as:
  /// LatLng(projected_y_northing, projected_x_easting)
  /// NOT LatLng(projected_x_easting, projected_y_northing)
  static proj4.Point _createSourcePoint(String sourceProjectionKey, LatLng sourcePoint) {
    switch (sourceProjectionKey) {
      // Geographic coordinate systems - standard lat/lng interpretation
      case 'EPSG:4326':
      case 'EPSG4326':
        return proj4.Point(x: sourcePoint.longitude, y: sourcePoint.latitude);

      // Web Mercator and other projected systems
      case 'EPSG:3857':
      case 'EPSG3857':
      case 'WEB_MERCATOR':
        // For Web Mercator projected coordinates:
        // User input LatLng(northing_y, easting_x) -> proj4.Point(x=easting, y=northing)
        return proj4.Point(x: sourcePoint.longitude, y: sourcePoint.latitude);

      // Turkish National Coordinate Systems (ITRF96) - Projected systems
      case 'ITRF96_3DEG_TM27':
      case 'ITRF96_3DEG_TM30':
      case 'ITRF96_3DEG_TM33':
      case 'ITRF96_3DEG_TM36':
      case 'ITRF96_3DEG_TM39':
      case 'ITRF96_3DEG_TM42':
      case 'ITRF96_3DEG_TM45':
        return proj4.Point(x: sourcePoint.longitude, y: sourcePoint.latitude);

      // European Datum 1950 systems - Projected systems
      case 'ED50_3DEG_TM27':
      case 'ED50_3DEG_TM30':
      case 'ED50_3DEG_TM33':
      case 'ED50_3DEG_TM36':
      case 'ED50_3DEG_TM39':
      case 'ED50_3DEG_TM42':
      case 'ED50_3DEG_TM45':
        return proj4.Point(x: sourcePoint.longitude, y: sourcePoint.latitude);

      // UTM 6-degree zone systems - Projected systems
      case 'ED50_6DEG_ZONE35':
      case 'ED50_6DEG_ZONE36':
      case 'ED50_6DEG_ZONE37':
      case 'ED50_6DEG_ZONE38':
      case 'ITRF96_6DEG_ZONE35':
      case 'ITRF96_6DEG_ZONE36':
      case 'ITRF96_6DEG_ZONE37':
      case 'ITRF96_6DEG_ZONE38':
        return proj4.Point(x: sourcePoint.longitude, y: sourcePoint.latitude);

      // Spatial Reference Organization definitions - Projected systems
      case 'SR-ORG:7931':
      case 'SR-ORG:7932':
      case 'SR-ORG:7933':
      case 'SR-ORG:7934':
      case 'SR-ORG:7935':
      case 'SR-ORG:7936':
      case 'SR-ORG:7937':
        return proj4.Point(x: sourcePoint.longitude, y: sourcePoint.latitude);

      // Default case for unknown projections
      default:
        log('Unknown source projection: $sourceProjectionKey, using default longitude/latitude (x/y) coordinate order');
        return proj4.Point(x: sourcePoint.longitude, y: sourcePoint.latitude);
    }
  }

  // MARK: - Coordinate Order Handling

  /// Handles coordinate order based on the target projection type.
  ///
  /// Different coordinate systems expect different coordinate orders:
  /// - Geographic systems (WGS84, etc.) expect latitude/longitude order
  /// - Projected systems (UTM, TM, etc.) expect x/y order
  ///
  /// IMPORTANT: LatLng constructor expects LatLng(latitude, longitude)
  /// For projected systems:
  /// - x = easting (east-west, longitude-like)
  /// - y = northing (north-south, latitude-like)
  /// So we need: LatLng(y, x) for projected systems
  static LatLng _handleCoordinateOrder(String targetProjectionKey, proj4.Point transformedCoordinate) {
    switch (targetProjectionKey) {
      // Geographic coordinate systems - already in lat/lng order
      case 'EPSG:4326':
      case 'EPSG4326':
        // For geographic systems, proj4 returns: x=longitude, y=latitude
        // LatLng constructor expects: LatLng(latitude, longitude)
        return LatLng(transformedCoordinate.y, transformedCoordinate.x);

      // Web Mercator (EPSG:3857) - projected coordinate system
      case 'EPSG:3857':
      case 'EPSG3857':
      case 'WEB_MERCATOR':
        // Web Mercator: x = easting (longitude direction), y = northing (latitude direction)
        // LatLng constructor: LatLng(latitude, longitude)
        // Therefore: LatLng(y=northing, x=easting)
        return LatLng(transformedCoordinate.y, transformedCoordinate.x);

      // Turkish National Coordinate Systems (ITRF96) - Projected systems
      case 'ITRF96_3DEG_TM27':
      case 'ITRF96_3DEG_TM30':
      case 'ITRF96_3DEG_TM33':
      case 'ITRF96_3DEG_TM36':
      case 'ITRF96_3DEG_TM39':
      case 'ITRF96_3DEG_TM42':
      case 'ITRF96_3DEG_TM45':
        // TM projections: x = easting, y = northing
        return LatLng(transformedCoordinate.y, transformedCoordinate.x);

      // European Datum 1950 systems - Projected systems
      case 'ED50_3DEG_TM27':
      case 'ED50_3DEG_TM30':
      case 'ED50_3DEG_TM33':
      case 'ED50_3DEG_TM36':
      case 'ED50_3DEG_TM39':
      case 'ED50_3DEG_TM42':
      case 'ED50_3DEG_TM45':
        return LatLng(transformedCoordinate.y, transformedCoordinate.x);

      // UTM 6-degree zone systems - Projected systems
      case 'ED50_6DEG_ZONE35':
      case 'ED50_6DEG_ZONE36':
      case 'ED50_6DEG_ZONE37':
      case 'ED50_6DEG_ZONE38':
      case 'ITRF96_6DEG_ZONE35':
      case 'ITRF96_6DEG_ZONE36':
      case 'ITRF96_6DEG_ZONE37':
      case 'ITRF96_6DEG_ZONE38':
        // UTM: x = easting, y = northing
        return LatLng(transformedCoordinate.y, transformedCoordinate.x);

      // Spatial Reference Organization definitions - Projected systems
      case 'SR-ORG:7931':
      case 'SR-ORG:7932':
      case 'SR-ORG:7933':
      case 'SR-ORG:7934':
      case 'SR-ORG:7935':
      case 'SR-ORG:7936':
      case 'SR-ORG:7937':
        return LatLng(transformedCoordinate.y, transformedCoordinate.x);

      // Default case for unknown projections - assume projected coordinate system
      default:
        log('Unknown projection: $targetProjectionKey, using default northing/easting (y/x) coordinate order');
        return LatLng(transformedCoordinate.y, transformedCoordinate.x);
    }
  }

  // MARK: - Batch Conversion

  /// Transforms multiple coordinate points from source projection to target projection.
  ///
  /// This method is a convenience wrapper around [convert] for batch processing
  /// of multiple coordinates. It applies the same transformation to each point
  /// in the input list.
  ///
  /// Parameters:
  /// - [sourcePoints]: A list of input coordinates as [LatLng] objects
  /// - [sourceProjectionKey]: The source projection identifier
  /// - [targetProjectionKey]: The target projection identifier
  ///
  /// Returns:
  /// A list of transformed [LatLng] coordinates in the target projection system.
  ///
  /// Throws:
  /// [ProjectionException] if any conversion fails. The exception will be thrown
  /// on the first failed conversion, and subsequent points will not be processed.
  ///
  /// Example:
  /// ```dart
  /// final wgs84Points = [
  ///   LatLng(41.0082, 28.9784), // Istanbul
  ///   LatLng(39.9334, 32.8597), // Ankara
  /// ];
  /// final webMercatorPoints = ProjectionConverter.convertBatch(
  ///   sourcePoints: wgs84Points,
  ///   sourceProjectionKey: 'EPSG:4326',
  ///   targetProjectionKey: 'EPSG:3857',
  /// );
  /// ```
  static List<LatLng> convertBatch({
    required List<LatLng> sourcePoints,
    required String sourceProjectionKey,
    required String targetProjectionKey,
  }) {
    // If source and target projections are the same, return the original points
    if (sourceProjectionKey == targetProjectionKey) {
      return List<LatLng>.from(sourcePoints);
    }

    return sourcePoints
        .map((point) => convert(
              sourcePoint: point,
              sourceProjectionKey: sourceProjectionKey,
              targetProjectionKey: targetProjectionKey,
            ))
        .toList();
  }
}
