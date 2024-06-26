
class AppReviewModel {
  final String result;
  final String resultMessage;
  final String popupMessage;
  final List<AppReviewData> data;

  AppReviewModel({
    required this.result,
    required this.resultMessage,
    required this.popupMessage,
    required this.data,
  });

  factory AppReviewModel.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<AppReviewData> dataList = list.map((i) => AppReviewData.fromJson(i)).toList();

    return AppReviewModel(
      result: json['result'],
      resultMessage: json['result_message'],
      popupMessage: json['popup_message'],
      data: dataList,
    );
  }
}

class AppReviewData {
  final int seq;
  final String reviewId;
  final String nickname;
  final String type;
  final String createDt;
  final int starRating;
  final int thumbsUpCount;
  final String title;
  final String comment;
  final String deviceProduct;
  final String source;
  final String link;

  AppReviewData({
    required this.seq,
    required this.reviewId,
    required this.nickname,
    required this.type,
    required this.createDt,
    required this.starRating,
    required this.thumbsUpCount,
    required this.title,
    required this.comment,
    required this.deviceProduct,
    required this.source,
    required this.link,
  });

  factory AppReviewData.fromJson(Map<String, dynamic> json) {
    return AppReviewData(
      seq: json['seq'],
      reviewId: json['reviewId'],
      nickname: json['nickname'],
      type: json['type'],
      createDt: json['createDt'],
      starRating: json['starRating'],
      thumbsUpCount: json['thumbsUpCount'],
      title: json['title'],
      comment: json['comment'],
      deviceProduct: json['deviceProduct'],
      source: json['source'],
      link: json['link'],
    );
  }
}