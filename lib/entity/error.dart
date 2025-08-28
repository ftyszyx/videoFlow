class ParseUrlError implements Exception {
  final String message;
  ParseUrlError(this.message);
  @override
  String toString() => message;
}

class CommonResult<T> {
  final bool success;
  final T? data;
  final String? error;
  CommonResult({required this.success, this.data, this.error});
}
