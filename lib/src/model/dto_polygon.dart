import 'package:latlong2/latlong.dart';

class DTOPolygon {
  List<LatLng>? exteriorsPoints;
  List<List<LatLng>>? interiorPointsLists;

  DTOPolygon({this.exteriorsPoints, this.interiorPointsLists});
}
