import 'dart:convert';

const _supportedMaps = {
  'mirage',
  'inferno',
  'dust2',
  'nuke',
  'ancient',
  'anubis',
  'vertigo',
};

const _supportedTypes = {'smoke', 'flash', 'molotov', 'he'};

class RecorderGrenadeImport {
  const RecorderGrenadeImport({
    required this.rawMap,
    required this.grenadeType,
    required this.throwPosition,
    required this.viewAngle,
    required this.landingPosition,
  });

  final String rawMap;
  final String grenadeType;
  final RecorderPoint throwPosition;
  final RecorderViewAngle viewAngle;
  final RecorderPoint landingPosition;

  factory RecorderGrenadeImport.fromRawText(String rawText) {
    if (rawText.trim().isEmpty) {
      throw const FormatException('Recorder JSON is empty');
    }

    final decoded = jsonDecode(rawText);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Recorder JSON must be an object');
    }

    return RecorderGrenadeImport.fromJson(decoded);
  }

  factory RecorderGrenadeImport.fromJson(Map<String, dynamic> json) {
    return RecorderGrenadeImport(
      rawMap: _readString(json, 'map'),
      grenadeType: _readString(json, 'grenade_type').toLowerCase(),
      throwPosition: RecorderPoint.fromJson(
        _readObject(json, 'throw_position'),
      ),
      viewAngle: RecorderViewAngle.fromJson(_readObject(json, 'view_angle')),
      landingPosition: RecorderPoint.fromJson(
        _readObject(json, 'landing_position'),
      ),
    );
  }

  String get normalizedMapCode {
    final cleaned = rawMap.trim().toLowerCase();
    return cleaned.replaceFirst(RegExp(r'^(de_|cs_)'), '');
  }

  String get safeMapCode =>
      _supportedMaps.contains(normalizedMapCode) ? normalizedMapCode : 'mirage';

  String get safeGrenadeType =>
      _supportedTypes.contains(grenadeType) ? grenadeType : 'smoke';

  String get suggestedTitle =>
      '${_displayMap(safeMapCode)} ${safeGrenadeType.toUpperCase()} line-up';

  String get suggestedFromPosition =>
      'Throw: ${throwPosition.toShortString()} | pitch ${viewAngle.pitchLabel}, yaw ${viewAngle.yawLabel}';

  String get suggestedToPosition => 'Land: ${landingPosition.toShortString()}';

  String get suggestedDescription =>
      'Imported from CS2 recorder.\n'
      'Throw position: ${throwPosition.toShortString()}\n'
      'View angle: pitch ${viewAngle.pitchLabel}, yaw ${viewAngle.yawLabel}\n'
      'Landing position: ${landingPosition.toShortString()}';

  String get suggestedImageUrl =>
      '/assets/gamementor/cs2/maps/$safeMapCode.jpg';

  String get suggestedTagsCsv =>
      ['recorder', safeMapCode, safeGrenadeType].join(', ');

  static String _displayMap(String mapCode) {
    return switch (mapCode) {
      'dust2' => 'Dust2',
      'nuke' => 'Nuke',
      _ => mapCode[0].toUpperCase() + mapCode.substring(1),
    };
  }
}

class RecorderPoint {
  const RecorderPoint({required this.x, required this.y, required this.z});

  final double x;
  final double y;
  final double z;

  factory RecorderPoint.fromJson(Map<String, dynamic> json) {
    return RecorderPoint(
      x: _readDouble(json, 'x'),
      y: _readDouble(json, 'y'),
      z: _readDouble(json, 'z'),
    );
  }

  String toShortString() {
    return 'x ${_formatNumber(x)}, y ${_formatNumber(y)}, z ${_formatNumber(z)}';
  }
}

class RecorderViewAngle {
  const RecorderViewAngle({required this.pitch, required this.yaw});

  final double pitch;
  final double yaw;

  factory RecorderViewAngle.fromJson(Map<String, dynamic> json) {
    return RecorderViewAngle(
      pitch: _readDouble(json, 'pitch'),
      yaw: _readDouble(json, 'yaw'),
    );
  }

  String get pitchLabel => _formatNumber(pitch);
  String get yawLabel => _formatNumber(yaw);
}

Map<String, dynamic> _readObject(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! Map<String, dynamic>) {
    throw FormatException('Field "$key" must be an object');
  }
  return value;
}

String _readString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Field "$key" must be a non-empty string');
  }
  return value.trim();
}

double _readDouble(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is num) {
    return value.toDouble();
  }
  throw FormatException('Field "$key" must be a number');
}

String _formatNumber(double value) {
  final text = value.toStringAsFixed(2);
  return text.replaceFirst(RegExp(r'\.?0+$'), '');
}
