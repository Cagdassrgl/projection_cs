## 1.0.1

- **BUGFIX**: Fixed coordinate order issue in EPSG:3857 to EPSG:4326 conversions
  - Improved coordinate input format handling for Web Mercator (EPSG:3857)
  - Added comprehensive documentation for coordinate order expectations
  - Enhanced `_createSourcePoint` method to handle projected coordinate systems correctly
  - Fixed polygon coordinate misalignment that caused Turkey boundaries to appear in wrong locations
  - Added detailed coordinate order validation for EPSG:3857 inputs

## 1.0.0

- **Initial Release** - Complete coordinate projection and spatial analysis package for Dart/Flutter
- **ProjectionConverter**: PROJ4-based coordinate system transformations
  - Single point conversion with `convert()` method
  - Batch conversion with `convertBatch()` method
  - Support for Turkish national coordinate systems (ITRF96, ED50)
  - Support for global coordinate systems (WGS84, UTM, Web Mercator)
- **WktGenerator**: Comprehensive spatial operations using dart_jts
  - Geometry creation (Point, LineString, Polygon, Multi-geometries)
  - Spatial analysis (buffer, convex hull, centroid, envelope)
  - Overlay operations (union, intersection, difference, symmetric difference)
  - Spatial predicates (intersects, contains, touches, within, covers, etc.)
  - Measurements (area, length, distance calculations)
  - Geometry validation and simplification
  - WKT (Well-Known Text) output generation
- **ProjectionDefinitions**: Pre-configured projection definitions
  - Turkish National Coordinate Systems (ITRF96 3-degree zones)
  - European Datum 1950 (ED50) systems
  - UTM 6-degree zone systems
  - Spatial Reference Organization (SR-ORG) definitions
  - Global coordinate systems (EPSG standards)
- **Code Organization**: MARK comments for improved navigation and maintainability
- **Dependencies**: dart_jts ^0.3.0+1, proj4dart ^2.1.0, latlong2: ^0.9.1
- **Platform Support**: Flutter and Dart applications
