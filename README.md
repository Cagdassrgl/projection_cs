# Projection CS - Coordinate System Transformations & Spatial Analysis

[![Pub Version](https://img.shields.io/pub/v/projection_cs)](https://pub.dev/packages/projection_cs)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A comprehensive Dart package for coordinate system transformations and advanced spatial analysis operations. Built with dart_jts integration for robust geometric computations and Well-Known Text (WKT) generation.

## 🆕 What's New in v1.2.0

**Code Reorganization & Improved Maintainability**

- **🗂️ Better Project Structure**: Reorganized source code with cleaner separation of concerns
- **📁 Specialized Folders**: 
  - `projections/` - Coordinate system transformations (`ProjectionConverter`, `ProjectionDefinitions`)
  - `generators/` - WKT geometry generation and spatial operations (`WktGenerator`)
  - `parsers/` - WKT parsing functionality (`UniversalWKTParser`)
- **🔧 Enhanced Developer Experience**: Improved code organization for better maintainability
- **✅ Backward Compatible**: All existing APIs remain unchanged

## ⚠️ Important: EPSG:3857 Coordinate Input Format

When working with **EPSG:3857 (Web Mercator)** coordinates, ensure proper coordinate order:

```dart
// ✅ CORRECT: For Web Mercator inputs, use LatLng(Y_northing, X_easting)
final webMercatorPoint = LatLng(5013551.0, 3225860.0); // LatLng(Y, X)

// ❌ WRONG: This will cause coordinate misalignment
final wrongPoint = LatLng(3225860.0, 5013551.0); // LatLng(X, Y) - AVOID!
```

**See [EPSG3857_COORDINATE_FORMAT.md](EPSG3857_COORDINATE_FORMAT.md) for detailed explanation.**

## Features

- **🌍 Coordinate Transformations**: Convert between different coordinate systems and projections
- **📐 Geometry Creation**: Create complex geometries (Points, LineStrings, Polygons, Multi-geometries)
- **🔬 Spatial Analysis**: Advanced geometric operations (buffer, convex hull, centroid, envelope)
- **⚖️ Spatial Predicates**: Test spatial relationships (intersects, contains, touches, crosses, etc.)
- **📏 Measurements**: Calculate area, length, and distance between geometries
- **🧮 WKT Generation**: Convert geometries to Well-Known Text format
- **🔧 Utility Functions**: Geometry validation, simplification, and type detection

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  projection_cs: ^1.2.0
```

Then run:

```bash
dart pub get
```

## Quick Start

```dart
import 'package:projection_cs/projection_cs.dart';
import 'package:latlong2/latlong.dart';

void main() {
  // Create a simple point geometry
  final point = WktGenerator.createPoint(
    coordinates: [LatLng(41.0082, 28.9784)], // Istanbul coordinates
    sourceProjectionKey: 'EPSG:4326',
    targetProjectionKey: 'EPSG:3857',
  );

  print('Point WKT: $point');

  // Convert coordinates between projections
  final converted = ProjectionConverter.convert(
    sourcePoint: LatLng(41.0082, 28.9784),
    sourceProjectionKey: 'EPSG:4326',
    targetProjectionKey: 'EPSG:3857',
  );

  print('Converted: ${converted.latitude}, ${converted.longitude}');
}
```

## Available Coordinate Systems

The package supports numerous coordinate systems including:

- **EPSG:4326** - WGS84 Geographic (Lat/Lon)
- **EPSG:3857** - Web Mercator (Google Maps, OpenStreetMap)
- **EPSG:2154** - RGF93 / Lambert-93 (France)
- **EPSG:25832** - ETRS89 / UTM zone 32N (Central Europe)
- **EPSG:32633** - WGS 84 / UTM zone 33N
- **EPSG:4258** - ETRS89 Geographic
- **EPSG:3035** - ETRS89 / LAEA Europe
- **EPSG:3826** - TWD97 / TM2 zone 121 (Taiwan)
- **EPSG:6668** - JGD2011 Geographic (Japan)
- **EPSG:7899** - NZGD2000 / NZTM (New Zealand)

## Geometry Creation

### Point Geometries

```dart
// Create a single point
final point = WktGenerator.createPoint(
  coordinates: [LatLng(40.7128, -74.0060)], // New York
  sourceProjectionKey: 'EPSG:4326',
  targetProjectionKey: 'EPSG:3857',
);

// Create multiple points
final multiPoint = WktGenerator.createMultiPoint(
  coordinates: [
    LatLng(40.7128, -74.0060), // New York
    LatLng(34.0522, -118.2437), // Los Angeles
  ],
  sourceProjectionKey: 'EPSG:4326',
  targetProjectionKey: 'EPSG:3857',
);
```

### LineString Geometries

```dart
// Create a simple line
final line = WktGenerator.createLineString(
  coordinates: [
    LatLng(40.7128, -74.0060), // Start
    LatLng(34.0522, -118.2437), // End
  ],
  sourceProjectionKey: 'EPSG:4326',
  targetProjectionKey: 'EPSG:3857',
);

// Create multiple lines
final multiLine = WktGenerator.createMultiLineString(
  coordinateLists: [
    [LatLng(40.7128, -74.0060), LatLng(34.0522, -118.2437)],
    [LatLng(41.8781, -87.6298), LatLng(39.7392, -104.9903)],
  ],
  sourceProjectionKey: 'EPSG:4326',
  targetProjectionKey: 'EPSG:3857',
);
```

### Polygon Geometries

```dart
// Create a simple polygon (triangle)
final polygon = WktGenerator.createPolygon(
  coordinates: [
    LatLng(40.7128, -74.0060),
    LatLng(34.0522, -118.2437),
    LatLng(41.8781, -87.6298),
    LatLng(40.7128, -74.0060), // Automatically closed if not provided
  ],
  sourceProjectionKey: 'EPSG:4326',
  targetProjectionKey: 'EPSG:3857',
);

// Create polygon with holes
final polygonWithHoles = WktGenerator.createPolygon(
  coordinates: outerRingCoordinates,
  holes: [holeCoordinates1, holeCoordinates2],
  sourceProjectionKey: 'EPSG:4326',
  targetProjectionKey: 'EPSG:3857',
);

// Create multiple polygons
final multiPolygon = WktGenerator.createMultiPolygon(
  coordinateLists: [polygon1Coords, polygon2Coords],
  sourceProjectionKey: 'EPSG:4326',
  targetProjectionKey: 'EPSG:3857',
);
```

## Spatial Analysis Operations

### Buffer Operations

```dart
// Create a 100-unit buffer around a geometry
final bufferedGeometry = WktGenerator.buffer(
  wktGeometry: 'POINT(100 200)',
  distance: 100.0,
);
```

### Convex Hull

```dart
// Calculate the convex hull of a geometry
final convexHull = WktGenerator.convexHull(
  wktGeometry: 'MULTIPOINT(0 0, 1 1, 2 0, 1 2)',
);
```

### Centroid Calculation

```dart
// Find the centroid of a polygon
final centroid = WktGenerator.centroid(
  wktGeometry: 'POLYGON((0 0, 4 0, 4 4, 0 4, 0 0))',
);
```

### Envelope (Bounding Box)

```dart
// Get the bounding box of a geometry
final envelope = WktGenerator.envelope(
  wktGeometry: 'LINESTRING(0 0, 5 5, 10 0)',
);
```

## Overlay Operations

### Union

```dart
// Combine two geometries
final unionResult = WktGenerator.union(
  wktGeometry1: 'POLYGON((0 0, 2 0, 2 2, 0 2, 0 0))',
  wktGeometry2: 'POLYGON((1 1, 3 1, 3 3, 1 3, 1 1))',
);
```

### Intersection

```dart
// Find the intersection of two geometries
final intersection = WktGenerator.intersection(
  wktGeometry1: 'POLYGON((0 0, 2 0, 2 2, 0 2, 0 0))',
  wktGeometry2: 'POLYGON((1 1, 3 1, 3 3, 1 3, 1 1))',
);
```

### Difference

```dart
// Subtract one geometry from another
final difference = WktGenerator.difference(
  wktGeometry1: 'POLYGON((0 0, 2 0, 2 2, 0 2, 0 0))',
  wktGeometry2: 'POLYGON((1 1, 3 1, 3 3, 1 3, 1 1))',
);
```

### Symmetric Difference

```dart
// Get the symmetric difference of two geometries
final symDiff = WktGenerator.symmetricDifference(
  wktGeometry1: 'POLYGON((0 0, 2 0, 2 2, 0 2, 0 0))',
  wktGeometry2: 'POLYGON((1 1, 3 1, 3 3, 1 3, 1 1))',
);
```

## Spatial Predicates

Test spatial relationships between geometries:

```dart
// Test if geometries intersect
final intersects = WktGenerator.intersects(
  wktGeometry1: 'POLYGON((0 0, 2 0, 2 2, 0 2, 0 0))',
  wktGeometry2: 'POINT(1 1)',
);

// Test if one geometry contains another
final contains = WktGenerator.contains(
  wktGeometry1: 'POLYGON((0 0, 4 0, 4 4, 0 4, 0 0))',
  wktGeometry2: 'POINT(2 2)',
);

// Test if geometries are disjoint
final disjoint = WktGenerator.disjoint(
  wktGeometry1: 'POINT(0 0)',
  wktGeometry2: 'POINT(10 10)',
);

// Test if geometries touch
final touches = WktGenerator.touches(
  wktGeometry1: 'POLYGON((0 0, 2 0, 2 2, 0 2, 0 0))',
  wktGeometry2: 'POLYGON((2 0, 4 0, 4 2, 2 2, 2 0))',
);

// Test if one geometry is within another
final within = WktGenerator.within(
  wktGeometry1: 'POINT(1 1)',
  wktGeometry2: 'POLYGON((0 0, 2 0, 2 2, 0 2, 0 0))',
);

// Test if geometries cross
final crosses = WktGenerator.crosses(
  wktGeometry1: 'LINESTRING(0 0, 2 2)',
  wktGeometry2: 'LINESTRING(0 2, 2 0)',
);

// Test if geometries overlap
final overlaps = WktGenerator.overlaps(
  wktGeometry1: 'POLYGON((0 0, 2 0, 2 2, 0 2, 0 0))',
  wktGeometry2: 'POLYGON((1 1, 3 1, 3 3, 1 3, 1 1))',
);
```

## Measurements

### Area Calculation

```dart
// Calculate area of a polygon
final area = WktGenerator.getArea(
  wktGeometry: 'POLYGON((0 0, 4 0, 4 3, 0 3, 0 0))',
);
print('Area: $area'); // Area: 12.0
```

### Length Calculation

```dart
// Calculate length of a linestring
final length = WktGenerator.getLength(
  wktGeometry: 'LINESTRING(0 0, 3 4)',
);
print('Length: $length'); // Length: 5.0
```

### Distance Between Geometries

```dart
// Calculate distance between two points
final distance = WktGenerator.distance(
  wktGeometry1: 'POINT(0 0)',
  wktGeometry2: 'POINT(3 4)',
);
print('Distance: $distance'); // Distance: 5.0
```

## Utility Functions

### WKT Validation

```dart
// Check if a WKT string is valid
final isValid = WktGenerator.isValidWkt(
  wktGeometry: 'POINT(10 20)',
);
print('Is valid: $isValid'); // true
```

### Geometry Type Detection

```dart
// Get the geometry type
final geometryType = WktGenerator.getGeometryType(
  wktGeometry: 'POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))',
);
print('Type: $geometryType'); // Type: POLYGON
```

### Point Count

```dart
// Get number of points in geometry
final numPoints = WktGenerator.getNumPoints(
  wktGeometry: 'LINESTRING(0 0, 1 1, 2 2)',
);
print('Points: $numPoints'); // Points: 3
```

### Geometry Simplification

```dart
// Simplify a complex geometry
final simplified = WktGenerator.simplify(
  wktGeometry: complexLineString,
  tolerance: 0.1,
);
```

### Geometry Collections

```dart
// Create a collection from multiple geometries
final collection = WktGenerator.createGeometryCollection(
  wktGeometries: [
    'POINT(10 20)',
    'LINESTRING(0 0, 10 10)',
    'POLYGON((0 0, 5 0, 5 5, 0 5, 0 0))',
  ],
);
```

## Coordinate System Conversion

### Single Point Conversion

```dart
// Convert a single coordinate
final converted = ProjectionConverter.convert(
  sourcePoint: LatLng(41.0082, 28.9784),
  sourceProjectionKey: 'EPSG:4326',
  targetProjectionKey: 'EPSG:3857',
);
```

### Batch Conversion

```dart
// Convert multiple coordinates at once
final convertedList = ProjectionConverter.convertBatch(
  sourcePoints: [
    LatLng(41.0082, 28.9784), // Istanbul
    LatLng(40.7128, -74.0060), // New York
    LatLng(51.5074, -0.1278), // London
  ],
  sourceProjectionKey: 'EPSG:4326',
  targetProjectionKey: 'EPSG:3857',
);
```

## Error Handling

The package uses custom exceptions for better error handling:

```dart
try {
  final result = WktGenerator.createPoint(
    coordinates: [], // Invalid: empty coordinates
    sourceProjectionKey: 'EPSG:4326',
    targetProjectionKey: 'EPSG:3857',
  );
} catch (e) {
  if (e is ProjectionException) {
    print('Projection error: ${e.message}');
  }
}
```

## Advanced Usage

### Working with Complex Projections

```dart
// Convert from geographic to projected coordinate system
final utm = ProjectionConverter.convert(
  sourcePoint: LatLng(52.5200, 13.4050), // Berlin
  sourceProjectionKey: 'EPSG:4326', // WGS84
  targetProjectionKey: 'EPSG:25832', // UTM Zone 32N
);

// Create geometry in UTM coordinates
final utmPolygon = WktGenerator.createPolygon(
  coordinates: utmCoordinates,
  sourceProjectionKey: 'EPSG:25832',
  targetProjectionKey: 'EPSG:25832', // Keep in same projection
);
```

### Spatial Analysis Workflow

```dart
// Complete spatial analysis workflow
void performSpatialAnalysis() {
  // 1. Create geometries
  final park = WktGenerator.createPolygon(
    coordinates: parkBoundary,
    sourceProjectionKey: 'EPSG:4326',
    targetProjectionKey: 'EPSG:3857',
  );

  final building = WktGenerator.createPolygon(
    coordinates: buildingFootprint,
    sourceProjectionKey: 'EPSG:4326',
    targetProjectionKey: 'EPSG:3857',
  );

  // 2. Create buffer zone
  final bufferZone = WktGenerator.buffer(
    wktGeometry: building,
    distance: 50.0, // 50 meter buffer
  );

  // 3. Test spatial relationships
  final intersects = WktGenerator.intersects(
    wktGeometry1: park,
    wktGeometry2: bufferZone,
  );

  // 4. Calculate measurements
  final parkArea = WktGenerator.getArea(wktGeometry: park);
  final buildingArea = WktGenerator.getArea(wktGeometry: building);

  print('Park intersects buffer: $intersects');
  print('Park area: $parkArea sq meters');
  print('Building area: $buildingArea sq meters');
}
```

## Performance Tips

1. **Batch Processing**: Use `convertBatch` for multiple coordinate transformations
2. **Projection Selection**: Choose appropriate target projections for your use case
3. **Geometry Simplification**: Use `simplify()` for complex geometries when precision allows
4. **WKT Validation**: Validate WKT strings before processing with `isValidWkt()`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with [dart_jts](https://pub.dev/packages/dart_jts) for robust geometric operations
- Inspired by the Java Topology Suite (JTS)
- Uses [latlong2](https://pub.dev/packages/latlong2) for coordinate representation

## Support

If you have questions or need help, please:

1. Check the [API documentation](https://pub.dev/documentation/projection_cs/latest/)
2. Search existing [issues](https://github.com/your-repo/projection_cs/issues)
3. Create a new issue with a detailed description

---

**Happy spatial computing!** 🌍📐🚀

- Follows Dart/Flutter best practices

## Getting Started

Add this package to your project's dependencies in `pubspec.yaml`:

```yaml
dependencies:
  projection_cs: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Coordinate Conversion

```dart
import 'package:latlong2/latlong.dart';
import 'package:projection_cs/projection_cs.dart';

void main() {
  // Convert WGS84 coordinates to Web Mercator
  const istanbulWgs84 = LatLng(41.0082, 28.9784);

  final webMercatorPoint = ProjectionConverter.convert(
    sourcePoint: istanbulWgs84,
    sourceProjectionKey: 'EPSG:4326',
    targetProjectionKey: 'EPSG:3857',
  );

  print('Web Mercator: ${webMercatorPoint.latitude}, ${webMercatorPoint.longitude}');
}
```

### Batch Coordinate Conversion

```dart
const cities = [
  LatLng(41.0082, 28.9784), // Istanbul
  LatLng(39.9334, 32.8597), // Ankara
  LatLng(38.4192, 27.1287), // Izmir
];

final convertedCities = ProjectionConverter.convertBatch(
  sourcePoints: cities,
  sourceProjectionKey: 'EPSG:4326',
  targetProjectionKey: 'ITRF96_3DEG_TM30',
);
```

### WKT Generation & Spatial Analysis

```dart
// Transform coordinates and generate WKT geometry
const polygon = [
  LatLng(41.0082, 28.9784), // Istanbul center
  LatLng(41.0200, 28.9800), // North
  LatLng(41.0100, 29.0000), // East
  LatLng(40.9900, 28.9700), // South
  LatLng(41.0082, 28.9784), // Close polygon
];

final polygonWkt = WktGenerator.transformAndGenerateGeometryWkt(
  coordinates: polygon,
  sourceProjectionKey: 'EPSG:4326',
  targetProjectionKey: 'EPSG:3857',
  geometryType: 'POLYGON',
);
print(polygonWkt); // POLYGON((3225860.73 5013551.24, ...))

// Create different geometry types
final pointWkt = WktGenerator.transformAndGenerateGeometryWkt(
  coordinates: [LatLng(41.0082, 28.9784)],
  sourceProjectionKey: 'EPSG:4326',
  targetProjectionKey: 'EPSG:3857',
  geometryType: 'POINT',
);

final lineWkt = WktGenerator.transformAndGenerateGeometryWkt(
  coordinates: [
    LatLng(41.0082, 28.9784), // Istanbul
    LatLng(39.9334, 32.8597), // Ankara
  ],
  sourceProjectionKey: 'EPSG:4326',
  targetProjectionKey: 'ITRF96_3DEG_TM30',
  geometryType: 'LINESTRING',
);
```

### Spatial Analysis Operations

```dart
// Buffer analysis around a point
final bufferWkt = WktGenerator.performSpatialAnalysis(
  coordinates: [LatLng(41.0082, 28.9784)],
  sourceProjectionKey: 'EPSG:4326',
  targetProjectionKey: 'EPSG:3857',
  geometryType: 'POINT',
  operation: 'buffer',
  operationParams: {'distance': 5000.0}, // 5km buffer
);

// Calculate area of a polygon
final area = WktGenerator.calculateSpatialMetric(
  coordinates: polygon,
  sourceProjectionKey: 'EPSG:4326',
  targetProjectionKey: 'EPSG:3857',
  geometryType: 'POLYGON',
  metric: 'area',
);
print('Area: ${area.toStringAsFixed(2)} square meters');

// Calculate length of a route
const route = [
  LatLng(41.0082, 28.9784), // Istanbul
  LatLng(40.7589, 29.9511), // Gebze
  LatLng(40.4167, 29.1333), // Bursa
];

final length = WktGenerator.calculateSpatialMetric(
  coordinates: route,
  sourceProjectionKey: 'EPSG:4326',
  targetProjectionKey: 'EPSG:3857',
  geometryType: 'LINESTRING',
  metric: 'length',
);
print('Route length: ${(length / 1000).toStringAsFixed(2)} km');
```

### Batch Processing

```dart
// Batch geometry WKT generation
final coordinateLists = [
  [LatLng(41.0082, 28.9784)], // Point
  route, // LineString
  polygon, // Polygon
];

final geometryTypes = ['POINT', 'LINESTRING', 'POLYGON'];

final batchWkts = WktGenerator.transformAndGenerateBatchGeometryWkt(
  coordinateLists: coordinateLists,
  sourceProjectionKey: 'EPSG:4326',
  targetProjectionKey: 'EPSG:3857',
  geometryTypes: geometryTypes,
);

for (int i = 0; i < batchWkts.length; i++) {
  print('${geometryTypes[i]}: ${batchWkts[i]}');
}
```

### Traditional WKT Generation

```dart
// Generate WKT for a coordinate system
final wkt = WktGenerator.generateWkt('EPSG:4326');
print(wkt);
// Output: GEOGCS["EPSG:4326",DATUM["World Geodetic System 1984",...]]

// Batch WKT generation
final wktBatch = WktGenerator.generateWktBatch([
  'EPSG:4326',
  'EPSG:3857',
  'ITRF96_3DEG_TM30',
]);
```

### Working with Projection Definitions

```dart
// Check available projections
final projections = ProjectionDefinitions.availableProjections;
print('Available: ${projections.length} projections');

// Check if a projection is supported
if (ProjectionDefinitions.isSupported('EPSG:4326')) {
  print('WGS84 is supported!');
}

// Get PROJ4 definition
final proj4String = ProjectionDefinitions.get('EPSG:4326');
print(proj4String); // +proj=longlat +datum=WGS84 +no_defs +type=crs
```

## Supported Coordinate Systems

### Global Systems

- **EPSG:4326** - WGS84 Geographic
- **EPSG:3857** - Web Mercator (Google Maps, OpenStreetMap)

### Turkish National Coordinate Systems

#### ITRF96 3-degree Transverse Mercator Zones

- **ITRF96_3DEG_TM27** - Central Meridian 27°E
- **ITRF96_3DEG_TM30** - Central Meridian 30°E
- **ITRF96_3DEG_TM33** - Central Meridian 33°E
- **ITRF96_3DEG_TM36** - Central Meridian 36°E
- **ITRF96_3DEG_TM39** - Central Meridian 39°E
- **ITRF96_3DEG_TM42** - Central Meridian 42°E
- **ITRF96_3DEG_TM45** - Central Meridian 45°E

#### ITRF96 UTM 6-degree Zones

- **ITRF96_6DEG_ZONE35** - UTM Zone 35N
- **ITRF96_6DEG_ZONE36** - UTM Zone 36N
- **ITRF96_6DEG_ZONE37** - UTM Zone 37N
- **ITRF96_6DEG_ZONE38** - UTM Zone 38N

#### European Datum 1950 (ED50) Systems

- **ED50_3DEG_TM27** to **ED50_3DEG_TM45** - 3-degree TM zones
- **ED50_6DEG_ZONE35** to **ED50_6DEG_ZONE38** - UTM zones

## Error Handling

The package provides comprehensive error handling with descriptive exception messages:

```dart
try {
  final result = ProjectionConverter.convert(
    sourcePoint: LatLng(41.0, 29.0),
    sourceProjectionKey: 'INVALID:PROJECTION',
    targetProjectionKey: 'EPSG:4326',
  );
} catch (e) {
  if (e is ProjectionException) {
    print('Projection error: ${e.message}');
  }
}
```

## Available Spatial Operations

### Geometry Types

- **POINT** - Single point coordinates
- **LINESTRING** - Connected series of points forming a line
- **POLYGON** - Closed shape with optional holes
- **MULTIPOINT** - Collection of points

### Spatial Analysis Operations

- **buffer** - Creates a buffer zone around geometry
- **convexHull** - Calculates the convex hull of geometry
- **centroid** - Finds the geometric center point
- **envelope** - Creates bounding box around geometry

### Spatial Metrics

- **area** - Calculates area for polygon geometries
- **length** - Calculates length for linestring geometries
- **perimeter** - Calculates perimeter for polygon geometries

### Integration with dart_jts

This package leverages the powerful [dart_jts](https://pub.dev/packages/dart_jts) library for spatial operations, providing:

- **High Performance**: Optimized spatial calculations and geometry operations
- **Industry Standard**: Based on the Java Topology Suite (JTS), widely used in GIS
- **Comprehensive**: Full suite of 2D spatial operations and predicates
- **Reliable**: Battle-tested algorithms for robust spatial analysis

## 🏗️ Package Architecture (v1.2.0+)

The package is organized with a clean, modular architecture for better maintainability:

```
lib/
├── projection_cs.dart          # Main export file
└── src/
    ├── projections/            # 🌍 Coordinate system transformations
    │   ├── projection_converter.dart      # Core transformation logic
    │   └── projection_definitions.dart    # Projection definitions & configs
    ├── generators/             # 🔧 WKT geometry generation & spatial ops
    │   └── wkt_generator.dart             # Spatial analysis & WKT creation
    ├── parsers/               # 📝 WKT parsing functionality
    │   └── wkt_universal_parser.dart      # Universal WKT parsing
    ├── model/                 # 📦 Data models & geometry objects
    │   ├── base/              # Base classes (WKTGeometry, WKTResult)
    │   └── object/            # Geometry implementations
    └── utils/                 # 🛠️ Utilities & exceptions
        ├── exceptions.dart    # Custom exception classes
        └── equler_util.dart   # Mathematical utilities
```

### Key Components

- **🌍 ProjectionConverter**: High-performance coordinate transformations between different CRS
- **🔧 WktGenerator**: Comprehensive spatial operations and WKT geometry generation
- **📝 UniversalWKTParser**: Intelligent WKT parsing with automatic geometry type detection
- **📦 WKT Models**: Type-safe geometry objects with rich spatial functionality
- **🛠️ Utilities**: Error handling, mathematical operations, and helper functions

This modular design ensures:
- **🔍 Easy Navigation**: Find functionality quickly with logical organization
- **🧪 Better Testing**: Isolated components for comprehensive test coverage
- **🔧 Enhanced Maintainability**: Clear separation of concerns
- **📈 Scalable Development**: Add new features without breaking existing code

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
