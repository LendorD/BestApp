// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'cs2_models.freezed.dart';
part 'cs2_models.g.dart';

@freezed
class CS2Map with _$CS2Map {
  const factory CS2Map({
    required int id,
    required String code,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _CS2Map;

  factory CS2Map.fromJson(Map<String, dynamic> json) => _$CS2MapFromJson(json);
}

@freezed
class CS2Grenade with _$CS2Grenade {
  const factory CS2Grenade({
    required int id,
    required String map,
    required String side,
    required String type,
    required String title,
    required String description,
    @JsonKey(name: 'from_position') required String fromPosition,
    @JsonKey(name: 'to_position') required String toPosition,
    required String difficulty,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'video_url') required String videoUrl,
    @Default(<String>[]) List<String> tags,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _CS2Grenade;

  factory CS2Grenade.fromJson(Map<String, dynamic> json) =>
      _$CS2GrenadeFromJson(json);
}

@freezed
class CreateCS2GrenadeRequest with _$CreateCS2GrenadeRequest {
  const factory CreateCS2GrenadeRequest({
    required String map,
    required String side,
    required String type,
    required String title,
    required String description,
    @JsonKey(name: 'from_position') required String fromPosition,
    @JsonKey(name: 'to_position') required String toPosition,
    required String difficulty,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'video_url') required String videoUrl,
    @Default(<String>[]) List<String> tags,
  }) = _CreateCS2GrenadeRequest;

  factory CreateCS2GrenadeRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCS2GrenadeRequestFromJson(json);
}

class CS2GrenadeFilters {
  const CS2GrenadeFilters({
    this.map = '',
    this.side = '',
    this.type = '',
    this.difficulty = '',
    this.search = '',
  });

  final String map;
  final String side;
  final String type;
  final String difficulty;
  final String search;

  CS2GrenadeFilters copyWith({
    String? map,
    String? side,
    String? type,
    String? difficulty,
    String? search,
  }) {
    return CS2GrenadeFilters(
      map: map ?? this.map,
      side: side ?? this.side,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      search: search ?? this.search,
    );
  }

  bool get hasActiveFilters =>
      map.isNotEmpty ||
      side.isNotEmpty ||
      type.isNotEmpty ||
      difficulty.isNotEmpty ||
      search.isNotEmpty;
}
