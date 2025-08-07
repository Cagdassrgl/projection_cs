import 'package:latlong2/latlong.dart' as lat_lng;
import 'package:projection_cs/src/model/base/wkt_geometry.dart';
import 'package:projection_cs/src/utils/equler_util.dart';

/// MultiLineString geometry class
class WKTMultiLineString extends WKTGeometry {
  const WKTMultiLineString(this.lineStrings);
  final List<List<lat_lng.LatLng>> lineStrings;

  int get lineStringCount => lineStrings.length;
  int get totalPointCount => lineStrings.fold(0, (sum, line) => sum + line.length);

  @override
  String toString() => 'WKTMultiLineString(${lineStrings.length} linestrings)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WKTMultiLineString && EqulerUtil.deepListEquals(lineStrings, other.lineStrings);

  @override
  int get hashCode => lineStrings.hashCode;
}
