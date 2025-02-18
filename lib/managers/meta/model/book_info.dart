
import 'dart:convert';

import 'page_location.dart';

class BookInfo {
  final List<String> titles;
  final List<String> authors;
  final String relativePath;
  final String? coverExtension;
  final int categoryId;
  final int lastReadTime;
  final PageLocation lastReadLocation;
  final String lastReadTitle;

  BookInfo({
    required this.titles,
    required this.authors,
    required this.relativePath,
    required this.coverExtension,
    required this.categoryId,
    required this.lastReadTime,
    required this.lastReadLocation,
    required this.lastReadTitle,
  });

  factory BookInfo.fromJson(Map<String, dynamic> json) {
    return BookInfo(
      titles:
      (json['titles'] as List<dynamic>).map((e) => e as String).toList(),
      authors:
      (json['authors'] as List<dynamic>).map((e) => e as String).toList(),
      relativePath: json['relative_path'],
      coverExtension: json['cover_extension'],
      categoryId: json['category_id'],
      lastReadTime: json['last_read_time'],
      lastReadLocation: PageLocation.fromJson(json['last_read_location']),
      lastReadTitle: json['last_read_title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titles': titles,
      'authors': authors,
      'relative_path': relativePath,
      'cover_extension': coverExtension,
      'category_id': categoryId,
      'last_read_time': lastReadTime,
      'last_read_location': lastReadLocation.toJson(),
      'last_read_title': lastReadTitle,
    };
  }

  static Map<String, BookInfo> mapFromJson(String jsonStr) {
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap.map((key, value) => MapEntry(key, BookInfo.fromJson(value)));
  }

  static String mapToJson(Map<String, BookInfo> bookInfos) {
    final Map<String, Map<String, dynamic>> jsonMap =
    bookInfos.map((key, value) => MapEntry(key, value.toJson()));
    return json.encode(jsonMap);
  }

  BookInfo copyWith({
    List<String>? titles,
    List<String>? authors,
    String? relativePath,
    String? coverExtension,
    int? categoryId,
    int? lastReadTime,
    PageLocation? lastReadLocation,
    String? lastReadTitle,
  }) {
    return BookInfo(
      titles: titles ?? this.titles,
      authors: authors ?? this.authors,
      relativePath: relativePath ?? this.relativePath,
      coverExtension: coverExtension ?? this.coverExtension,
      categoryId: categoryId ?? this.categoryId,
      lastReadTime: lastReadTime ?? this.lastReadTime,
      lastReadLocation: lastReadLocation ?? this.lastReadLocation,
      lastReadTitle: lastReadTitle ?? this.lastReadTitle,
    );
  }

  String get lastReadTimeString {
    final lastReadDateTime =
    DateTime.fromMillisecondsSinceEpoch(lastReadTime).toLocal();
    final hourString = lastReadDateTime.hour.toString().padLeft(2, '0');
    final minuteString = lastReadDateTime.minute.toString().padLeft(2, '0');
    final secondString = lastReadDateTime.second.toString().padLeft(2, '0');
    return '${lastReadDateTime.year}年${lastReadDateTime.month}月${lastReadDateTime.day}日 $hourString:$minuteString:$secondString';
  }
}

class ExtendedBookInfo extends BookInfo {
  final String? coverRelativePath;
  final String? descRelativePath;
  final String epubBundleRelativePath;

  ExtendedBookInfo({
    required this.coverRelativePath,
    required this.descRelativePath,
    required this.epubBundleRelativePath,
    required super.titles,
    required super.authors,
    required super.relativePath,
    required super.coverExtension,
    required super.categoryId,
    required super.lastReadTime,
    required super.lastReadLocation,
    required super.lastReadTitle,
  });

  @override
  ExtendedBookInfo copyWith({
    String? coverRelativePath,
    String? descRelativePath,
    String? epubBundleRelativePath,
    List<String>? titles,
    List<String>? authors,
    String? relativePath,
    String? coverExtension,
    int? categoryId,
    int? lastReadTime,
    PageLocation? lastReadLocation,
    String? lastReadTitle,
  }) {
    return ExtendedBookInfo(
      coverRelativePath: coverRelativePath ?? this.coverRelativePath,
      descRelativePath: descRelativePath ?? this.descRelativePath,
      epubBundleRelativePath:
      epubBundleRelativePath ?? this.epubBundleRelativePath,
      titles: titles ?? this.titles,
      authors: authors ?? this.authors,
      relativePath: relativePath ?? this.relativePath,
      coverExtension: coverExtension ?? this.coverExtension,
      categoryId: categoryId ?? this.categoryId,
      lastReadTime: lastReadTime ?? this.lastReadTime,
      lastReadLocation: lastReadLocation ?? this.lastReadLocation,
      lastReadTitle: lastReadTitle ?? this.lastReadTitle,
    );
  }
}