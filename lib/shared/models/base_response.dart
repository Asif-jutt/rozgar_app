class BaseResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  const BaseResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory BaseResponse.ok(T data, [String? message]) =>
      BaseResponse(success: true, data: data, message: message);

  factory BaseResponse.fail(String message) =>
      BaseResponse(success: false, message: message);
}
