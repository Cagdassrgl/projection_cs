import 'package:projection_cs/projection_cs.dart';

/// A utility class that provides PROJ4 definitions for various coordinate reference systems.
///
/// This class contains predefined projection strings for commonly used coordinate systems,
/// including Turkish national coordinate systems (ITRF96, ED50), UTM zones, and global
/// coordinate systems like WGS84 and Web Mercator.
class ProjectionDefinitions {
  // MARK: - Projection Definitions Map

  /// A comprehensive collection of PROJ4 projection definitions.
  ///
  /// The map contains projection keys as strings and their corresponding PROJ4
  /// definition strings. These definitions include parameters for:
  /// - Projection type (e.g., Transverse Mercator, UTM, Geographic)
  /// - Ellipsoid parameters (e.g., GRS80, International 1924, WGS84)
  /// - Datum transformation parameters
  /// - False easting/northing and scale factors
  static const Map<String, String> _projectionCodes = {
    // MARK: - Turkish National Coordinate Systems (ITRF96)
    // Turkish National Coordinate Systems - ITRF96 based (3-degree zones)
    'ITRF96_3DEG_TM30': '+proj=tmerc +lat_0=0 +lon_0=30 +k=1 +x_0=500000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs',
    'ITRF96_3DEG_TM27': '+proj=tmerc +lat_0=0 +lon_0=27 +k=1 +x_0=500000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs',
    'ITRF96_3DEG_TM33': '+proj=tmerc +lat_0=0 +lon_0=33 +k=1 +x_0=500000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs',
    'ITRF96_3DEG_TM36': '+proj=tmerc +lat_0=0 +lon_0=36 +k=1 +x_0=500000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs',
    'ITRF96_3DEG_TM39': '+proj=tmerc +lat_0=0 +lon_0=39 +k=1 +x_0=500000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs',
    'ITRF96_3DEG_TM42': '+proj=tmerc +lat_0=0 +lon_0=42 +k=1 +x_0=500000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs',
    'ITRF96_3DEG_TM45': '+proj=tmerc +lat_0=0 +lon_0=45 +k=1 +x_0=500000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs',

    // MARK: - European Datum 1950 (ED50) - 3-degree Systems
    // European Datum 1950 - 3-degree Transverse Mercator zones
    'ED50_3DEG_TM30': '+proj=tmerc +lat_0=0 +lon_0=30 +k=1 +x_0=500000 +y_0=0 +ellps=intl +units=m +no_defs',
    'ED50_3DEG_TM27': '+proj=tmerc +lat_0=0 +lon_0=27 +k=1 +x_0=500000 +y_0=0 +ellps=intl +units=m +no_defs',
    'ED50_3DEG_TM33': '+proj=tmerc +lat_0=0 +lon_0=33 +k=1 +x_0=500000 +y_0=0 +ellps=intl +units=m +no_defs',
    'ED50_3DEG_TM36': '+proj=tmerc +lat_0=0 +lon_0=36 +k=1 +x_0=500000 +y_0=0 +ellps=intl +units=m +no_defs',
    'ED50_3DEG_TM39': '+proj=tmerc +lat_0=0 +lon_0=39 +k=1 +x_0=500000 +y_0=0 +ellps=intl +units=m +no_defs',
    'ED50_3DEG_TM42': '+proj=tmerc +lat_0=0 +lon_0=42 +k=1 +x_0=500000 +y_0=0 +ellps=intl +units=m +no_defs',
    'ED50_3DEG_TM45': '+proj=tmerc +lat_0=0 +lon_0=45 +k=1 +x_0=500000 +y_0=0 +ellps=intl +units=m +no_defs',

    // MARK: - UTM 6-degree Zone Systems
    // European Datum 1950 - UTM 6-degree zones
    'ED50_6DEG_ZONE35': '+proj=utm +zone=35 +ellps=intl +units=m +no_defs',
    'ED50_6DEG_ZONE36': '+proj=utm +zone=36 +ellps=intl +units=m +no_defs',
    'ED50_6DEG_ZONE37': '+proj=utm +zone=37 +ellps=intl +units=m +no_defs',
    'ED50_6DEG_ZONE38': '+proj=utm +zone=38 +ellps=intl +units=m +no_defs',

    // ITRF96 - UTM 6-degree zones
    'ITRF96_6DEG_ZONE35': '+proj=utm +zone=35 +datum=WGS84 +units=m +no_defs +type=crs',
    'ITRF96_6DEG_ZONE36': '+proj=utm +zone=36 +datum=WGS84 +units=m +no_defs +type=crs',
    'ITRF96_6DEG_ZONE37': '+proj=utm +zone=37 +datum=WGS84 +units=m +no_defs +type=crs',
    'ITRF96_6DEG_ZONE38': '+proj=utm +zone=38 +datum=WGS84 +units=m +no_defs +type=crs',

    // MARK: - Spatial Reference Organization (SR-ORG) Definitions
    // Spatial Reference Organization definitions (alternative ITRF96 definitions)
    'SR-ORG:7931': '+proj=tmerc +lat_0=0 +lon_0=27 +k=1 +x_0=500000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs',
    'SR-ORG:7932': '+proj=tmerc +lat_0=0 +lon_0=30 +k=1 +x_0=500000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs',
    'SR-ORG:7933': '+proj=tmerc +lat_0=0 +lon_0=33 +k=1 +x_0=500000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs',
    'SR-ORG:7934': '+proj=tmerc +lat_0=0 +lon_0=36 +k=1 +x_0=500000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs',
    'SR-ORG:7935': '+proj=tmerc +lat_0=0 +lon_0=39 +k=1 +x_0=500000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs',
    'SR-ORG:7936': '+proj=tmerc +lat_0=0 +lon_0=42 +k=1 +x_0=500000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs',
    'SR-ORG:7937': '+proj=tmerc +lat_0=0 +lon_0=45 +k=1 +x_0=500000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs',

    // MARK: - Global Coordinate Systems (EPSG)
    // Global coordinate systems
    'EPSG3857': '+proj=merc +a=6378137 +b=6378137 +lat_ts=0 +lon_0=0 +x_0=0 +y_0=0 +k=1 +units=m +nadgrids=@null +wktext +no_defs +type=crs', // Web Mercator (legacy)
    'EPSG:3857': '+proj=merc +a=6378137 +b=6378137 +lat_ts=0 +lon_0=0 +x_0=0 +y_0=0 +k=1 +units=m +nadgrids=@null +wktext +no_defs +type=crs', // Web Mercator
    'EPSG4326': '+proj=longlat +datum=WGS84 +no_defs +type=crs', // WGS84 Geographic (legacy)
    'EPSG:4326': '+proj=longlat +datum=WGS84 +no_defs +type=crs', // WGS84 Geographic
  };

