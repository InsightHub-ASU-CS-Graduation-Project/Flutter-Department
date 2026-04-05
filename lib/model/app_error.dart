class AppError {
  final String? message;
  final String? error;
  final String? msg;
  final List<String>? errors;

  AppError({
    this.message,
    this.error,
    this.msg,
    this.errors,
  });

  factory AppError.fromJson(Map<String, dynamic> json) {
    return AppError(
      message: json['message'] as String?,
      error: json['error'] as String?,
      msg: json['msg'] as String?,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }
  String getErrorMessage() {
    if (message != null) return message!;
    if (error != null) return error!;
    if (msg != null) return msg!;
    if (errors != null && errors!.isNotEmpty) return errors!.join(', ');
    return 'Unknown error';
  }
}