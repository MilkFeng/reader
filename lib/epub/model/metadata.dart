import 'package:quiver/core.dart';

class Version {
  late final int major;
  late final int minor;

  Version(String version) {
    final parts = version.split('.');
    major = int.parse(parts[0]);
    minor = int.parse(parts[1]);
  }

  bool isVersion2() => major == 2;
  bool isVersion3() => major == 3;

  @override
  String toString() => '$major.$minor';

  @override
  bool operator ==(Object other) {
    if (other is Version) {
      return major == other.major && minor == other.minor;
    }
    return false;
  }

  @override
  int get hashCode => hash2(major.hashCode, minor.hashCode);
}


class Metadata {
  final Version version;

  final List<String> titles;
  final List<String> authors;

  final String? description;
  final List<String> subjects;

  final String? coverHref;

  Metadata({
    required this.version,
    required this.titles,
    required this.authors,
    required this.description,
    required this.subjects,
    required this.coverHref,
  });
}
