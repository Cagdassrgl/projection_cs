import 'package:latlong2/latlong.dart' as lat_lng;
import 'package:projection_cs/src/model/base/wkt_geometry.dart';
import 'package:projection_cs/src/utils/equler_util.dart';

/// LineString geometry class
class WKTLineString extends WKTGeometry {
  const WKTLineString(this.points);
  final List<lat_lng.LatLng> points;

  int get pointCount => points.length;

  @override
  String toString() => 'WKTLineString(${points.length} points)';

  @override
  bool operator ==(Object other) => identical(this, other) || other is WKTLineString && EqulerUtil.listEquals(points, other.points);

  @override
  int get hashCode => points.hashCode;
}
