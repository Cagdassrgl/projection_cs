import 'package:projection_cs/src/model/base/wkt_geometry.dart';

/// Result wrapper for WKT parsing operations
class WKTResult<T extends WKTGeometry> {
  factory WKTResult.failure(String error) => WKTResult._(error: error, isSuccess: false);

  factory WKTResult.success(T geometry) => WKTResult._(geometry: geometry, isSuccess: true);

  const WKTResult._({required this.isSuccess, this.geometry, this.error});
  final T? geometry;
  final String? error;
  final bool isSuccess;

  bool get isFailure => !isSuccess;

  @override
  String toString() => isSuccess ? 'WKTResult.success($geometry)' : 'WKTResult.failure($error)';
}
