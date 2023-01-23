import 'package:calendar202211/model/schedule.dart';
import 'package:flutter/cupertino.dart';
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
  List<String> holiday = ['土', '日'];
  late PageController controller;
  DateTime firstDay = DateTime(2023, 1, 1);
  late DateTime selectedDate;
  // firstDayから何ヶ月経っているかという状態を管理
  late int initialIndex;
  int monthDuration = 0;

  DateTime? selectedStartTime;
  DateTime? selectedEndTime;

  late List<int> yearOption;
  List<int> monthOption = List.generate(12, (index) => index + 1);
  List<int>? dayOption;
  void buildDayOption(DateTime selectedDate) {
    List<int> _list = [];
    for (int i = 1;
        i <=
            DateTime(selectedDate.year, selectedDate.month + 1, 1)
                .subtract(Duration(days: 1))
                .day;
        i++) {
      _list.add(i);
    }
    dayOption = _list;
  }

  List<int> hourOption = List.generate(24, (index) => index);
  List<int> minuteOption = List.generate(60, (index) => index);

  // ピッカーの開始か終了かの判断
  bool isSettingStartTime = true;

  Map<DateTime, List<Schedule>> scheduleMap = {
    DateTime(2023, 1, 9): [
      Schedule(
        title: 'shop',
        startAt: DateTime(2023, 1, 9, 10),
        endAt: DateTime(2023, 1, 9, 11),
      ),
    ],
    DateTime(2023, 1, 9): [
      Schedule(
        title: 'shop',
        startAt: DateTime(2023, 1, 9, 10),
        endAt: DateTime(2023, 1, 9, 11),
      ),
    ],
    DateTime(2023, 1, 9): [
      Schedule(
        title: 'shop',
        startAt: DateTime(2023, 1, 9, 10),
        endAt: DateTime(2023, 1, 9, 11),
      ),
    ],
    DateTime(2023, 1, 9): [
      Schedule(
        title: 'shop',
        startAt: DateTime(2023, 1, 9, 10),
        endAt: DateTime(2023, 1, 9, 11),
      ),
    ],
    DateTime(2023, 1, 9): [
      Schedule(
        title: 'shop',
        startAt: DateTime(2023, 1, 9, 10),
        endAt: DateTime(2023, 1, 9, 11),
      ),
    ],
    DateTime(2023, 1, 10): [
      Schedule(
        title: 'shop',
        startAt: DateTime(2023, 1, 9, 10),
        endAt: DateTime(2023, 1, 9, 11),
      ),
    ]
  };

  void selectDate(DateTime casheDate) {
    selectedDate = casheDate;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    yearOption = [now.year, now.year + 1];
    selectedDate = now;
    initialIndex =
        (now.year - firstDay.year) * 12 + (now.month - firstDay.month);
    controller = PageController(initialPage: initialIndex);
    controller.addListener(() {
      monthDuration = (controller.page! - initialIndex).round();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text(
          DateFormat('yyyy年 M月')
              .format(DateTime(now.year, now.month + monthDuration)),
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                            child: Text(
                              e,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: (holiday.any((name) => name == e))
                                    ? Colors.red
                                    : null,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            Expanded(child: createCalenderItem()),
          ],
        ),
      ),
      // 画面右下のプラスボタン
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.orangeAccent,
        onPressed: () {
          selectedStartTime = selectedDate;
          showDialog(
              context: context,
              builder: (context) {
                return buildAppScheduleDialog();
              });
        },
        child: Icon(
          Icons.create,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget buildAppScheduleDialog() {
    final _editController = TextEditingController();
    return StatefulBuilder(builder: (context, setState) {
      return SimpleDialog(
        titlePadding: EdgeInsets.zero,
        title: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _editController,
                      decoration: InputDecoration(
                          hintText: 'タイトルを追加', border: InputBorder.none),
                    ),
                  ),
                ),
                // 削除ボタン
                IconButton(
                  onPressed: () {
                    _editController.clear();
                    // Navigator.pop(context);
                  },
                  splashRadius: 15,
                  splashColor: Colors.red,
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
                // 追加ボタン
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  splashRadius: 15,
                  splashColor: Colors.green,
                  icon: Icon(
                    Icons.done,
                    color: Colors.green,
                  ),
                ),
                //閉じるボタン
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  splashRadius: 15,
                  splashColor: Colors.red,
                  icon: Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                // 開始時刻
                GestureDetector(
                  onTap: () async {
                    buildDayOption(selectedDate);
                    isSettingStartTime = true;
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return buildSelectedTimeDialog();
                        });
                    setState(() {});
                  },
                  child: Container(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat('yyyy').format(selectedStartTime!)),
                        SizedBox(width: 5),
                        Text(DateFormat('MM/dd').format(selectedStartTime!)),
                        SizedBox(width: 5),
                        Text(DateFormat('HH:mm').format(selectedStartTime!)),
                      ],
                    ),
                  ),
                ),
                // 終了時刻
                GestureDetector(
                  onTap: () async {
                    buildDayOption(selectedDate);
                    isSettingStartTime = false;
                    selectedEndTime ??= selectedStartTime;
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return buildSelectedTimeDialog();
                        });
                    setState(() {});
                  },
                  child: Container(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(selectedEndTime == null
                            ? '-----'
                            : DateFormat('yyyy').format(selectedEndTime!)),
                        SizedBox(width: 5),
                        Text(selectedEndTime == null
                            ? '--/--'
                            : DateFormat('MM/dd').format(selectedEndTime!)),
                        SizedBox(width: 5),
                        Text(selectedEndTime == null
                            ? '--:--'
                            : DateFormat('HH:mm').format(selectedEndTime!)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget buildSelectedTimeDialog() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: StatefulBuilder(builder: (context, setState) {
        return SimpleDialog(
          titlePadding: EdgeInsets.zero,
          title: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '日時を選択',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // 追加ボタン
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    splashRadius: 15,
                    splashColor: Colors.green,
                    icon: Icon(
                      Icons.done,
                      color: Colors.green,
                    ),
                  ),
                  // 削除ボタン
                  IconButton(
                    onPressed: () {
                      // _editController.clear();
                      Navigator.pop(context);
                    },
                    splashRadius: 15,
                    splashColor: Colors.red,
                    icon: Icon(
                      Icons.close,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              Container(
                height: 120,
                width: 350,
                child: Row(
                  children: [
                    // 年ピッカー
                    Expanded(
                      flex: 2,
                      child: CupertinoPicker(
                          selectionOverlay:
                              const CupertinoPickerDefaultSelectionOverlay(
                                  background: Colors.transparent),
                          itemExtent: 35,
                          onSelectedItemChanged: (int index) {
                            if (isSettingStartTime) {
                              selectedStartTime = DateTime(
                                  yearOption[index],
                                  selectedStartTime!.month,
                                  selectedStartTime!.day,
                                  selectedStartTime!.hour,
                                  selectedStartTime!.minute);
                            } else {
                              selectedEndTime = DateTime(
                                  yearOption[index],
                                  selectedEndTime!.month,
                                  selectedEndTime!.day,
                                  selectedEndTime!.hour,
                                  selectedEndTime!.minute);
                            }
                          },
                          children: yearOption
                              .map(
                                (e) => Container(
                                  alignment: Alignment.center,
                                  height: 35,
                                  child: Text('$e'),
                                ),
                              )
                              .toList()),
                    ),
                    Text('年'),
                    // 月ピッカー
                    Expanded(
                      child: CupertinoPicker(
                          selectionOverlay:
                              const CupertinoPickerDefaultSelectionOverlay(
                                  background: Colors.transparent),
                          itemExtent: 35,
                          onSelectedItemChanged: (int index) {
                            if (isSettingStartTime) {
                              selectedStartTime = DateTime(
                                  selectedStartTime!.year,
                                  monthOption[index],
                                  selectedStartTime!.day,
                                  selectedStartTime!.hour,
                                  selectedStartTime!.minute);
                              buildDayOption(selectedStartTime!);
                            } else {
                              selectedEndTime = DateTime(
                                  selectedEndTime!.year,
                                  monthOption[index],
                                  selectedEndTime!.day,
                                  selectedEndTime!.hour,
                                  selectedEndTime!.minute);
                              buildDayOption(selectedEndTime!);
                            }
                            setState(() {});
                          },
                          children: monthOption
                              .map(
                                (e) => Container(
                                  alignment: Alignment.center,
                                  height: 35,
                                  child: Text('$e'),
                                ),
                              )
                              .toList()),
                    ),
                    Text('月'),
                    // 日ピッカー
                    Expanded(
                      child: CupertinoPicker(
                          selectionOverlay:
                              const CupertinoPickerDefaultSelectionOverlay(
                                  background: Colors.transparent),
                          itemExtent: 35,
                          onSelectedItemChanged: (int index) {
                            if (isSettingStartTime) {
                              selectedStartTime = DateTime(
                                  selectedStartTime!.year,
                                  selectedStartTime!.month,
                                  dayOption![index],
                                  selectedStartTime!.hour,
                                  selectedStartTime!.minute);
                            } else {
                              selectedEndTime = DateTime(
                                  selectedEndTime!.year,
                                  selectedEndTime!.month,
                                  dayOption![index],
                                  selectedEndTime!.hour,
                                  selectedEndTime!.minute);
                            }
                          },
                          children: dayOption!
                              .map(
                                (e) => Container(
                                  alignment: Alignment.center,
                                  height: 35,
                                  child: Text('$e'),
                                ),
                              )
                              .toList()),
                    ),
                    Text('日'),
                    // 時ピッカー
                    Expanded(
                      child: CupertinoPicker(
                          selectionOverlay:
                              const CupertinoPickerDefaultSelectionOverlay(
                                  background: Colors.transparent),
                          itemExtent: 35,
                          onSelectedItemChanged: (int index) {
                            if (isSettingStartTime) {
                              selectedStartTime = DateTime(
                                  selectedStartTime!.year,
                                  selectedStartTime!.month,
                                  selectedStartTime!.day,
                                  hourOption[index],
                                  selectedStartTime!.minute);
                            } else {
                              selectedEndTime = DateTime(
                                  selectedEndTime!.year,
                                  selectedEndTime!.month,
                                  selectedEndTime!.day,
                                  hourOption[index],
                                  selectedEndTime!.minute);
                            }
                          },
                          children: hourOption
                              .map(
                                (e) => Container(
                                  alignment: Alignment.center,
                                  height: 35,
                                  child: Text('$e'),
                                ),
                              )
                              .toList()),
                    ),
                    Text('時'),
                    // 分ピッカー
                    Expanded(
                      child: CupertinoPicker(
                          selectionOverlay:
                              const CupertinoPickerDefaultSelectionOverlay(
                                  background: Colors.transparent),
                          itemExtent: 35,
                          onSelectedItemChanged: (int index) {
                            if (isSettingStartTime) {
                              selectedStartTime = DateTime(
                                  selectedStartTime!.year,
                                  selectedStartTime!.month,
                                  selectedStartTime!.day,
                                  selectedStartTime!.hour,
                                  minuteOption[index]);
                            } else {
                              selectedEndTime = DateTime(
                                  selectedEndTime!.year,
                                  selectedEndTime!.month,
                                  selectedEndTime!.day,
                                  selectedEndTime!.hour,
                                  minuteOption[index]);
                            }
                          },
                          children: minuteOption
                              .map(
                                (e) => Container(
                                  alignment: Alignment.center,
                                  height: 35,
                                  child: Text('$e'),
                                ),
                              )
                              .toList()),
                    ),
                    Text('分'),
                  ],
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget createCalenderItem() {
    return PageView.builder(
        controller: controller,
        itemBuilder: (context, index) {
          List<Widget> _list = [];
          List<Widget> _listCache = [];

          DateTime date =
              DateTime(now.year, now.month + index - initialIndex, 1);

          int monthLastDay = DateTime(date.year, date.month + 1, 1)
              .subtract(Duration(days: 1))
              .day;

          for (int i = 0; i < monthLastDay; i++) {
            _listCache.add(_CalenderItem(
              day: i + 1,
              now: now,
              casheDate: DateTime(date.year, date.month, i + 1),
              scheduleList: scheduleMap[DateTime(date.year, date.month, i + 1)],
              selectedDate: selectedDate,
              selectDate: selectDate,
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
  final DateTime selectedDate;
  final List<Schedule>? scheduleList;
  final Function selectDate;
  const _CalenderItem(
      {required this.day,
      required this.now,
      required this.casheDate,
      required this.selectedDate,
      this.scheduleList,
      required this.selectDate,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isSelected = (selectedDate.difference(casheDate).inDays == 0) &&
        (selectedDate.day == casheDate.day);
    // 今日がどうかの判定
    bool isToday =
        (now.difference(casheDate).inDays == 0) && (now.day == casheDate.day);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          selectDate(casheDate);
        },
        child: Container(
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            color: isSelected ? Colors.redAccent.withOpacity(0.2) : null,
            border: Border.all(color: Colors.orangeAccent),
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isToday ? Colors.orange : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.topCenter,
                width: 20,
                height: 20,
                child: Text(
                  '$day',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              scheduleList == null
                  ? Container()
                  : Column(
                      children: scheduleList!
                          .map((e) => Container(
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                width: double.infinity,
                                height: 20,
                                alignment: Alignment.centerLeft,
                                margin:
                                    EdgeInsets.only(top: 2, left: 2, right: 2),
                                child: Text(
                                  e.title,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
