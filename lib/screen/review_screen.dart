import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:app_review/api/AppReview.dart';
import 'package:app_review/model/AppReviewModel.dart';
import 'package:app_review/screen/second_screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

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
  String? selectedPlatform;

  final Map<String, String> platformMapping = {
    'AOS': 'EBR-01',
    'iOS': 'EBR-02',
    'Cafe': 'EBR-03',
  };

  final List<String?> platforms = [null, 'AOS', 'iOS', 'Cafe'];
  final Map<String?, String> platformLabels = {
    null: '전체',
    'AOS': '안드로이드',
    'iOS': '아이폰',
    'Cafe': '카페'
  };

  @override
  void initState() {
    super.initState();

    getReview().then((data) {
      setState(() {
        isLoading = false;
      });
    });
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
              // DropdownButton<String?>(
              //   value: selectedPlatform,
              //   onChanged: (String? newValue) {
              //     setState(() {
              //       selectedPlatform = newValue;
              //       getReview();
              //     });
              //   },
              //   items: [null, 'AOS', 'iOS', 'Cafe']
              //       .map<DropdownMenuItem<String?>>((String? i) {
              //     return DropdownMenuItem<String?>(
              //       value: i,
              //       child: Text({
              //             'AOS': '안드로이드',
              //             'iOS': '아이폰',
              //             'Cafe': '카페'
              //           }[i] ??
              //           '전체'),
              //     );
              //   }).toList(),
              // ),
              DropdownButtonHideUnderline(
                child: DropdownButton2<String?>(
                  isExpanded: true,
                  value: selectedPlatform,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPlatform = newValue;
                      getReview();
                    });
                  },
                  items: platforms
                      .map<DropdownMenuItem<String?>>((String? platform) {
                    return DropdownMenuItem<String?>(
                      value: platform,
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 8,
                          ),
                          Text(platformLabels[platform] ?? '전체'),
                        ],
                      ),
                    );
                  }).toList(),
                  buttonStyleData: ButtonStyleData(
                    height: 40,
                    width: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.white,
                    ),
                    offset: const Offset(0, 0),
                    scrollbarTheme: ScrollbarThemeData(
                      radius: const Radius.circular(40),
                      thickness: MaterialStateProperty.all(6),
                      thumbVisibility: MaterialStateProperty.all(true),
                    ),
                  ),
                  menuItemStyleData: MenuItemStyleData(
                    height: 40,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : currentModels.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info,
                              size: 30,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              '데이터가 없습니다.',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemBuilder: (context, index) {
                          DateTime dateTime =
                              DateTime.parse(currentModels[index].createDt);

                          DateTime now = DateTime.now();

                          bool isSameDate = (dateTime.year == now.year &&
                              dateTime.month == now.month &&
                              dateTime.day == now.day);

                          return InkWell(
                            onTap: () async {
                              if (currentModels[index].link == '') {
                              } else {
                                final url = currentModels[index].link;
                                if (await canLaunch(url)) {
                                  await launch(
                                    url,
                                    forceSafariVC: false,
                                    forceWebView: false,
                                    enableJavaScript: true,
                                  );
                                } else {
                                  throw 'Could not launch $url';
                                }
                              }
                            },
                            child: ListTile(
                              leading: isSameDate
                                  ? const Text(
                                      'NEW',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic),
                                    )
                                  : null,
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
      String startTime = '';
      String endTime = '';
      if (startDate == null && endDate == null) {
        startTime =
            '${DateTime.now().year.toString()}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
        endTime =
            '${DateTime.now().year.toString()}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
      } else {
        //${date.year}-${date.month}-${date.day}
        startTime =
            '${startDate?.year}-${startDate?.month.toString().padLeft(2, '0')}-${startDate?.day.toString().padLeft(2, '0')}';
        if (endDate == null) {
          endTime =
              '${DateTime.now().year.toString()}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
        } else {
          endTime =
              '${endDate?.year}-${endDate?.month.toString().padLeft(2, '0')}-${endDate?.day.toString().padLeft(2, '0')}';
        }
      }

      AppReviewModel appReviewModel = await AppReview().get(startTime, endTime);

      if (selectedPlatform == null) {
        allModels = appReviewModel.data;
      } else {
        try {
          allModels = appReviewModel.data.where((element) {
            return element.type == platformMapping[selectedPlatform];
          }).toList();
        } catch (e) {
          dev.log(e.toString());
        }
      }
      totalPages = (allModels.length / pageSize).ceil();
      setCurrentPage(1);
      setState(() {});
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

      bool matchesPlatform = (selectedPlatform == null ||
          platformMapping[selectedPlatform]!.contains(item.type));

      return matchesDate && matchesQuery; //&& matchesPlatform;
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
      if (dateType == "start") {
        startDate = picked;
      } else {
        endDate = picked;
      }
      await getReview();
      setState(() {});
    }
  }

  Widget dateSelectionButton(String dateType) {
    DateTime? date = dateType == "start" ? startDate : endDate;
    String label = dateType == "start" ? "시작 날짜" : "종료 날짜";

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _selectDate(context, dateType);
          });
        },
        child: Text(date == null
            ? '$label: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}'
            : '$label: ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'),
      ),
    );
  }
  // Widget dateSelectionButton(String dateType) {
  //   DateTime? date = dateType == "start" ? startDate : endDate;
  //   String label = dateType == "start" ? "시작 날짜" : "종료 날짜";
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: OutlinedButton(
  //       onPressed: () {
  //         setState(() {
  //           _selectDate(context, dateType);
  //         });
  //       },
  //       child: Text(
  //           date == null ? '$label 선택' : '$label: ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day}'),
  //     ),
  //   );
  // }

  Widget refreshDate() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton(
        onPressed: () async {
          setState(() {
            startDate = null;
            endDate = null;
            selectedPlatform = null;
          });
          getReview();
        },
        child: const Text('초기화'),
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
