import 'package:geocore/geocore.dart' as geocore;
import 'package:latlong2/latlong.dart' as lat_lng;
import 'package:projection_cs/projection_cs.dart';
import 'package:projection_cs/src/model/dto_polygon.dart';

/// WKTParser is a utility class for parsing WKT (Well-Known Text) geometries
/// into DTOs (Data Transfer Objects) used in the projection_cs package.
class WKTParser {
  /// Parses a WKT string and returns a [lat_lng.LatLng] point.
  /// Returns null if the WKT is null or not a valid point.
  static lat_lng.LatLng? parsePoint({required String wkt, String? sourceProjectionKey, String? targetProjectionKey}) {
    final geometry = geocore.WKT().parserProjected().parse(wkt);
    if (geometry is geocore.Point) {
      if (sourceProjectionKey != null) {
        return _convertProjection(
          latLng: lat_lng.LatLng(geometry.y as double, geometry.x as double),
          sourceProjectionKey: sourceProjectionKey,
          targetProjectionKey: targetProjectionKey,
        );
      }
      return lat_lng.LatLng(geometry.y as double, geometry.x as double);
    }
    return null;
  }

  /// Parses a WKT string and returns a list of [lat_lng.LatLng] points for LineString.
  /// Returns an empty list if the WKT is null or not a valid LineString.
  static List<lat_lng.LatLng> parseLineString({required String wkt, String? sourceProjectionKey, String? targetProjectionKey}) {
    final geometry = geocore.WKT().parserProjected().parse(wkt);
    if (geometry is geocore.LineString) {
      if (sourceProjectionKey != null) {
        return _converListProjection(
          pointList: geometry.chain.map((p) => lat_lng.LatLng(p.y as double, p.x as double)).toList(),
          sourceProjectionKey: sourceProjectionKey,
          targetProjectionKey: targetProjectionKey,
        );
      }
      return geometry.chain.map((p) => lat_lng.LatLng(p.y as double, p.x as double)).toList();
    }
    return [];
  }

  /// Parses a WKT string and returns a list of [DTOPolygon] objects.
  /// If the WKT is null or not a valid Polygon or MultiPolygon, returns an empty list.
  /// Returns a list containing one or more [DTOPolygon] objects based on the parsed geometry.
  static List<DTOPolygon> parsePolygon({required String wkt, String? sourceProjectionKey, String? targetProjectionKey}) {
    final geometry = geocore.WKT().parserProjected().parse(wkt);
    List<DTOPolygon> polygonList = [];

    if (geometry is geocore.MultiPolygon) {
      for (var polygon in geometry.polygons) {
        polygonList.add(_convertPolygon(polygon: polygon, sourceProjectionKey: sourceProjectionKey, targetProjectionKey: targetProjectionKey));
      }
    } else if (geometry is geocore.Polygon) {
      polygonList.add(_convertPolygon(polygon: geometry));
    }

    return polygonList;
  }

  /// Converts a [geocore.Polygon] to a [DTOPolygon].
  /// This method extracts the exterior and interior points from the polygon
  /// and returns a [DTOPolygon] object.
  /// If the polygon has no exterior or interior points, it returns an empty [DTOPolygon].
  static DTOPolygon _convertPolygon({required geocore.Polygon polygon, String? sourceProjectionKey, String? targetProjectionKey}) {
    var exteriorPoints = polygon.exterior.chain.map((p) => lat_lng.LatLng(p.y as double, p.x as double)).toList();
    if (sourceProjectionKey != null) {
      exteriorPoints = _converListProjection(
        pointList: exteriorPoints,
        sourceProjectionKey: sourceProjectionKey,
        targetProjectionKey: targetProjectionKey,
      );
    }
    var interiorPointsLists = polygon.interior.map((ring) {
      return ring.chain.map((p) => lat_lng.LatLng(p.y as double, p.x as double)).toList();
    }).toList();

    if (sourceProjectionKey != null) {
      interiorPointsLists = interiorPointsLists.map((list) {
        return _converListProjection(
          pointList: list,
          sourceProjectionKey: sourceProjectionKey,
          targetProjectionKey: targetProjectionKey,
        );
      }).toList();
    }

    return DTOPolygon(exteriorsPoints: exteriorPoints, interiorPointsLists: interiorPointsLists);
  }

  static lat_lng.LatLng _convertProjection({
    required lat_lng.LatLng latLng,
    required String sourceProjectionKey,
    String? targetProjectionKey,
  }) =>
      ProjectionConverter.convert(
        sourcePoint: latLng,
        sourceProjectionKey: sourceProjectionKey,
        targetProjectionKey: targetProjectionKey ?? 'EPSG:4326',
      );

  static List<lat_lng.LatLng> _converListProjection({
    required List<lat_lng.LatLng> pointList,
    required String sourceProjectionKey,
    String? targetProjectionKey,
  }) =>
      ProjectionConverter.convertBatch(
        sourcePoints: pointList,
        sourceProjectionKey: sourceProjectionKey,
        targetProjectionKey: targetProjectionKey ?? 'EPSG:4326',
      );
}
