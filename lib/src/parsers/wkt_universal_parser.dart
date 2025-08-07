import 'package:geocore/geocore.dart' as geocore;
import 'package:latlong2/latlong.dart' as lat_lng;
import 'package:projection_cs/projection_cs.dart';

/// Base class for all WKT geometry results

/// Universal WKT Parser that automatically detects geometry type and returns appropriate class
class UniversalWKTParser {
  static final geocore.WktFactory<geocore.Point<num>> _parser = geocore.WKT().parserProjected();

  /// Parses any WKT string and returns the appropriate WKTGeometry subclass
  static WKTResult<WKTGeometry> parse(
    String wkt, {
    String? sourceProjectionKey,
    String? targetProjectionKey,
  }) {
    try {
      if (wkt.trim().isEmpty) {
        return WKTResult.failure('WKT string is empty');
      }

      final geometry = _parser.parse(wkt);

      return WKTResult.success(_convertGeometry(
        geometry,
        sourceProjectionKey,
        targetProjectionKey,
      ));
    } catch (e) {
      return WKTResult.failure('Failed to parse WKT: $e');
    }
  }

  /// Type-safe parsing methods for specific geometry types
  static WKTResult<WKTPoint> parseAsPoint(
    String wkt, {
    String? sourceProjectionKey,
    String? targetProjectionKey,
  }) {
    final result = parse(wkt, sourceProjectionKey: sourceProjectionKey, targetProjectionKey: targetProjectionKey);

    if (result.isFailure) {
      return WKTResult.failure(result.error!);
    }

    if (result.geometry is WKTPoint) {
      return WKTResult.success(result.geometry! as WKTPoint);
    }

    return WKTResult.failure('Expected Point, got ${result.geometry.runtimeType}');
  }

  static WKTResult<WKTLineString> parseAsLineString(
    String wkt, {
    String? sourceProjectionKey,
    String? targetProjectionKey,
  }) {
    final result = parse(wkt, sourceProjectionKey: sourceProjectionKey, targetProjectionKey: targetProjectionKey);

    if (result.isFailure) {
      return WKTResult.failure(result.error!);
    }

    if (result.geometry is WKTLineString) {
      return WKTResult.success(result.geometry! as WKTLineString);
    }

    return WKTResult.failure('Expected LineString, got ${result.geometry.runtimeType}');
  }

  static WKTResult<WKTPolygon> parseAsPolygon(
    String wkt, {
    String? sourceProjectionKey,
    String? targetProjectionKey,
  }) {
    final result = parse(wkt, sourceProjectionKey: sourceProjectionKey, targetProjectionKey: targetProjectionKey);

    if (result.isFailure) {
      return WKTResult.failure(result.error!);
    }

    if (result.geometry is WKTPolygon) {
      return WKTResult.success(result.geometry! as WKTPolygon);
    }

    return WKTResult.failure('Expected Polygon, got ${result.geometry.runtimeType}');
  }

  /// Converts geocore geometry to appropriate WKTGeometry subclass
  static WKTGeometry _convertGeometry(
    geocore.Geometry geometry,
    String? sourceProjectionKey,
    String? targetProjectionKey,
  ) {
    // Geometry tipini kontrol etmek için pattern matching kullan
    if (geometry is geocore.Point) {
      return _convertPoint(geometry, sourceProjectionKey, targetProjectionKey);
    } else if (geometry is geocore.LineString) {
      return _convertLineString(geometry, sourceProjectionKey, targetProjectionKey);
    } else if (geometry is geocore.Polygon) {
      return _convertPolygon([geometry], sourceProjectionKey, targetProjectionKey);
    } else if (geometry is geocore.MultiPoint) {
      return _convertMultiPoint(geometry, sourceProjectionKey, targetProjectionKey);
    } else if (geometry is geocore.MultiLineString) {
      return _convertMultiLineString(geometry, sourceProjectionKey, targetProjectionKey);
    } else if (geometry is geocore.MultiPolygon) {
      return _convertPolygon(geometry.polygons.toList(), sourceProjectionKey, targetProjectionKey);
    } else if (geometry is geocore.GeometryCollection) {
      return _convertGeometryCollection(geometry, sourceProjectionKey, targetProjectionKey);
    } else {
      throw UnsupportedError('Unsupported geometry type: ${geometry.runtimeType}');
    }
  }

