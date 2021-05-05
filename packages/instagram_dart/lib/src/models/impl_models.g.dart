// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// Generator: JsonGenerator
// Target: library
// **************************************************************************

// Generated by owl 0.2.1
// https://github.com/agilord/owl

// ignore: unused_import, library_prefixes
import 'impl_models.dart';
// ignore: unused_import, library_prefixes
import 'dart:convert';
// ignore: unused_import, library_prefixes
import 'package:owl/util/json/core.dart' as _owl_json;

// **************************************************************************
// Generator: JsonGenerator
// Target: class InstagramResponse
// **************************************************************************

/// Mapper for InstagramResponse
abstract class InstagramResponseMapper {
  /// Converts an instance of InstagramResponse to Map.
  static Map<String, dynamic> map(InstagramResponse object) {
    if (object == null) return null;
    return (new _owl_json.MapBuilder(ordered: false)
          ..put('meta', InstagramExceptionMapper.map(object.meta))
          ..put('pagination',
              InstagramResponsePaginationMapper.map(object.pagination))
          ..put('data', object.data))
        .toMap();
  }

  /// Converts a Map to an instance of InstagramResponse.
  static InstagramResponse parse(Map<String, dynamic> map) {
    if (map == null) return null;
    final InstagramResponse object = new InstagramResponse();
    object.meta = InstagramExceptionMapper.parse(map['meta']);
    object.pagination =
        InstagramResponsePaginationMapper.parse(map['pagination']);
    object.data = map['data'];
    return object;
  }

  /// Converts a JSON string to an instance of InstagramResponse.
  static InstagramResponse fromJson(String json) {
    if (json == null || json.isEmpty) return null;
    final Map<String, dynamic> map = JSON.decoder.convert(json);
    return parse(map);
  }

  /// Converts an instance of InstagramResponse to JSON string.
  static String toJson(InstagramResponse object) {
    if (object == null) return null;
    return JSON.encoder.convert(map(object));
  }
}

// **************************************************************************
// Generator: JsonGenerator
// Target: class InstagramException
// **************************************************************************

/// Mapper for InstagramException
abstract class InstagramExceptionMapper {
  /// Converts an instance of InstagramException to Map.
  static Map<String, dynamic> map(InstagramException object) {
    if (object == null) return null;
    return (new _owl_json.MapBuilder(ordered: false)
          ..put('code', object.code)
          ..put('error_type', object.errorType)
          ..put('error_message', object.errorMessage))
        .toMap();
  }

  /// Converts a Map to an instance of InstagramException.
  static InstagramException parse(Map<String, dynamic> map) {
    if (map == null) return null;
    final InstagramException object = new InstagramException();
    object.code = map['code'];
    object.errorType = map['error_type'];
    object.errorMessage = map['error_message'];
    return object;
  }

  /// Converts a JSON string to an instance of InstagramException.
  static InstagramException fromJson(String json) {
    if (json == null || json.isEmpty) return null;
    final Map<String, dynamic> map = JSON.decoder.convert(json);
    return parse(map);
  }

  /// Converts an instance of InstagramException to JSON string.
  static String toJson(InstagramException object) {
    if (object == null) return null;
    return JSON.encoder.convert(map(object));
  }
}

// **************************************************************************
// Generator: JsonGenerator
// Target: class InstagramResponsePagination
// **************************************************************************

/// Mapper for InstagramResponsePagination
abstract class InstagramResponsePaginationMapper {
  /// Converts an instance of InstagramResponsePagination to Map.
  static Map<String, dynamic> map(InstagramResponsePagination object) {
    if (object == null) return null;
    return (new _owl_json.MapBuilder(ordered: false)
          ..put('next_url', object.nextUrl)
          ..put('next_max_id', object.nextMaxId))
        .toMap();
  }

  /// Converts a Map to an instance of InstagramResponsePagination.
  static InstagramResponsePagination parse(Map<String, dynamic> map) {
    if (map == null) return null;
    final InstagramResponsePagination object =
        new InstagramResponsePagination();
    object.nextUrl = map['next_url'];
    object.nextMaxId = map['next_max_id'];
    return object;
  }

  /// Converts a JSON string to an instance of InstagramResponsePagination.
  static InstagramResponsePagination fromJson(String json) {
    if (json == null || json.isEmpty) return null;
    final Map<String, dynamic> map = JSON.decoder.convert(json);
    return parse(map);
  }

  /// Converts an instance of InstagramResponsePagination to JSON string.
  static String toJson(InstagramResponsePagination object) {
    if (object == null) return null;
    return JSON.encoder.convert(map(object));
  }
}

// **************************************************************************
// Generator: JsonGenerator
// Target: class InstagramAuthException
// **************************************************************************

/// Mapper for InstagramAuthException
abstract class InstagramAuthExceptionMapper {
  /// Converts an instance of InstagramAuthException to Map.
  static Map<String, dynamic> map(InstagramAuthException object) {
    if (object == null) return null;
    return (new _owl_json.MapBuilder(ordered: false)
          ..put('error', object.error)
          ..put('error_reason', object.errorReason)
          ..put('error_description', object.errorDescription))
        .toMap();
  }

  /// Converts a Map to an instance of InstagramAuthException.
  static InstagramAuthException parse(Map<String, dynamic> map) {
    if (map == null) return null;
    final InstagramAuthException object = new InstagramAuthException();
    object.error = map['error'];
    object.errorReason = map['error_reason'];
    object.errorDescription = map['error_description'];
    return object;
  }

  /// Converts a JSON string to an instance of InstagramAuthException.
  static InstagramAuthException fromJson(String json) {
    if (json == null || json.isEmpty) return null;
    final Map<String, dynamic> map = JSON.decoder.convert(json);
    return parse(map);
  }

  /// Converts an instance of InstagramAuthException to JSON string.
  static String toJson(InstagramAuthException object) {
    if (object == null) return null;
    return JSON.encoder.convert(map(object));
  }
}