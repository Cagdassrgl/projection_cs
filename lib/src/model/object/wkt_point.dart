import 'package:latlong2/latlong.dart' as lat_lng;
import 'package:projection_cs/src/model/base/wkt_geometry.dart';

/// Point geometry class
class WKTPoint extends WKTGeometry {
  const WKTPoint(this.point);
  final lat_lng.LatLng point;

  @override
  String toString() => 'WKTPoint(lat: ${point.latitude}, lng: ${point.longitude})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WKTPoint && point.latitude == other.point.latitude && point.longitude == other.point.longitude;

  @override
  int get hashCode => point.hashCode;
}