  // MARK: - Projection Retrieval Methods

  /// Retrieves the PROJ4 definition string for the specified projection key.
  ///
  /// This method looks up the projection definition in the internal map and
  /// returns the corresponding PROJ4 string that can be used for coordinate
  /// transformations.
  ///
  /// Parameters:
  /// - [projectionKey]: The projection identifier to look up
  ///
  /// Returns:
  /// A PROJ4 definition string containing all necessary projection parameters.
  ///
  /// Throws:
  /// [ProjectionException] if the projection key is not found in the definitions.
  ///
  /// Example:
  /// ```dart
  /// final proj4String = ProjectionDefinitions.get('EPSG:4326');
  /// // Returns: '+proj=longlat +datum=WGS84 +no_defs +type=crs'
  /// ```
  static String get(String projectionKey) {
    final definition = _projectionCodes[projectionKey];
    if (definition == null) {
      throw ProjectionException('Projection definition for "$projectionKey" not found. '
          'Available projections: ${_projectionCodes.keys.join(', ')}');
    }
    return definition;
  }

  // MARK: - Utility Methods

  /// Returns a list of all available projection keys.
  ///
  /// This method provides access to all supported projection identifiers
  /// that can be used with the [get] method.
  ///
  /// Returns:
  /// A list of all available projection key strings.
  static List<String> get availableProjections => _projectionCodes.keys.toList();

  /// Checks if a projection key is supported.
  ///
  /// Parameters:
  /// - [projectionKey]: The projection identifier to check
  ///
  /// Returns:
  /// `true` if the projection is supported, `false` otherwise.
  static bool isSupported(String projectionKey) {
    return _projectionCodes.containsKey(projectionKey);
  }
}
