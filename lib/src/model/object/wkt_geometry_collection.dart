import 'package:projection_cs/src/model/base/wkt_geometry.dart';
import 'package:projection_cs/src/utils/equler_util.dart';

/// GeometryCollection class
class WKTGeometryCollection extends WKTGeometry {
  const WKTGeometryCollection(this.geometries);
  final List<WKTGeometry> geometries;

  int get geometryCount => geometries.length;

  @override
  String toString() => 'WKTGeometryCollection(${geometries.length} geometries)';

  @override
  bool operator ==(Object other) => identical(this, other) || other is WKTGeometryCollection && EqulerUtil.listEquals(geometries, other.geometries);

  @override
  int get hashCode => geometries.hashCode;
}
