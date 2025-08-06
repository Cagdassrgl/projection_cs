## 1.1.0

- Added WKTParser

## 1.0.5

- **OPTIMIZATION**: Improved performance for same-projection transformations
  - Added early return optimization when source and target projections are identical
  - Applied to both `convert()` and `convertBatch()` methods
  - Eliminates unnecessary computation for same-projection scenarios
- **FEATURE**: Added WKT projection conversion functionality
  - Added `convertWkt()` method to transform WKT geometries between coordinate systems
  - Supports all standard WKT geometry types (Point, LineString, Polygon, Multi-geometries, GeometryCollection)
  - Comprehensive error handling and validation for WKT parsing and transformation
  - Enhanced spatial workflow by enabling direct WKT coordinate system transformations

## 1.0.3

- **ENHANCEMENT**: Enhanced WKT to Geometry conversion with projection support
  - Updated `wktToGeometry()` method to accept optional `sourceProjectionKey` parameter
  - Added automatic coordinate conversion from source projection to EPSG:4326 (WGS84)
  - Added comprehensive projection conversion support for all geometry types (Point, LineString, Polygon, Multi-geometries, GeometryCollection)
  - Enhanced spatial analysis workflow by providing direct geometry objects in standardized WGS84 coordinates
  - Improved documentation with detailed examples for projection conversion use cases
  - Added extensive test coverage for projection conversion scenarios

## 1.0.2

- **FEATURE**: Added WKT to Geometry conversion methods
  - Added `wktToGeometry()` method to convert WKT strings to dart_jts Geometry objects
  - Added `geometryToWkt()` method to convert Geometry objects back to WKT strings
  - Enhanced spatial analysis capabilities by providing direct access to Geometry objects
  - Comprehensive error handling and documentation for new conversion methods
  - Enables advanced spatial operations using dart_jts library directly

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
