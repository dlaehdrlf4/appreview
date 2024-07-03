import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../model/AppReviewModel.dart';

class AppReview {
  Future<dynamic> get(String start, String end) async {
    try {
      http.Response response = await http.get(Uri.parse(
          "http://10.130.110.80:9000/appreview?start_date=$start&end_date=$end"));
      if (response.statusCode != 200) {
        return null;
      }
      // final Map<String, dynamic> decodedJson = json.decode(response.body);
      return AppReviewModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes)));
    } catch (error) {
      print(error.toString());
      developer.log('asdfsf');
      return null;
    }
  }

  // Future<ApiCommonResponse?> get(String RequestUrl) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse("http://10.130.110.80:9000/appreview"),
  //     );
  //     if (response.statusCode != 200) return null;
  //
  //     final Map<String, dynamic> decodedJson = json.decode(response.body);
  //     return ApiCommonResponse.fromJson(decodedJson);
  //
  //   } catch (error) {
  //     print(error.toString());
  //     return null;
  //   }
  // }
}
