import 'package:flutter/material.dart';

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: const Text(
          '차지비 리뷰 크롤링',
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
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              accountName: Text('리뷰 대시보드'),
              accountEmail: null,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              child: Text('리뷰'),
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('sfdsdf'),
      ),
    );
  }
}
