import 'package:latlong2/latlong.dart';

/// DTOPolygon is a Data Transfer Object representing a polygon with exterior and interior points.
class DTOPolygon {
  /// Creates a new instance of [DTOPolygon].
  DTOPolygon({this.exteriorsPoints, this.interiorPointsLists});

  /// List of exterior points of the polygon.
  /// This is a list of [LatLng] points representing the outer boundary of the polygon.
  /// If the polygon has no exterior points, this will be null.
  List<LatLng>? exteriorsPoints;

  /// List of lists of interior points (holes) of the polygon.
  /// Each inner list represents a hole in the polygon,
  /// and contains [LatLng] points representing the boundary of that hole.
  /// If the polygon has no interior points, this will be null.
  List<List<LatLng>>? interiorPointsLists;
}
