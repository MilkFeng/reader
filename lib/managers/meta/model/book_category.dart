import 'dart:convert';

enum CategoryBooksOrder {
  title,
  lastRead,
}

class BookCategory {
  final int id;
  final String name;
  final CategoryBooksOrder order;
  final int index;

  BookCategory({
    required this.id,
    required this.name,
    required this.order,
    required this.index,
  });

  factory BookCategory.fromJson(Map<String, dynamic> json) {
    return BookCategory(
      id: json['id'],
      name: json['name'],
      order: CategoryBooksOrder.values[json['order']],
      index: json['index'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'order': order.index,
      'index': index,
    };
  }

  static Map<int, BookCategory> mapFromJson(String jsonStr) {
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap.map(
        (key, value) => MapEntry(int.parse(key), BookCategory.fromJson(value)));
  }

  static String mapToJson(Map<int, BookCategory> bookCategories) {
    final Map<String, Map<String, dynamic>> jsonMap = bookCategories
        .map((key, value) => MapEntry(key.toString(), value.toJson()));
    return json.encode(jsonMap);
  }

  BookCategory copyWith({
    int? id,
    String? name,
    CategoryBooksOrder? order,
    int? index,
  }) {
    return BookCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      index: index ?? this.index,
    );
  }
}
