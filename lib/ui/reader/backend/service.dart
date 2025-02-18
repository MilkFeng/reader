import 'dart:io';

abstract class Service {
  String get part;
  Future<void> handleRequest(String path, HttpRequest request);
}