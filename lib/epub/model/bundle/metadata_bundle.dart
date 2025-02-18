import '../metadata.dart';

class MetadataBundle {
  final String version;

  final List<String> titles;
  final List<String> authors;

  final String? description;
  final List<String> subjects;

  final String? coverHref;

  MetadataBundle({
    required this.version,
    required this.titles,
    required this.authors,
    required this.description,
    required this.subjects,
    required this.coverHref,
  });

  factory MetadataBundle.fromMetadata(Metadata metadata) {
    return MetadataBundle(
      version: metadata.version.toString(),
      titles: metadata.titles,
      authors: metadata.authors,
      description: metadata.description,
      subjects: metadata.subjects,
      coverHref: metadata.coverHref,
    );
  }

  Metadata toMetadata() {
    return Metadata(
      version: Version(version),
      titles: titles,
      authors: authors,
      description: description,
      subjects: subjects,
      coverHref: coverHref,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'titles': titles,
      'authors': authors,
      'description': description,
      'subjects': subjects,
      'coverHref': coverHref,
    };
  }

  factory MetadataBundle.fromJson(Map<String, dynamic> json) {
    return MetadataBundle(
      version: json['version'],
      titles: List<String>.from(json['titles']),
      authors: List<String>.from(json['authors']),
      description: json['description'],
      subjects: List<String>.from(json['subjects']),
      coverHref: json['coverHref'],
    );
  }
}