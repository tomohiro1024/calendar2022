import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalenderView extends StatefulWidget {
  const CalenderView({Key? key}) : super(key: key);

  @override
  State<CalenderView> createState() => _CalenderViewState();
}

class _CalenderViewState extends State<CalenderView> {
  // 現在時刻の取得
  DateTime now = DateTime.now();
  //　曜日
  List<String> weekName = ['月', '火', '水', '木', '金', '土', '日'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text(
          DateFormat('yyyy年 M月').format(now),
          style: TextStyle(color: Colors.black),
        ),
        // 影をなくす
        elevation: 0,
      ),
      body: Container(
        height: 30,
        color: Colors.orangeAccent,
        child: Row(
          children: weekName
              .map((e) => Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      // eに月曜日〜日曜日までの文字列の値が入っている。
                      child: Text(e),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
