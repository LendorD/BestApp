// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cs2_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CS2MapImpl _$$CS2MapImplFromJson(Map<String, dynamic> json) => _$CS2MapImpl(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  displayName: json['display_name'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$CS2MapImplToJson(_$CS2MapImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'display_name': instance.displayName,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

_$CS2GrenadeImpl _$$CS2GrenadeImplFromJson(Map<String, dynamic> json) =>
    _$CS2GrenadeImpl(
      id: (json['id'] as num).toInt(),
      map: json['map'] as String,
      side: json['side'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      fromPosition: json['from_position'] as String,
      toPosition: json['to_position'] as String,
      difficulty: json['difficulty'] as String,
      imageUrl: json['image_url'] as String,
      videoUrl: json['video_url'] as String,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$CS2GrenadeImplToJson(_$CS2GrenadeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'map': instance.map,
      'side': instance.side,
      'type': instance.type,
      'title': instance.title,
      'description': instance.description,
      'from_position': instance.fromPosition,
      'to_position': instance.toPosition,
      'difficulty': instance.difficulty,
      'image_url': instance.imageUrl,
      'video_url': instance.videoUrl,
      'tags': instance.tags,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

_$CreateCS2GrenadeRequestImpl _$$CreateCS2GrenadeRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateCS2GrenadeRequestImpl(
  map: json['map'] as String,
  side: json['side'] as String,
  type: json['type'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  fromPosition: json['from_position'] as String,
  toPosition: json['to_position'] as String,
  difficulty: json['difficulty'] as String,
  imageUrl: json['image_url'] as String,
  videoUrl: json['video_url'] as String,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$$CreateCS2GrenadeRequestImplToJson(
  _$CreateCS2GrenadeRequestImpl instance,
) => <String, dynamic>{
  'map': instance.map,
  'side': instance.side,
  'type': instance.type,
  'title': instance.title,
  'description': instance.description,
  'from_position': instance.fromPosition,
  'to_position': instance.toPosition,
  'difficulty': instance.difficulty,
  'image_url': instance.imageUrl,
  'video_url': instance.videoUrl,
  'tags': instance.tags,
};
