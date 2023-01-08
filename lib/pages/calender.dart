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
      body: SafeArea(
        child: Column(
          children: [
            Container(
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
            Expanded(child: createCalenderItem()),
          ],
        ),
      ),
    );
  }

  Widget createCalenderItem() {
    return PageView.builder(itemBuilder: (context, index) {
      List<Widget> _list = [];
      List<Widget> _listCache = [];
      // 今月の最終日の取得
      int monthLastDay =
          DateTime(now.year, now.month + 1, 1).subtract(Duration(days: 1)).day;

      DateTime date = DateTime(now.year, now.month, 1);

      for (int i = 0; i < monthLastDay; i++) {
        _listCache.add(_CalenderItem(
          day: i + 1,
          now: now,
          casheDate: DateTime(now.year, now.month, i + 1),
        ));
        int repeatNumber = 7 - _listCache.length;
        if (date.add(Duration(days: i)).weekday == 7) {
          if (i < 7) {
            _listCache.insertAll(
                0,
                List.generate(
                    repeatNumber,
                    (index) => Expanded(
                            child: Container(
                          color: Colors.orangeAccent.withOpacity(0.3),
                        ))));
          }
          _list.add(Expanded(child: Row(children: _listCache)));
          _listCache = [];
        } else if (i == monthLastDay - 1) {
          _listCache.addAll(List.generate(
              repeatNumber,
              (index) => Expanded(
                      child: Container(
                    color: Colors.orangeAccent.withOpacity(0.3),
                  ))));
          _list.add(Expanded(child: Row(children: _listCache)));
        }
      }
      return Column(
        children: _list,
      );
    });
  }
}

class _CalenderItem extends StatelessWidget {
  final int day;
  final DateTime now;
  final DateTime casheDate;
  const _CalenderItem(
      {required this.day, required this.now, required this.casheDate, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 今日がどうかの判定
    bool isToday =
        (now.difference(casheDate).inDays == 0) && (now.day == casheDate.day);
    return Expanded(
      child: Container(
        alignment: Alignment.topCenter,
        child: Container(
          decoration: BoxDecoration(
            color: isToday ? Colors.orange : null,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.topCenter,
          width: 20,
          height: 20,
          child: Text('$day'),
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orangeAccent),
        ),
      ),
    );
  }
}
