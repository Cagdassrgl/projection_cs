import 'package:projection_cs/src/model/base/wkt_geometry.dart';
import 'package:projection_cs/src/model/object/dto_polygon.dart';
import 'package:projection_cs/src/utils/equler_util.dart';

/// Polygon geometry class
class WKTPolygon extends WKTGeometry {
  const WKTPolygon(this.polygons);
  final List<DTOPolygon> polygons;

  bool get isMultiPolygon => polygons.length > 1;
  int get polygonCount => polygons.length;

  @override
  String toString() => 'WKTPolygon(${polygons.length} polygon${polygons.length > 1 ? 's' : ''})';

  @override
  bool operator ==(Object other) => identical(this, other) || other is WKTPolygon && EqulerUtil.listEquals(polygons, other.polygons);

  @override
  int get hashCode => polygons.hashCode;
}
