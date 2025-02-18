import 'package:async/async.dart';

class SingleLoadManager<P, R> {
  final Map<int, CancelableOperation<R>> _operations = {};

  final Future<R> Function(int id, P event) onLoad;
  final Future<void> Function(int id, P event)? onCancel;

  SingleLoadManager({
    required this.onLoad,
    this.onCancel,
  });

  Future<R> load(int id, P param) async {
    if (_operations.containsKey(id)) {
      await _operations[id]!.cancel();
      _operations.remove(id);
    }

    _operations[id] = CancelableOperation.fromFuture(
      onLoad(id, param),
      onCancel: () {
        onCancel?.call(id, param);
      },
    );

    return await _operations[id]!.value;
  }

  void dispose() {
    for (final operation in _operations.values) {
      operation.cancel();
    }

    _operations.clear();
  }
}
