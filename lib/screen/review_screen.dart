import 'dart:math';

import 'package:app_review/api/AppReview.dart';
import 'package:app_review/model/AppReviewModel.dart';
import 'package:app_review/screen/second_screen.dart';
import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  AppReviewModel? appReviewModel;
  List<AppReviewData> allModels = [];
  bool isLoading = true;
  // List<TestModel> currentModels = [];
  List<AppReviewData> currentModels = [];
  int currentPage = 1;
  int pageSize = 10;
  int totalPages = 0;
  String searchQuery = "";
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    getReview().then((data) {
      setState(() {
        isLoading = false;
      });
    });
    // fetchAllModels().then((_) {
    //   setState(() {
    //     isLoading = false;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: const Text(
          '차지비 리뷰 모음',
          style: TextStyle(color: Colors.white),
        ),
      ),
      drawer: Drawer(
        shadowColor: Colors.white,
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: Image.asset(
                'asset/img/img_logo_white.png',
              ),
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              accountName: const Text('리뷰 대시보드'),
              accountEmail: null,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              child: Text('리뷰'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => SecondScreen()));
                  },
                  child: Text('테스트페이지')),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          searchField(),
          Row(
            children: [
              refreshDate(),
              dateSelectionButton('start'),
              dateSelectionButton('end'),
            ],
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          '${currentModels[index].title}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${currentModels[index].comment}',
                        ),
                        trailing: Text(
                          '${currentModels[index].createDt}',
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                    itemCount: currentModels.length,
                  ),
          ),
          pagination(),
        ],
      ),
    );
  }

  Future<void> getReview() async {
    try {
      AppReviewModel appReviewModel = await AppReview().get();
      allModels = appReviewModel.data;
      totalPages = (allModels.length / pageSize).ceil();
      setCurrentPage(1);
    } catch (e) {}
  }

  Widget searchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: '검색',
          hintText: '리뷰를 검색하세요.',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: (text) {
          setState(() {
            searchQuery = text;
            filterSearchResults();
          });
        },
      ),
    );
  }

  void filterSearchResults() {
    List<AppReviewData> filteredList = allModels.where((item) {
      DateTime itemDate = DateTime.parse(item.createDt);

      bool matchesDate =
          (startDate == null || itemDate.isAtLeast(startDate!)) &&
              (endDate == null || itemDate.isAtMost(endDate!));

      bool matchesQuery = (searchQuery.isEmpty ||
          item.comment.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.title.toLowerCase().contains(searchQuery.toLowerCase()));

      return matchesDate && matchesQuery;
    }).toList();

    totalPages = (filteredList.length / pageSize).ceil();

    currentModels = filteredList.sublist(0, min(pageSize, filteredList.length));
    currentPage = 1;
  }

  void setCurrentPage(int page) {
    int start = (page - 1) * pageSize;
    int end = min(start + pageSize, allModels.length);
    currentModels = allModels.sublist(start, end);
    currentPage = page;
  }

  Widget pagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: currentPage > 1 ? () => changePage(currentPage - 1) : null,
        ),
        Text('$currentPage / $totalPages'),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: currentPage < totalPages
              ? () => changePage(currentPage + 1)
              : null,
        ),
      ],
    );
  }

  void changePage(int newPage) {
    setState(() {
      setCurrentPage(newPage);
    });
  }

  Future<void> _selectDate(BuildContext context, String dateType) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateType == "start"
          ? startDate ?? DateTime.now()
          : endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (dateType == "start") {
          startDate = picked;
        } else {
          endDate = picked;
        }
        filterSearchResults();
      });
    }
  }

  Widget dateSelectionButton(String dateType) {
    DateTime? date = dateType == "start" ? startDate : endDate;
    String label = dateType == "start" ? "시작 날짜" : "종료 날짜";

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton(
        onPressed: () => _selectDate(context, dateType),
        child: Text(date == null
            ? '$label 선택'
            : '$label: ${date.year}-${date.month}-${date.day}'),
      ),
    );
  }

  Widget refreshDate() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            startDate = null;
            endDate = null;
            filterSearchResults();
          });
        },
        child: const Text('날짜 초기화'),
      ),
    );
  }
}

extension DateTimeComparison on DateTime {
  // 시작일을 정확히 포함하도록 처리
  bool isAtLeast(DateTime other) {
    return !this.isBefore(other);
  }

  // 종료일을 포함하도록 처리
  bool isAtMost(DateTime other) {
    return this.isBefore(other.add(const Duration(days: 1)));
  }
}
