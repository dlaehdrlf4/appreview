
class ApiCommonResponse {
  final String result;
  final String resultMessage;
  final dynamic data;

  ApiCommonResponse({
    required this.result,
    required this.resultMessage,
    required this.data,
  });

  factory ApiCommonResponse.fromJson(Map<String, dynamic> json) {
    return ApiCommonResponse(
      result: json['result'],
      resultMessage: json['result_message'],
      data: json['data'],
    );
  }
}