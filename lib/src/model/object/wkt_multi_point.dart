import 'package:latlong2/latlong.dart' as lat_lng;
import 'package:projection_cs/src/model/base/wkt_geometry.dart';
import 'package:projection_cs/src/utils/equler_util.dart';

/// MultiPoint geometry class
class WKTMultiPoint extends WKTGeometry {
  const WKTMultiPoint(this.points);
  final List<lat_lng.LatLng> points;

  int get pointCount => points.length;

  @override
  String toString() => 'WKTMultiPoint(${points.length} points)';

  @override
  bool operator ==(Object other) => identical(this, other) || other is WKTMultiPoint && EqulerUtil.listEquals(points, other.points);

  @override
  int get hashCode => points.hashCode;
}