  static WKTPoint _convertPoint(
    geocore.Point point,
    String? sourceProjectionKey,
    String? targetProjectionKey,
  ) {
    var latLng = lat_lng.LatLng(point.y.toDouble(), point.x.toDouble());

    if (sourceProjectionKey != null) {
      latLng = _convertProjection(latLng, sourceProjectionKey, targetProjectionKey);
    }

    return WKTPoint(latLng);
  }

  static WKTLineString _convertLineString(
    geocore.LineString lineString,
    String? sourceProjectionKey,
    String? targetProjectionKey,
  ) {
    var points = lineString.chain.map((p) => lat_lng.LatLng(p.y.toDouble(), p.x.toDouble())).toList();

    if (sourceProjectionKey != null) {
      points = _convertListProjection(points, sourceProjectionKey, targetProjectionKey);
    }

    return WKTLineString(points);
  }

  static WKTPolygon _convertPolygon(
    List<geocore.Polygon> polygons,
    String? sourceProjectionKey,
    String? targetProjectionKey,
  ) {
    final dtoPolygons = polygons.map((polygon) {
      var exteriorPoints = polygon.exterior.chain.map((p) => lat_lng.LatLng(p.y.toDouble(), p.x.toDouble())).toList();

      var interiorPointsLists = polygon.interior.map((ring) {
        return ring.chain.map((p) => lat_lng.LatLng(p.y.toDouble(), p.x.toDouble())).toList();
      }).toList();

      if (sourceProjectionKey != null) {
        exteriorPoints = _convertListProjection(exteriorPoints, sourceProjectionKey, targetProjectionKey);
        interiorPointsLists = interiorPointsLists.map((list) {
          return _convertListProjection(list, sourceProjectionKey, targetProjectionKey);
        }).toList();
      }

      return DTOPolygon(
        exteriorsPoints: exteriorPoints,
        interiorPointsLists: interiorPointsLists,
      );
    }).toList();

    return WKTPolygon(dtoPolygons);
  }

  static WKTMultiPoint _convertMultiPoint(
    geocore.MultiPoint multiPoint,
    String? sourceProjectionKey,
    String? targetProjectionKey,
  ) {
    var points = multiPoint.points.map((p) => lat_lng.LatLng(p.y.toDouble(), p.x.toDouble())).toList();

    if (sourceProjectionKey != null) {
      points = _convertListProjection(points, sourceProjectionKey, targetProjectionKey);
    }

    return WKTMultiPoint(points);
  }

  static WKTMultiLineString _convertMultiLineString(
    geocore.MultiLineString multiLineString,
    String? sourceProjectionKey,
    String? targetProjectionKey,
  ) {
    final lineStrings = multiLineString.lineStrings.map((lineString) {
      var points = lineString.chain.map((p) => lat_lng.LatLng(p.y.toDouble(), p.x.toDouble())).toList();

      if (sourceProjectionKey != null) {
        points = _convertListProjection(points, sourceProjectionKey, targetProjectionKey);
      }

      return points;
    }).toList();

    return WKTMultiLineString(lineStrings);
  }

  static WKTGeometryCollection _convertGeometryCollection(
    geocore.GeometryCollection collection,
    String? sourceProjectionKey,
    String? targetProjectionKey,
  ) {
    final geometries = collection.geometries.map((geometry) => _convertGeometry(geometry, sourceProjectionKey, targetProjectionKey)).toList();

    return WKTGeometryCollection(geometries);
  }

  // Helper methods
  static lat_lng.LatLng _convertProjection(
    lat_lng.LatLng latLng,
    String sourceProjectionKey,
    String? targetProjectionKey,
  ) =>
      ProjectionConverter.convert(
        sourcePoint: latLng,
        sourceProjectionKey: sourceProjectionKey,
        targetProjectionKey: targetProjectionKey ?? 'EPSG:4326',
      );

  static List<lat_lng.LatLng> _convertListProjection(
    List<lat_lng.LatLng> pointList,
    String sourceProjectionKey,
    String? targetProjectionKey,
  ) =>
      ProjectionConverter.convertBatch(
        sourcePoints: pointList,
        sourceProjectionKey: sourceProjectionKey,
        targetProjectionKey: targetProjectionKey ?? 'EPSG:4326',
      );
}
